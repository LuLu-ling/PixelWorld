param([string]$Blue, [string]$Fg, [string]$Repo)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Resize([Drawing.Image]$src, [int]$size) {
    $bmp = New-Object Drawing.Bitmap $size, $size, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'; $g.SmoothingMode = 'HighQuality'
    $g.CompositingQuality = 'HighQuality'
    $g.DrawImage($src, 0, 0, $size, $size)
    $g.Dispose(); return $bmp
}

# Rounded square, optional margin (fraction of the canvas on each side)
function Rounded([Drawing.Image]$src, [int]$size, [double]$margin, [double]$radius) {
    $bmp = New-Object Drawing.Bitmap $size, $size, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'; $g.SmoothingMode = 'AntiAlias'
    $g.Clear([Drawing.Color]::Transparent)
    $m = [float]($size * $margin); $w = [float]($size - 2 * $m); $r = [float]($w * $radius); $d = 2 * $r
    $path = New-Object Drawing.Drawing2D.GraphicsPath
    $path.AddArc($m, $m, $d, $d, 180, 90); $path.AddArc($m + $w - $d, $m, $d, $d, 270, 90)
    $path.AddArc($m + $w - $d, $m + $w - $d, $d, $d, 0, 90); $path.AddArc($m, $m + $w - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $scaled = Resize $src ([int]$w)
    $brush = [Drawing.TextureBrush]::new($scaled, [Drawing.Drawing2D.WrapMode]::Clamp)
    $brush.TranslateTransform($m, $m)
    $g.FillPath($brush, $path)
    $g.Dispose(); return $bmp
}

# White silhouette from the alpha channel (Android 13 themed icon)
function Mono([Drawing.Bitmap]$src) {
    $bmp = New-Object Drawing.Bitmap $src.Width, $src.Height, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
    for ($y = 0; $y -lt $src.Height; $y++) { for ($x = 0; $x -lt $src.Width; $x++) {
        $a = $src.GetPixel($x, $y).A
        $bmp.SetPixel($x, $y, [Drawing.Color]::FromArgb($a, 255, 255, 255))
    } }
    return $bmp
}

function SavePng([Drawing.Image]$img, [string]$path) {
    New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
    $img.Save($path, [Drawing.Imaging.ImageFormat]::Png)
}

$imgBlue = [Drawing.Image]::FromFile($Blue)
$imgFg = [Drawing.Image]::FromFile($Fg)

# Sources kept in the repo
SavePng (Resize $imgBlue 1024) "$Repo\assets\icon\icon.png"
SavePng (Resize $imgFg 1024) "$Repo\assets\icon\icon_foreground.png"

# Android: adaptive foreground/monochrome (108 dp) and legacy icon (48 dp)
$res = "$Repo\android\app\src\main\res"
foreach ($d in @(@('mdpi', 1), @('hdpi', 1.5), @('xhdpi', 2), @('xxhdpi', 3), @('xxxhdpi', 4))) {
    $fgSized = Resize $imgFg ([int](108 * $d[1]))
    SavePng $fgSized "$res\mipmap-$($d[0])\ic_launcher_foreground.png"
    SavePng (Mono $fgSized) "$res\mipmap-$($d[0])\ic_launcher_monochrome.png"
    SavePng (Rounded $imgBlue ([int](48 * $d[1])) 0 0.22) "$res\mipmap-$($d[0])\ic_launcher.png"
}

# Windows: .ico with PNG entries
$sizes = 16, 24, 32, 48, 64, 128, 256
$pngs = foreach ($s in $sizes) {
    $ms = New-Object IO.MemoryStream
    (Rounded $imgBlue $s 0 0.18).Save($ms, [Drawing.Imaging.ImageFormat]::Png)
    , $ms.ToArray()
}
$ico = New-Object IO.MemoryStream
$w = New-Object IO.BinaryWriter $ico
$w.Write([uint16]0); $w.Write([uint16]1); $w.Write([uint16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $s = $sizes[$i]; $b = if ($s -ge 256) { 0 } else { $s }
    $w.Write([byte]$b); $w.Write([byte]$b); $w.Write([byte]0); $w.Write([byte]0)
    $w.Write([uint16]1); $w.Write([uint16]32); $w.Write([uint32]$pngs[$i].Length); $w.Write([uint32]$offset)
    $offset += $pngs[$i].Length
}
foreach ($p in $pngs) { $w.Write($p) }
$w.Flush()
[IO.File]::WriteAllBytes("$Repo\windows\runner\resources\app_icon.ico", $ico.ToArray())

# macOS: Apple's grid (824/1024 body, about 22% corner radius)
foreach ($s in 16, 32, 64, 128, 256, 512, 1024) {
    SavePng (Rounded $imgBlue $s (100 / 1024) 0.2237) "$Repo\macos\Runner\Assets.xcassets\AppIcon.appiconset\app_icon_$s.png"
}
$imgBlue.Dispose(); $imgFg.Dispose()
'done'
