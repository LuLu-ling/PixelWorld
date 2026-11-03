# Puts "P C / L ." on the cube's left face and "PW" on its right face.
# Face geometry is given for the 1254 px blue source; $scale/$topY adapt it to the transparent one.
param([string]$Src, [string]$Out, [double]$Scale = 1.0, [double]$TopY = 272, [string]$FontName = 'Segoe UI Black')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$img = [Drawing.Bitmap]::FromFile($Src)
$canvas = New-Object Drawing.Bitmap $img.Width, $img.Height, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gr = [Drawing.Graphics]::FromImage($canvas)
$gr.DrawImage($img, 0, 0, $img.Width, $img.Height)
$gr.SmoothingMode = 'AntiAlias'
$gr.TextRenderingHint = 'AntiAlias'

# Points measured on the blue source, scaled about the cube's top vertex (627, 272)
function Pt([double]$x, [double]$y) { [Drawing.PointF]::new(627 + ($x - 627) * $Scale, $TopY + ($y - 272) * $Scale) }

$ink = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(255, 0x14, 0x71, 0xFD))
$font = [Drawing.FontFamily]::new($FontName)

# The faces are drawn wider than tall (horizontal edge about 383 px, vertical about 340 px on the
# 1254 px source), so glyphs are narrowed by that ratio before mapping to keep their proportions
$narrow = 340.0 / 383.0

# Draws text centred at (cx, cy) in a 100x100 face space mapped by origin/u/v
function FaceText([Drawing.PointF]$o, [Drawing.PointF]$u, [Drawing.PointF]$v, [string]$text, [double]$cx, [double]$cy, [double]$em) {
    $path = GlyphPath $text $em
    $b = $path.GetBounds()
    $centre = New-Object Drawing.Drawing2D.Matrix
    $centre.Translate([float]($cx - $b.X - $b.Width / 2), [float]($cy - $b.Y - $b.Height / 2))
    $path.Transform($centre)
    # face space (0..100, 0..100) -> image
    $m = [Drawing.Drawing2D.Matrix]::new(($u.X - $o.X) / 100, ($u.Y - $o.Y) / 100, ($v.X - $o.X) / 100, ($v.Y - $o.Y) / 100, $o.X, $o.Y)
    $path.Transform($m)
    $gr.FillPath($ink, $path)
}

function GlyphPath([string]$text, [double]$em) {
    $path = New-Object Drawing.Drawing2D.GraphicsPath
    $path.AddString($text, $font, [int][Drawing.FontStyle]::Regular, [float]$em, [Drawing.PointF]::new(0, 0),
        [Drawing.StringFormat]::GenericTypographic)
    $squeeze = New-Object Drawing.Drawing2D.Matrix
    $squeeze.Scale([float]$narrow, 1)
    $path.Transform($squeeze)
    return $path
}

# Draws a glyph with its left edge at $left and the cap top of its line at $capTop (face space),
# so letters in a column share a left edge and letters in a row share a baseline
function GlyphAt([Drawing.PointF]$o, [Drawing.PointF]$u, [Drawing.PointF]$v, [string]$text, [double]$left, [double]$capTop, [double]$em) {
    $path = GlyphPath $text $em
    $capY = (GlyphPath 'H' $em).GetBounds().Y
    $shift = New-Object Drawing.Drawing2D.Matrix
    $shift.Translate([float]($left - $path.GetBounds().X), [float]($capTop - $capY))
    $path.Transform($shift)
    $m = [Drawing.Drawing2D.Matrix]::new(($u.X - $o.X) / 100, ($u.Y - $o.Y) / 100, ($v.X - $o.X) / 100, ($v.Y - $o.Y) / 100, $o.X, $o.Y)
    $path.Transform($m)
    $gr.FillPath($ink, $path)
}

# Left face: top-left corner, front-top vertex, bottom-left corner. "P C / L ." as a 2x2 block,
# centred on the face: columns left-aligned, rows on a shared baseline
$lo = Pt 290 465; $lu = Pt 627 645; $lv = Pt 290 800
$em = 50; $colGap = 5; $rowGap = 8
$w = @{}; foreach ($ch in 'P', 'C', 'L', '.') { $w[$ch] = (GlyphPath $ch $em).GetBounds().Width }
$cap = (GlyphPath 'H' $em).GetBounds().Height
$col1 = [Math]::Max($w['P'], $w['L']); $col2 = [Math]::Max($w['C'], $w['.'])
$x1 = (100 - ($col1 + $colGap + $col2)) / 2; $x2 = $x1 + $col1 + $colGap
$y1 = (100 - (2 * $cap + $rowGap)) / 2; $y2 = $y1 + $cap + $rowGap
GlyphAt $lo $lu $lv 'P' $x1 $y1 $em
GlyphAt $lo $lu $lv 'C' $x2 $y1 $em
GlyphAt $lo $lu $lv 'L' $x1 $y2 $em
GlyphAt $lo $lu $lv '.' $x2 $y2 $em
# Right face: front-top vertex, top-right corner, front-bottom vertex
$ro = Pt 627 645; $ru = Pt 965 465; $rv = Pt 627 985
FaceText $ro $ru $rv 'PW' 50 52 52

$gr.Dispose(); $img.Dispose()
$canvas.Save($Out, [Drawing.Imaging.ImageFormat]::Png)
'saved ' + $Out
