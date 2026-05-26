"""Generate app icon for 日拱一卒 (rigongyizu).

Design: warm orange (#FF6B35) background with a white Chinese chess pawn silhouette.
"""
from PIL import Image, ImageDraw
import os


PRIMARY = (255, 107, 53)


def generate_icon(size):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    margin = max(1, int(size * 0.04))
    radius = int(size * 0.22)
    draw.rounded_rectangle((margin, margin, size - margin, size - margin),
                           radius=radius, fill=PRIMARY)

    cx = size / 2
    s = size

    # Head (circle)
    head_r = s * 0.16
    head_cy = s * 0.30
    draw.ellipse([cx - head_r, head_cy - head_r, cx + head_r, head_cy + head_r],
                 fill=(255, 255, 255))

    # Neck
    neck_w = s * 0.06
    neck_top = head_cy + head_r * 0.6
    neck_bot = s * 0.44
    draw.rectangle([cx - neck_w/2, neck_top, cx + neck_w/2, neck_bot],
                    fill=(255, 255, 255))

    # Body (trapezoid)
    body_top = neck_bot
    body_bot = s * 0.64
    draw.polygon([
        (cx - s * 0.12, body_top),
        (cx + s * 0.12, body_top),
        (cx + s * 0.22, body_bot),
        (cx - s * 0.22, body_bot),
    ], fill=(255, 255, 255))

    # Base
    base_half = s * 0.25
    base_top = body_bot
    base_bot = s * 0.72
    draw.rounded_rectangle([cx - base_half, base_top, cx + base_half, base_bot],
                           radius=s * 0.04, fill=(255, 255, 255))

    # Three dots (日 - daily rhythm)
    dot_r = max(1, int(s * 0.025))
    dot_y = s * 0.82
    for i in range(3):
        dx = cx + (i - 1) * s * 0.10
        draw.ellipse([dx - dot_r, dot_y - dot_r, dx + dot_r, dot_y + dot_r],
                     fill=(255, 255, 255))

    return img


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    android_sizes = {
        'mdpi': 48, 'hdpi': 72, 'xhdpi': 96,
        'xxhdpi': 144, 'xxxhdpi': 192,
    }
    ios_sizes = {
        'Icon-App-20x20@1x': 20, 'Icon-App-20x20@2x': 40, 'Icon-App-20x20@3x': 60,
        'Icon-App-29x29@1x': 29, 'Icon-App-29x29@2x': 58, 'Icon-App-29x29@3x': 87,
        'Icon-App-40x40@1x': 40, 'Icon-App-40x40@2x': 80, 'Icon-App-40x40@3x': 120,
        'Icon-App-60x60@2x': 120, 'Icon-App-60x60@3x': 180,
        'Icon-App-76x76@1x': 76, 'Icon-App-76x76@2x': 152,
        'Icon-App-83.5x83.5@2x': 167, 'Icon-App-1024x1024@1x': 1024,
    }

    for density, px in android_sizes.items():
        icon = generate_icon(px)
        path = os.path.join(root, 'android', 'app', 'src', 'main', 'res',
                            f'mipmap-{density}', 'ic_launcher.png')
        icon.save(path, 'PNG')
        print(f'  Android {density}: {px}x{px}')

    ios_dir = os.path.join(root, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
    for name, px in ios_sizes.items():
        icon = generate_icon(px)
        path = os.path.join(ios_dir, f'{name}.png')
        icon.save(path, 'PNG')
        print(f'  iOS {name}: {px}x{px}')

    preview = generate_icon(512)
    preview_path = os.path.join(root, 'tmp', 'icon_preview.png')
    os.makedirs(os.path.dirname(preview_path), exist_ok=True)
    preview.save(preview_path, 'PNG')
    print(f'\nPreview: {preview_path}')


if __name__ == '__main__':
    main()
