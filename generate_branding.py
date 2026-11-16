import math
from PIL import Image, ImageDraw, ImageFilter

def create_artifex_icon(size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Outer background: Dark sleek metallic rounded square / circle
    # Radius
    corner_r = int(size * 0.22)
    # Gradient background
    bg_base = Image.new("RGBA", (size, size), (24, 25, 32, 255))
    bg_draw = ImageDraw.Draw(bg_base)
    
    # Radial dark glow from center
    center = size // 2
    for r in range(size // 2, 0, -4):
        alpha = int(255 * (1 - (r / (size // 2)) * 0.6))
        # Deep indigo dark gradient
        color = (28, 29, 45, alpha)
        bg_draw.ellipse([center - r, center - r, center + r, center + r], fill=color)
        
    # Mask to rounded rect
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=corner_r, fill=255)
    img.paste(bg_base, (0, 0), mask)
    
    # Draw glossy inner border
    border_draw = ImageDraw.Draw(img)
    border_draw.rounded_rectangle([4, 4, size - 4, size - 4], radius=corner_r, outline=(255, 255, 255, 35), width=int(size * 0.008))
    
    # Lens Outer Rim
    lens_r = int(size * 0.38)
    # Subtle drop shadow for lens
    shadow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow_layer)
    s_draw.ellipse([center - lens_r - 10, center - lens_r + 15, center + lens_r + 10, center + lens_r + 35], fill=(0, 0, 0, 160))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=int(size * 0.04)))
    img = Image.alpha_composite(img, shadow_layer)
    
    # Draw metallic camera bezel
    bezel_draw = ImageDraw.Draw(img)
    bezel_draw.ellipse([center - lens_r, center - lens_r, center + lens_r, center + lens_r], fill=(35, 38, 50, 255), outline=(0, 229, 255, 120), width=int(size * 0.012))
    
    inner_bezel_r = int(lens_r * 0.90)
    bezel_draw.ellipse([center - inner_bezel_r, center - inner_bezel_r, center + inner_bezel_r, center + inner_bezel_r], fill=(18, 19, 24, 255), outline=(255, 255, 255, 25), width=2)
    
    # Aperture / Prism Blades
    # We create 6 vibrant aperture blades
    blade_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(blade_layer)
    
    colors = [
        (0, 229, 255, 230),   # Cyan
        (64, 156, 255, 230),  # Blue
        (138, 43, 226, 230),  # Purple
        (236, 72, 153, 230),  # Magenta
        (249, 115, 22, 230),  # Orange
        (16, 185, 129, 230),  # Emerald
    ]
    
    blade_r = int(inner_bezel_r * 0.88)
    aperture_hole_r = int(blade_r * 0.32)
    num_blades = len(colors)
    
    for i, col in enumerate(colors):
        angle1 = math.radians(i * (360 / num_blades))
        angle2 = math.radians((i + 1.2) * (360 / num_blades))
        angle3 = math.radians((i + 0.6) * (360 / num_blades))
        
        # Points of blade polygon
        p1 = (center + int(blade_r * math.cos(angle1)), center + int(blade_r * math.sin(angle1)))
        p2 = (center + int(blade_r * math.cos(angle2)), center + int(blade_r * math.sin(angle2)))
        p3 = (center + int(aperture_hole_r * math.cos(angle3)), center + int(aperture_hole_r * math.sin(angle3)))
        
        b_draw.polygon([p1, p2, p3], fill=col)
        b_draw.line([p1, p2], fill=(255, 255, 255, 120), width=int(size * 0.006))
        b_draw.line([p2, p3], fill=(255, 255, 255, 60), width=int(size * 0.004))
        
    img = Image.alpha_composite(img, blade_layer)
    
    # Center aperture iris (dark void with colorful core)
    center_iris = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ci_draw = ImageDraw.Draw(center_iris)
    ci_draw.ellipse([center - aperture_hole_r, center - aperture_hole_r, center + aperture_hole_r, center + aperture_hole_r], fill=(12, 13, 17, 255), outline=(0, 229, 255, 200), width=int(size * 0.008))
    
    # Focal spark in the middle
    spark_r = int(aperture_hole_r * 0.45)
    ci_draw.ellipse([center - spark_r, center - spark_r, center + spark_r, center + spark_r], fill=(0, 229, 255, 220))
    
    spark_glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sg_draw = ImageDraw.Draw(spark_glow)
    sg_draw.ellipse([center - spark_r * 2, center - spark_r * 2, center + spark_r * 2, center + spark_r * 2], fill=(0, 229, 255, 120))
    spark_glow = spark_glow.filter(ImageFilter.GaussianBlur(radius=int(size * 0.02)))
    
    img = Image.alpha_composite(img, spark_glow)
    img = Image.alpha_composite(img, center_iris)
    
    # Glass reflection sweep over the lens (45 deg angle)
    glass_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    g_draw = ImageDraw.Draw(glass_layer)
    # Semi-transparent arc/ellipse highlight
    g_draw.arc([center - lens_r + 20, center - lens_r + 15, center + lens_r - 20, center + lens_r - 15], start=210, end=330, fill=(255, 255, 255, 140), width=int(size * 0.02))
    img = Image.alpha_composite(img, glass_layer)
    
    # Corner focus marks (like viewfinder)
    vf_draw = ImageDraw.Draw(img)
    vf_color = (0, 229, 255, 180)
    vf_len = int(size * 0.07)
    vf_margin = int(size * 0.12)
    vf_width = int(size * 0.007)
    
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

def main():
    icon_1024 = create_artifex_icon(1024)
    icon_1024.save("assets/artifex_icon_1024.png", "PNG")
    
    icon_512 = icon_1024.resize((512, 512), Image.Resampling.LANCZOS)
    icon_512.save("assets/artifex_icon_512.png", "PNG")
    icon_512.save("assets/ai_image.png", "PNG") # Also update in-app asset
    
    # Generate Android launcher icons
    mipmaps = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    
    for folder, dim in mipmaps.items():
        resized = icon_1024.resize((dim, dim), Image.Resampling.LANCZOS)
        path = f"android/app/src/main/res/{folder}/ic_launcher.png"
        resized.save(path, "PNG")
        print(f"Saved {path} ({dim}x{dim})")
        
    # Create Feature Graphic Banner (1024 x 500)
    banner = Image.new("RGBA", (1024, 500), (18, 19, 25, 255))
    b_draw = ImageDraw.Draw(banner)
    
    # Gradient backdrop
    for x in range(1024):
        t = x / 1024.0
        # Dark purple to deep cyan
        r = int(18 + 20 * (1 - t))
        g = int(19 + 25 * t)
        b = int(25 + 45 * t)
        b_draw.line([(x, 0), (x, 500)], fill=(r, g, b, 255))
        
    # Place icon on the right side
    icon_sub = icon_1024.resize((380, 380), Image.Resampling.LANCZOS)
    banner.paste(icon_sub, (600, 60), icon_sub)
    
    # Save banner
    banner.save("assets/artifex_studio_banner.png", "PNG")
    print("Artifex Photo Studio branding generated successfully!")

if __name__ == "__main__":
    main()
