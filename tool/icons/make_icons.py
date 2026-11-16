"""生成 Pixel World 的应用图标（Windows、macOS、安卓、Linux、启动器内、网站）。

源图是 assets/icon/source/cube_transparent.png（透明底的白色立方体）。
脚本在左侧面印 P、右侧面印 W：字母按等轴测投影贴到面上（在立体空间里是正的），
并沿面的法线方向凸起一点，和顶面中间凸起的小方块一致。

用法（需要 Pillow 和 numpy；字体用 Windows 自带的 Bahnschrift）：
    python tool/icons/make_icons.py
"""

from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

REPO = Path(__file__).resolve().parents[2]
SRC = REPO / 'assets/icon/source/cube_transparent.png'
FONT = Path('C:/Windows/Fonts/bahnschrift.ttf')

# 立方体各顶点（在 1254 px 的源图上量得）
_TOP = (627, 270)
_SCALE = 1.05


def _pt(x, y):
    """在旧蓝底图上量的点换算到透明源图（以顶点为中心缩放）"""
    return np.array([_TOP[0] + (x - 627) * _SCALE, _TOP[1] + (y - 272) * _SCALE])


# 每个面：原点、横边终点、竖边终点
FACES = {
    'L': (_pt(290, 465), _pt(627, 645), _pt(290, 800)),
    'R': (_pt(627, 645), _pt(965, 465), _pt(627, 985)),
}

N = 1200  # 面空间分辨率：面在立体空间里是正方形
EM = 0.80  # 字号（相对面的边长）
W_SQUEEZE = 0.8  # W 比 P 宽很多，斜着看会显得更大更高，收窄一些让两边平衡
DEPTH = 0.010  # 凸起的厚度（相对图片宽度）
SIDE = 0.78  # 侧壁比字面暗多少
BLUE = np.array([20, 113, 253])


def _unit(v):
    return v / np.linalg.norm(v)


# 面的外法线投影到画面上的方向：左面朝左下，右面朝右下
NORMALS = {'L': _unit(FACES['R'][0] - FACES['R'][1]), 'R': _unit(FACES['L'][1] - FACES['L'][0])}


def _glyph(ch):
    font = ImageFont.truetype(str(FONT), int(N * EM))
    font.set_variation_by_axes([700, 100])  # Bold，正常宽度
    tmp = Image.new('L', (N * 2, N), 0)
    d = ImageDraw.Draw(tmp)
    l, t, r, b = d.textbbox((0, 0), ch, font=font)
    d.text((-l, -t), ch, font=font, fill=255)
    g = tmp.crop((0, 0, r - l, b - t))
    if ch == 'W':
        g = g.resize((int(g.width * W_SQUEEZE), g.height), Image.LANCZOS)
    m = Image.new('L', (N, N), 0)
    m.paste(g, ((N - g.width) // 2, (N - g.height) // 2))
    return m


def _to_image(mask, size, o, u, v):
    """面空间 (0..N) → 画面：p = o + (u-o)·s + (v-o)·t"""
    a = np.column_stack([(u - o) / N, (v - o) / N])
    inv = np.linalg.inv(a)
    c = -inv @ o
    return mask.transform(size, Image.AFFINE, (inv[0, 0], inv[0, 1], c[0], inv[1, 0], inv[1, 1], c[1]), Image.BICUBIC)


def _shift(m, d):
    return ImageChops.offset(m, int(round(d[0])), int(round(d[1])))


def _face_rgb(img, o, u, v):
    c = (o + u + v + (u + v - o)) / 4
    x, y = int(c[0]), int(c[1])
    return np.array(img)[y - 20 : y + 20, x - 20 : x + 20, :3].reshape(-1, 3).astype(float).mean(0)


def render():
    """返回（印好字的立方体，字母的遮罩）"""
    img = Image.open(SRC).convert('RGBA')
    size = img.size
    out = img.copy()
    letters = Image.new('L', size, 0)
    left = _face_rgb(img, *FACES['L']).mean()
    depth = size[0] * DEPTH
    for key, ch in (('L', 'P'), ('R', 'W')):
        o, u, v = FACES[key]
        m = _to_image(_glyph(ch), size, o, u, v)
        k = _face_rgb(img, o, u, v).mean() / left  # 右面比左面暗，字也跟着暗
        top = tuple(int(c) for c in np.clip(BLUE * k, 0, 255)) + (255,)
        side = tuple(int(c) for c in np.clip(BLUE * k * SIDE, 0, 255)) + (255,)
        n = NORMALS[key]
        # 落在面上的淡阴影
        sh = _shift(m, n * depth * 1.6).filter(ImageFilter.GaussianBlur(depth * 0.8))
        shadow = Image.new('RGBA', size, (10, 40, 120, 0))
        shadow.putalpha(sh.point(lambda a: int(a * 0.25)))
        out.alpha_composite(shadow)
        # 侧壁沿法线一层层叠起来，字面在最外层
        layer = Image.new('RGBA', size, (0, 0, 0, 0))
        for i in range(int(depth)):
            layer.paste(side, (0, 0), _shift(m, n * i))
        face = _shift(m, n * depth)
        layer.paste(top, (0, 0), face)
        out.alpha_composite(layer)
        letters = ImageChops.lighter(letters, face)
    # 去掉立方体外面那圈很淡的光晕，裁边时不会留下硬边
    body = img.getchannel('A').point(lambda a: 255 if a > 140 else 0).filter(ImageFilter.MaxFilter(5))
    out.putalpha(ImageChops.multiply(out.getchannel('A'), body))
    return out, letters, body.getbbox()


def _square(img, bbox, margin):
    """裁到立方体，四周留 margin（相对边长），放进正方形"""
    c = img.crop(bbox)
    s = int(max(c.size) / (1 - 2 * margin))
    sq = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    sq.paste(c, ((s - c.width) // 2, (s - c.height) // 2), c)
    return sq


def _resize(img, s):
    return img.resize((s, s), Image.LANCZOS)


def _save(img, rel):
    p = REPO / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    img.save(p)


def main():
    cube, letters, bbox = render()
    tight = _square(cube, bbox, 0)  # 立方体是六边形，四角本来就空，不再留边

    # 启动器内（标题栏、启动页、关于）、Linux 窗口图标、网站
    _save(_resize(tight, 1024), 'assets/icon/icon.png')
    _save(_resize(tight, 320), 'docs/icon.png')
    _save(_resize(tight, 64), 'docs/favicon.png')

    # 安卓自适应图标：108dp 的画布里只有中间直径 66dp 的圆一定可见（桌面会裁成圆形或圆角方形），
    # 立方体高度缩到约 60dp 放进去；背景是白色（colors.xml）
    adaptive = _square(cube, bbox, 0.22)
    _save(_resize(adaptive, 1024), 'assets/icon/icon_foreground.png')
    # 单色主题图标：立方体的剪影，字母镂空
    mono = Image.new('RGBA', cube.size, (255, 255, 255, 0))
    mono.putalpha(ImageChops.subtract(cube.getchannel('A'), letters))
    mono = _square(mono, bbox, 0.22)
    # 旧版安卓（8.0 以前）的普通图标：白色圆角方块上放立方体
    legacy = Image.new('RGBA', (1024, 1024), (255, 255, 255, 0))
    plate = Image.new('L', (1024, 1024), 0)
    ImageDraw.Draw(plate).rounded_rectangle((0, 0, 1023, 1023), radius=225, fill=255)
    legacy.paste((255, 255, 255, 255), (0, 0), plate)
    legacy.alpha_composite(_resize(_square(cube, bbox, 0.12), 1024))
    res = 'android/app/src/main/res'
    for name, k in (('mdpi', 1), ('hdpi', 1.5), ('xhdpi', 2), ('xxhdpi', 3), ('xxxhdpi', 4)):
        _save(_resize(adaptive, int(108 * k)), f'{res}/mipmap-{name}/ic_launcher_foreground.png')
        _save(_resize(mono, int(108 * k)), f'{res}/mipmap-{name}/ic_launcher_monochrome.png')
        _save(_resize(legacy, int(48 * k)), f'{res}/mipmap-{name}/ic_launcher.png')

    # Windows：多尺寸 .ico（透明底，立方体占满）
    ico = REPO / 'windows/runner/resources/app_icon.ico'
    tight.save(ico, sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)])

    # macOS：按苹果的网格，主体占 824/1024，透明底
    mac = _square(cube, bbox, 100 / 1024)
    for s in (16, 32, 64, 128, 256, 512, 1024):
        _save(_resize(mac, s), f'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_{s}.png')
    print('done')


if __name__ == '__main__':
    main()
