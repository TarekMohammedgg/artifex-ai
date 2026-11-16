import math
from PIL import Image, ImageDraw, ImageFilter

def create_aperture_emblem(size=432):
    """Creates the glowing camera aperture prism emblem with transparent background."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    center = size // 2
    
    # In adaptive icons, emblem should occupy ~65% of total canvas to stay within safe zone
    emblem_r = int(size * 0.32)
    
    # Outer bezel
    bezel_draw = ImageDraw.Draw(img)
    bezel_draw.ellipse(
        [center - emblem_r, center - emblem_r, center + emblem_r, center + emblem_r],
        fill=(30, 32, 44, 255),
        outline=(0, 229, 255, 180),
        width=int(size * 0.016)
    )
    
    inner_bezel_r = int(emblem_r * 0.88)
    bezel_draw.ellipse(
        [center - inner_bezel_r, center - inner_bezel_r, center + inner_bezel_r, center + inner_bezel_r],
        fill=(16, 17, 22, 255),
        outline=(255, 255, 255, 40),
        width=2
    )
    
    # Aperture / Prism Blades
    blade_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(blade_layer)
    
    colors = [
        (0, 229, 255, 240),   # Bright Cyan
        (64, 156, 255, 240),  # Blue
        (138, 43, 226, 240),  # Royal Purple
        (236, 72, 153, 240),  # Neon Pink
        (249, 115, 22, 240),  # Vivid Orange
        (16, 185, 129, 240),  # Emerald Green
    ]
    
    blade_r = int(inner_bezel_r * 0.90)
    aperture_hole_r = int(blade_r * 0.32)
    num_blades = len(colors)
    
    for i, col in enumerate(colors):
        angle1 = math.radians(i * (360 / num_blades))
        angle2 = math.radians((i + 1.25) * (360 / num_blades))
        angle3 = math.radians((i + 0.6) * (360 / num_blades))
        
        p1 = (center + int(blade_r * math.cos(angle1)), center + int(blade_r * math.sin(angle1)))
        p2 = (center + int(blade_r * math.cos(angle2)), center + int(blade_r * math.sin(angle2)))
        p3 = (center + int(aperture_hole_r * math.cos(angle3)), center + int(aperture_hole_r * math.sin(angle3)))
        
        b_draw.polygon([p1, p2, p3], fill=col)
        b_draw.line([p1, p2], fill=(255, 255, 255, 140), width=int(size * 0.008))
        b_draw.line([p2, p3], fill=(255, 255, 255, 80), width=int(size * 0.005))
        
    img = Image.alpha_composite(img, blade_layer)
    
    # Center aperture core
    center_iris = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ci_draw = ImageDraw.Draw(center_iris)
    ci_draw.ellipse(
        [center - aperture_hole_r, center - aperture_hole_r, center + aperture_hole_r, center + aperture_hole_r],
        fill=(10, 11, 15, 255),
        outline=(0, 229, 255, 220),
        width=int(size * 0.01)
    )
    
    # Glowing spark
    spark_r = int(aperture_hole_r * 0.45)
    ci_draw.ellipse([center - spark_r, center - spark_r, center + spark_r, center + spark_r], fill=(0, 229, 255, 240))
    
    img = Image.alpha_composite(img, center_iris)
    
    # Viewfinder corners in safe zone
    vf_draw = ImageDraw.Draw(img)
    vf_color = (0, 229, 255, 190)
    vf_len = int(size * 0.06)
    vf_margin = int(size * 0.17)
    vf_width = int(size * 0.009)
    
    # Top-Left
    vf_draw.line([(vf_margin, vf_margin), (vf_margin + vf_len, vf_margin)], fill=vf_color, width=vf_width)
    vf_draw.line([(vf_margin, vf_margin), (vf_margin, vf_margin + vf_len)], fill=vf_color, width=vf_width)
    # Top-Right
    vf_draw.line([(size - vf_margin, vf_margin), (size - vf_margin - vf_len, vf_margin)], fill=vf_color, width=vf_width)
    vf_draw.line([(size - vf_margin, vf_margin), (size - vf_margin, vf_margin + vf_len)], fill=vf_color, width=vf_width)
    # Bottom-Left
    vf_draw.line([(vf_margin, size - vf_margin), (vf_margin + vf_len, size - vf_margin)], fill=vf_color, width=vf_width)
    vf_draw.line([(vf_margin, size - vf_margin), (vf_margin, size - vf_margin - vf_len)], fill=vf_color, width=vf_width)
    # Bottom-Right
    vf_draw.line([(size - vf_margin, size - vf_margin), (size - vf_margin - vf_len, size - vf_margin)], fill=vf_color, width=vf_width)
    vf_draw.line([(size - vf_margin, size - vf_margin), (size - vf_margin, size - vf_margin - vf_len)], fill=vf_color, width=vf_width)
    
    return img

def create_adaptive_background(size=432):
    """Creates the deep dark metallic/indigo adaptive background."""
    bg = Image.new("RGBA", (size, size), (22, 23, 30, 255))
    draw = ImageDraw.Draw(bg)
    center = size // 2
    for r in range(size // 2, 0, -3):
        t = r / (size // 2)
        alpha = int(255 * (1 - t * 0.45))
        draw.ellipse([center - r, center - r, center + r, center + r], fill=(28, 30, 44, alpha))
    return bg

def create_adaptive_monochrome(size=432):
    """Creates white silhouette on transparent for Android Material You themed icons."""
    mono = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    center = size // 2
    emblem_r = int(size * 0.32)
    draw = ImageDraw.Draw(mono)
    draw.ellipse([center - emblem_r, center - emblem_r, center + emblem_r, center + emblem_r], outline=(255, 255, 255, 255), width=int(size * 0.02))
    inner_r = int(emblem_r * 0.5)
    draw.ellipse([center - inner_r, center - inner_r, center + inner_r, center + inner_r], fill=(255, 255, 255, 255))
    return mono

def main():
    adaptive_densities = {
        "mipmap-mdpi": 108,
        "mipmap-hdpi": 162,
        "mipmap-xhdpi": 216,
        "mipmap-xxhdpi": 324,
        "mipmap-xxxhdpi": 432,
    }
    
    legacy_densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    
    # 1. Master High-Res Icons
    master_fg = create_aperture_emblem(1024)
    master_bg = create_adaptive_background(1024)
    master_mono = create_adaptive_monochrome(1024)
    
    # Combined legacy master
    master_full = master_bg.copy()
    master_full.paste(master_fg, (0, 0), master_fg)
    
    # 2. Update Legacy ic_launcher.png
    for folder, dim in legacy_densities.items():
        resized = master_full.resize((dim, dim), Image.Resampling.LANCZOS)
        path = f"android/app/src/main/res/{folder}/ic_launcher.png"
        resized.save(path, "PNG")
        print(f"Updated legacy: {path} ({dim}x{dim})")
        
    # 3. Update Adaptive Icons: foreground, background, monochrome
    for folder, dim in adaptive_densities.items():
        fg_resized = master_fg.resize((dim, dim), Image.Resampling.LANCZOS)
        fg_path = f"android/app/src/main/res/{folder}/ic_launcher_foreground.png"
        fg_resized.save(fg_path, "PNG")
        
        bg_resized = master_bg.resize((dim, dim), Image.Resampling.LANCZOS)
        bg_path = f"android/app/src/main/res/{folder}/ic_launcher_background.png"
        bg_resized.save(bg_path, "PNG")
        
        mono_resized = master_mono.resize((dim, dim), Image.Resampling.LANCZOS)
        mono_path = f"android/app/src/main/res/{folder}/ic_launcher_monochrome.png"
        mono_resized.save(mono_path, "PNG")
        
        print(f"Updated adaptive: {folder} (FG, BG, Mono @ {dim}x{dim})")
        
    print("All Android launcher icons (Adaptive + Legacy) successfully updated!")

if __name__ == "__main__":
    main()
