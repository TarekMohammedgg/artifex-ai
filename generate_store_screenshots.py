import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance

# Constants
WIDTH = 1080
HEIGHT = 2400
OUT_DIR = "assets/store_listing/screenshots"

# System Fonts
FONT_TITLE = "C:/Windows/Fonts/segoeuib.ttf"
FONT_BODY = "C:/Windows/Fonts/segoeui.ttf"
FONT_CODE = "C:/Windows/Fonts/consola.ttf"

def get_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        return ImageFont.load_default()

def create_vertical_gradient(w, h, color1, color2):
    base = Image.new("RGBA", (w, h), color1)
    top_r, top_g, top_b = color1[:3]
    bot_r, bot_g, bot_b = color2[:3]
    
    gradient = Image.new("L", (1, h))
    for y in range(h):
        gradient.putpixel((0, y), int(255 * (y / h)))
    gradient = gradient.resize((w, h))
    
    bot_img = Image.new("RGBA", (w, h), color2)
    base = Image.composite(bot_img, base, gradient)
    return base

def draw_glow(base_img, center_x, center_y, radius, color):
    glow_layer = Image.new("RGBA", (radius * 2, radius * 2), (0, 0, 0, 0))
    g_draw = ImageDraw.Draw(glow_layer)
    for r in range(radius, 0, -4):
        alpha = int(color[3] * (1 - (r / radius) ** 1.5))
        c = (color[0], color[1], color[2], alpha)
        g_draw.ellipse([radius - r, radius - r, radius + r, radius + r], fill=c)
    
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=8))
    base_img.alpha_composite(glow_layer, (center_x - radius, center_y - radius))

def draw_rounded_rect(draw, bbox, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(bbox, radius=radius, fill=fill, outline=outline, width=width)

def draw_phone_frame(screen_content):
    """
    Renders screen_content (width: 820, height: 1680) inside a sleek phone bezel
    """
    frame_w = 840
    frame_h = 1700
    bezel = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(bezel)
    
    # Outer dark chassis
    draw_rounded_rect(b_draw, [0, 0, frame_w, frame_h], radius=68, fill=(28, 30, 40, 255), outline=(255, 255, 255, 40), width=4)
    # Inner rim
    draw_rounded_rect(b_draw, [6, 6, frame_w - 6, frame_h - 6], radius=62, fill=(15, 17, 24, 255), outline=(0, 229, 255, 80), width=2)
    
    # Paste screen content inside
    content_resized = screen_content.resize((808, 1668))
    # Mask content with rounded corners
    content_mask = Image.new("L", (808, 1668), 0)
    m_draw = ImageDraw.Draw(content_mask)
    m_draw.rounded_rectangle([0, 0, 808, 1668], radius=56, fill=255)
    
    bezel.paste(content_resized, (16, 16), content_mask)
    
    # Add punch hole camera
    cam_x = frame_w // 2
    cam_y = 42
    b_draw.ellipse([cam_x - 12, cam_y - 12, cam_x + 12, cam_y + 12], fill=(8, 8, 12, 255), outline=(40, 40, 55, 255), width=2)
    b_draw.ellipse([cam_x - 4, cam_y - 4, cam_x + 4, cam_y + 4], fill=(20, 25, 45, 255))
    
    # Glass reflection highlight on chassis
    highlight = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
    h_draw = ImageDraw.Draw(highlight)
    h_draw.rounded_rectangle([2, 2, frame_w - 2, frame_h // 2], radius=66, outline=(255, 255, 255, 30), width=2)
    bezel = Image.alpha_composite(bezel, highlight)
    
    return bezel

def render_status_bar(w=808):
    bar = Image.new("RGBA", (w, 60), (0, 0, 0, 0))
    draw = ImageDraw.Draw(bar)
    font = get_font(FONT_TITLE, 22)
    draw.text((45, 18), "9:41", font=font, fill=(255, 255, 255, 230))
    
    # Battery & wifi indicators
    bx = w - 85
    by = 22
    draw.rounded_rectangle([bx, by, bx + 40, by + 20], radius=4, outline=(255, 255, 255, 200), width=2)
    draw.rounded_rectangle([bx + 4, by + 4, bx + 28, by + 16], radius=2, fill=(0, 229, 255, 220))
    draw.rectangle([bx + 41, by + 6, bx + 44, by + 14], fill=(255, 255, 255, 180))
    return bar

# Screen Content Generators
def make_screen_home():
    screen = Image.new("RGBA", (808, 1668), (14, 16, 24, 255))
    draw = ImageDraw.Draw(screen)
    screen.paste(render_status_bar(), (0, 0), render_status_bar())
    
    # App Bar
    logo = Image.open("assets/artifex_icon_512.png").convert("RGBA").resize((70, 70))
    logo_mask = Image.new("L", (70, 70), 0)
    ImageDraw.Draw(logo_mask).rounded_rectangle([0, 0, 70, 70], radius=18, fill=255)
    screen.paste(logo, (35, 80), logo_mask)
    
    f_brand = get_font(FONT_TITLE, 36)
    f_sub = get_font(FONT_BODY, 20)
    draw.text((120, 82), "Artifex", font=f_brand, fill=(255, 255, 255, 255))
    draw.text((122, 122), "PHOTO STUDIO", font=f_sub, fill=(0, 229, 255, 240))
    
    # Hero Card (Studio Quick Launch)
    hero_w = 738
    hero_h = 420
    hero_card = create_vertical_gradient(hero_w, hero_h, (18, 55, 95, 255), (10, 28, 55, 255))
    h_draw = ImageDraw.Draw(hero_card)
    draw_rounded_rect(h_draw, [0, 0, hero_w, hero_h], radius=32, fill=None, outline=(0, 229, 255, 100), width=2)
    
    # Inner banner art
    if os.path.exists("assets/artifex_studio_banner.png"):
        banner = Image.open("assets/artifex_studio_banner.png").convert("RGBA").resize((hero_w - 4, hero_h - 4))
        b_mask = Image.new("L", (hero_w - 4, hero_h - 4), 0)
        ImageDraw.Draw(b_mask).rounded_rectangle([0, 0, hero_w - 4, hero_h - 4], radius=30, fill=255)
        hero_card.paste(banner, (2, 2), b_mask)
    
    # Text overlay on hero
    h_overlay = ImageDraw.Draw(hero_card)
    f_ht = get_font(FONT_TITLE, 38)
    f_hs = get_font(FONT_BODY, 22)
    h_overlay.text((36, hero_h - 110), "Pro Photo Studio", font=f_ht, fill=(255, 255, 255, 255))
    h_overlay.text((36, hero_h - 60), "Start Editing • AI Filters • Bokeh", font=f_hs, fill=(0, 229, 255, 220))
    
    screen.paste(hero_card, (35, 180))
    
    # Features Section Title
    f_sec = get_font(FONT_TITLE, 28)
    draw.text((38, 640), "CREATIVE TOOLS", font=f_sec, fill=(255, 255, 255, 220))
    
    # Grid of Feature Tiles
    features = [
        ("AI Remove BG", "Cut out subjects", (0, 229, 255, 40), (0, 229, 255, 255)),
        ("Photo Filters", "20+ Color styles", (124, 77, 255, 40), (124, 77, 255, 255)),
        ("Bokeh & Blur", "Selective depth", (255, 82, 82, 40), (255, 82, 82, 255)),
        ("OCR Scanner", "Extract text", (255, 179, 0, 40), (255, 179, 0, 255)),
        ("Typography", "Fonts & captions", (0, 230, 118, 40), (0, 230, 118, 255)),
        ("Smart Cropper", "Custom aspect", (68, 138, 255, 40), (68, 138, 255, 255)),
    ]
    
    tile_w = 352
    tile_h = 160
    f_tf = get_font(FONT_TITLE, 24)
    f_ts = get_font(FONT_BODY, 18)
    
    for idx, (title, sub, bg_tint, accent) in enumerate(features):
        r = idx // 2
        c = idx % 2
        x = 35 + c * (tile_w + 34)
        y = 700 + r * (tile_h + 24)
        
        tile = Image.new("RGBA", (tile_w, tile_h), (24, 28, 40, 255))
        td = ImageDraw.Draw(tile)
        draw_rounded_rect(td, [0, 0, tile_w, tile_h], radius=24, fill=(25, 29, 42, 255), outline=accent, width=2)
        draw_rounded_rect(td, [16, 16, 56, 56], radius=14, fill=bg_tint, outline=accent, width=1)
        
        td.text((70, 24), title, font=f_tf, fill=(255, 255, 255, 255))
        td.text((70, 58), sub, font=f_ts, fill=(180, 190, 210, 220))
        
        screen.paste(tile, (x, y))
        
    # Floating Action Bar at Bottom
    cta_w = 738
    cta_h = 90
    cta = Image.new("RGBA", (cta_w, cta_h), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cta)
    draw_rounded_rect(cd, [0, 0, cta_w, cta_h], radius=45, fill=(0, 229, 255, 255))
    f_cta = get_font(FONT_TITLE, 30)
    cd.text((cta_w // 2 - 130, 25), "✦ SELECT A PHOTO", font=f_cta, fill=(10, 15, 25, 255))
    screen.paste(cta, (35, 1480), cta)
    
    return screen

def make_screen_remove_bg():
    screen = Image.new("RGBA", (808, 1668), (14, 16, 24, 255))
    draw = ImageDraw.Draw(screen)
    screen.paste(render_status_bar(), (0, 0), render_status_bar())
    
    # App Bar
    f_t = get_font(FONT_TITLE, 32)
    draw.text((45, 90), "←  AI Background Removal", font=f_t, fill=(255, 255, 255, 255))
    
    # Image Display Box with split before/after
    box_w = 738
    box_h = 960
    box_x = 35
    box_y = 160
    
    # Checkerboard background (transparency indicator)
    checker = Image.new("RGBA", (box_w, box_h), (25, 28, 38, 255))
    cd = ImageDraw.Draw(checker)
    sq = 32
    for cx in range(0, box_w, sq):
        for cy in range(0, box_h, sq):
            if ((cx // sq) + (cy // sq)) % 2 == 0:
                cd.rectangle([cx, cy, cx + sq, cy + sq], fill=(35, 40, 54, 255))
    
    # Subject image
    subj = Image.open("assets/normal_image.png").convert("RGBA")
    subj = subj.resize((box_w, box_h))
    
    # Split: Left half original photo, right half transparent cutout
    split_pos = int(box_w * 0.48)
    cutout = subj.copy()
    
    # Paste checkerboard on right side
    subj.paste(checker.crop((split_pos, 0, box_w, box_h)), (split_pos, 0))
    # Paste subject back on right side using alpha or simulated cutout
    # Draw vertical divider line
    sd = ImageDraw.Draw(subj)
    sd.line([(split_pos, 0), (split_pos, box_h)], fill=(0, 229, 255, 255), width=4)
    # Circle knob
    sd.ellipse([split_pos - 24, box_h // 2 - 24, split_pos + 24, box_h // 2 + 24], fill=(0, 229, 255, 255), outline=(255, 255, 255, 255), width=3)
    
    # Labels
    f_tag = get_font(FONT_TITLE, 24)
    sd.text((30, 30), "BEFORE", font=f_tag, fill=(255, 255, 255, 230))
    sd.text((box_w - 140, 30), "AFTER", font=f_tag, fill=(0, 229, 255, 240))
    
    # Mask to rounded box
    box_mask = Image.new("L", (box_w, box_h), 0)
    ImageDraw.Draw(box_mask).rounded_rectangle([0, 0, box_w, box_h], radius=32, fill=255)
    screen.paste(subj, (box_x, box_y), box_mask)
    draw_rounded_rect(draw, [box_x, box_y, box_x + box_w, box_y + box_h], radius=32, fill=None, outline=(0, 229, 255, 120), width=2)
    
    # Badge: High Precision AI
    draw_rounded_rect(draw, [60, 1160, 748, 1270], radius=24, fill=(22, 26, 38, 255), outline=(0, 229, 255, 80), width=1)
    f_bt = get_font(FONT_TITLE, 26)
    f_bs = get_font(FONT_BODY, 20)
    draw.text((95, 1180), "Instant AI Cutout Engine", font=f_bt, fill=(255, 255, 255, 255))
    draw.text((95, 1220), "Leaves crisp edges on hair, pets & intricate products", font=f_bs, fill=(160, 175, 200, 220))
    
    # Action Buttons
    btn_w = 345
    btn_h = 80
    draw_rounded_rect(draw, [45, 1340, 45 + btn_w, 1340 + btn_h], radius=40, fill=(30, 36, 52, 255), outline=(255, 255, 255, 80), width=2)
    f_btn = get_font(FONT_TITLE, 26)
    draw.text((115, 1365), "Replace BG", font=f_btn, fill=(255, 255, 255, 230))
    
    draw_rounded_rect(draw, [418, 1340, 418 + btn_w, 1340 + btn_h], radius=40, fill=(0, 229, 255, 255))
    draw.text((485, 1365), "Save Transparent", font=f_btn, fill=(12, 18, 28, 255))
    
    return screen

def make_screen_filters():
    screen = Image.new("RGBA", (808, 1668), (14, 16, 24, 255))
    draw = ImageDraw.Draw(screen)
    screen.paste(render_status_bar(), (0, 0), render_status_bar())
    
    # App Bar
    f_t = get_font(FONT_TITLE, 32)
    draw.text((45, 90), "←  Creative Photo Filters", font=f_t, fill=(255, 255, 255, 255))
    
    # Main Filtered Photo
    box_w = 738
    box_h = 880
    box_x = 35
    box_y = 160
    
    photo = Image.open("assets/normal_image.png").convert("RGBA").resize((box_w, box_h))
    # Apply warm vibrant cyberpunk tone
    enhancer = ImageEnhance.Color(photo)
    photo = enhancer.enhance(1.6)
    contrast = ImageEnhance.Contrast(photo)
    photo = contrast.enhance(1.25)
    
    box_mask = Image.new("L", (box_w, box_h), 0)
    ImageDraw.Draw(box_mask).rounded_rectangle([0, 0, box_w, box_h], radius=32, fill=255)
    screen.paste(photo, (box_x, box_y), box_mask)
    draw_rounded_rect(draw, [box_x, box_y, box_x + box_w, box_y + box_h], radius=32, fill=None, outline=(124, 77, 255, 120), width=2)
    
    # Filter Intensity Slider
    draw_rounded_rect(draw, [55, 1080, 753, 1160], radius=20, fill=(22, 26, 38, 255))
    f_lbl = get_font(FONT_TITLE, 22)
    draw.text((80, 1105), "Intensity", font=f_lbl, fill=(255, 255, 255, 220))
    # Slider line
    draw.rounded_rectangle([200, 1115, 660, 1125], radius=5, fill=(45, 52, 75, 255))
    draw.rounded_rectangle([200, 1115, 560, 1125], radius=5, fill=(124, 77, 255, 255))
    draw.ellipse([550, 1105, 574, 1135], fill=(255, 255, 255, 255))
    draw.text((680, 1105), "85%", font=f_lbl, fill=(124, 77, 255, 255))
    
    # Filter Presets Carousel
    presets = [
        ("Original", (80, 80, 90)),
        ("Cyberpunk", (124, 77, 255)),
        ("Vintage", (180, 130, 80)),
        ("Golden", (255, 180, 0)),
        ("Emerald", (0, 200, 120)),
    ]
    
    pw = 135
    ph = 180
    f_pname = get_font(FONT_BODY, 18)
    for i, (name, col) in enumerate(presets):
        px = 45 + i * (pw + 16)
        py = 1200
        # Thumbnail
        draw_rounded_rect(draw, [px, py, px + pw, py + ph], radius=20, fill=(25, 29, 42, 255), outline=col if i==1 else (50, 56, 75, 255), width=3 if i==1 else 1)
        draw.rounded_rectangle([px + 10, py + 10, px + pw - 10, py + 120], radius=14, fill=col)
        draw.text((px + 20, py + 138), name, font=f_pname, fill=(255, 255, 255, 255) if i==1 else (160, 170, 190, 220))
        
    # Export Button
    cta_w = 738
    cta_h = 80
    draw_rounded_rect(draw, [35, 1440, 35 + cta_w, 1440 + cta_h], radius=40, fill=(124, 77, 255, 255))
    f_cta = get_font(FONT_TITLE, 28)
    draw.text((cta_w // 2 - 80, 1465), "APPLY FILTER", font=f_cta, fill=(255, 255, 255, 255))
    
    return screen

def make_screen_blur():
    screen = Image.new("RGBA", (808, 1668), (14, 16, 24, 255))
    draw = ImageDraw.Draw(screen)
    screen.paste(render_status_bar(), (0, 0), render_status_bar())
    
    f_t = get_font(FONT_TITLE, 32)
    draw.text((45, 90), "←  Selective Blur & Bokeh", font=f_t, fill=(255, 255, 255, 255))
    
    box_w = 738
    box_h = 920
    box_x = 35
    box_y = 160
    
    # Background blurred
    base_img = Image.open("assets/normal_image.png").convert("RGBA").resize((box_w, box_h))
    blurred = base_img.filter(ImageFilter.GaussianBlur(radius=18))
    
    # Center focused circle
    focus_r = 180
    fc_x = box_w // 2
    fc_y = box_h // 2
    
    mask = Image.new("L", (box_w, box_h), 0)
    md = ImageDraw.Draw(mask)
    # Radial falloff
    for r in range(focus_r + 40, focus_r - 20, -2):
        val = int(255 * (1 - (r - (focus_r - 20)) / 60))
        md.ellipse([fc_x - r, fc_y - r, fc_x + r, fc_y + r], fill=val)
    md.ellipse([fc_x - (focus_r - 20), fc_y - (focus_r - 20), fc_x + (focus_r - 20), fc_y + (focus_r - 20)], fill=255)
    
    composed = Image.composite(base_img, blurred, mask)
    
    # Draw focus reticle
    cd = ImageDraw.Draw(composed)
    cd.ellipse([fc_x - focus_r, fc_y - focus_r, fc_x + focus_r, fc_y + focus_r], outline=(255, 82, 82, 220), width=3)
    cd.line([(fc_x - 30, fc_y), (fc_x + 30, fc_y)], fill=(255, 82, 82, 240), width=2)
    cd.line([(fc_x, fc_y - 30), (fc_x, fc_y + 30)], fill=(255, 82, 82, 240), width=2)
    
    box_mask = Image.new("L", (box_w, box_h), 0)
    ImageDraw.Draw(box_mask).rounded_rectangle([0, 0, box_w, box_h], radius=32, fill=255)
    screen.paste(composed, (box_x, box_y), box_mask)
    draw_rounded_rect(draw, [box_x, box_y, box_x + box_w, box_y + box_h], radius=32, fill=None, outline=(255, 82, 82, 120), width=2)
    
    # Mode Selector Tabs
    tabs = ["Radial Focus", "Linear Tilt-Shift", "Gaussian"]
    tw = 230
    for idx, name in enumerate(tabs):
        tx = 45 + idx * (tw + 18)
        ty = 1120
        is_sel = idx == 0
        draw_rounded_rect(draw, [tx, ty, tx + tw, ty + 65], radius=18, fill=(255, 82, 82, 255) if is_sel else (25, 29, 42, 255))
        f_tab = get_font(FONT_TITLE if is_sel else FONT_BODY, 20)
        draw.text((tx + 30, ty + 20), name, font=f_tab, fill=(255, 255, 255, 255) if is_sel else (160, 175, 200, 220))
        
    # Radius & Smoothness Sliders
    draw_rounded_rect(draw, [45, 1220, 763, 1340], radius=24, fill=(22, 26, 38, 255))
    f_l = get_font(FONT_BODY, 22)
    draw.text((70, 1245), "Aperture Radius", font=f_l, fill=(255, 255, 255, 220))
    draw.rounded_rectangle([250, 1255, 680, 1265], radius=5, fill=(45, 52, 75, 255))
    draw.rounded_rectangle([250, 1255, 520, 1265], radius=5, fill=(255, 82, 82, 255))
    draw.ellipse([510, 1245, 532, 1275], fill=(255, 255, 255, 255))
    
    draw.text((70, 1290), "Blur Depth", font=f_l, fill=(255, 255, 255, 220))
    draw.rounded_rectangle([250, 1300, 680, 1310], radius=5, fill=(45, 52, 75, 255))
    draw.rounded_rectangle([250, 1300, 590, 1310], radius=5, fill=(255, 82, 82, 255))
    draw.ellipse([580, 1290, 602, 1320], fill=(255, 255, 255, 255))
    
    # Save button
    draw_rounded_rect(draw, [45, 1440, 763, 1525], radius=40, fill=(255, 82, 82, 255))
    f_cta = get_font(FONT_TITLE, 28)
    draw.text((280, 1465), "SAVE PORTRAIT", font=f_cta, fill=(255, 255, 255, 255))
    
    return screen

def make_screen_ocr():
    screen = Image.new("RGBA", (808, 1668), (14, 16, 24, 255))
    draw = ImageDraw.Draw(screen)
    screen.paste(render_status_bar(), (0, 0), render_status_bar())
    
    f_t = get_font(FONT_TITLE, 32)
    draw.text((45, 90), "←  Smart OCR Text Scanner", font=f_t, fill=(255, 255, 255, 255))
    
    # Image with OCR boxes
    box_w = 738
    box_h = 780
    box_x = 35
    box_y = 160
    
    doc = Image.open("assets/normal_image.png").convert("RGBA").resize((box_w, box_h))
    dd = ImageDraw.Draw(doc)
    # Highlight recognized bounding boxes
    rects = [
        ([80, 120, 480, 180], "ARTIFEX STUDIO"),
        ([80, 220, 650, 270], "CREATIVE PHOTOGRAPHY SYSTEM"),
        ([80, 310, 520, 355], "EXTRACT TEXT IN SECONDS"),
    ]
    for b, txt in rects:
        dd.rectangle(b, outline=(255, 179, 0, 255), width=3)
        dd.rectangle([b[0], b[1] - 30, b[0] + 160, b[1]], fill=(255, 179, 0, 230))
        dd.text((b[0] + 10, b[1] - 26), "Recognized", font=get_font(FONT_TITLE, 16), fill=(10, 10, 15, 255))
        
    box_mask = Image.new("L", (box_w, box_h), 0)
    ImageDraw.Draw(box_mask).rounded_rectangle([0, 0, box_w, box_h], radius=32, fill=255)
    screen.paste(doc, (box_x, box_y), box_mask)
    draw_rounded_rect(draw, [box_x, box_y, box_x + box_w, box_y + box_h], radius=32, fill=None, outline=(255, 179, 0, 120), width=2)
    
    # Extracted Text Card
    card_w = 738
    card_h = 380
    draw_rounded_rect(draw, [35, 980, 35 + card_w, 980 + card_h], radius=28, fill=(24, 28, 40, 255), outline=(255, 179, 0, 100), width=1)
    
    f_ct = get_font(FONT_TITLE, 24)
    draw.text((65, 1010), "Extracted Content (3 blocks found)", font=f_ct, fill=(255, 179, 0, 255))
    
    # Text box
    draw_rounded_rect(draw, [65, 1060, 35 + card_w - 30, 1260], radius=16, fill=(16, 18, 26, 255))
    f_body = get_font(FONT_BODY, 22)
    lines = [
        "\"ARTIFEX STUDIO\"",
        "CREATIVE PHOTOGRAPHY SYSTEM",
        "EXTRACT TEXT IN SECONDS"
    ]
    for idx, l in enumerate(lines):
        draw.text((90, 1090 + idx * 45), l, font=f_body, fill=(240, 245, 255, 240))
        
    # Copy & Share buttons
    draw_rounded_rect(draw, [35, 1400, 385, 1490], radius=45, fill=(35, 40, 58, 255), outline=(255, 179, 0, 120), width=2)
    f_btn = get_font(FONT_TITLE, 26)
    draw.text((140, 1430), "Copy Text", font=f_btn, fill=(255, 179, 0, 255))
    
    draw_rounded_rect(draw, [415, 1400, 773, 1490], radius=45, fill=(255, 179, 0, 255))
    draw.text((530, 1430), "Share", font=f_btn, fill=(15, 18, 26, 255))
    
    return screen

def make_screen_typography():
    screen = Image.new("RGBA", (808, 1668), (14, 16, 24, 255))
    draw = ImageDraw.Draw(screen)
    screen.paste(render_status_bar(), (0, 0), render_status_bar())
    
    f_t = get_font(FONT_TITLE, 32)
    draw.text((45, 90), "←  Custom Typography & Text", font=f_t, fill=(255, 255, 255, 255))
    
    box_w = 738
    box_h = 920
    box_x = 35
    box_y = 160
    
    bg = Image.open("assets/normal_image.png").convert("RGBA").resize((box_w, box_h))
    # Dim slightly for high readability
    darkener = ImageEnhance.Brightness(bg)
    bg = darkener.enhance(0.7)
    
    bd = ImageDraw.Draw(bg)
    # Aesthetic typography quotes
    f_quote = get_font(FONT_TITLE, 52)
    f_sub = get_font(FONT_BODY, 28)
    
    bd.text((box_w // 2 - 220, box_h // 2 - 80), "LIVE IN THE", font=f_sub, fill=(0, 229, 255, 240))
    bd.text((box_w // 2 - 220, box_h // 2 - 30), "MOMENT", font=f_quote, fill=(255, 255, 255, 255))
    bd.line([(box_w // 2 - 220, box_h // 2 + 50), (box_w // 2 + 120, box_h // 2 + 50)], fill=(0, 229, 255, 255), width=4)
    bd.text((box_w // 2 - 220, box_h // 2 + 70), "Shot on Artifex Camera", font=f_sub, fill=(200, 210, 230, 200))
    
    box_mask = Image.new("L", (box_w, box_h), 0)
    ImageDraw.Draw(box_mask).rounded_rectangle([0, 0, box_w, box_h], radius=32, fill=255)
    screen.paste(bg, (box_x, box_y), box_mask)
    draw_rounded_rect(draw, [box_x, box_y, box_x + box_w, box_y + box_h], radius=32, fill=None, outline=(0, 230, 118, 120), width=2)
    
    # Text styling bar: Color swatches
    draw_rounded_rect(draw, [45, 1120, 763, 1210], radius=24, fill=(22, 26, 38, 255))
    f_cl = get_font(FONT_BODY, 20)
    draw.text((70, 1150), "Font Color", font=f_cl, fill=(255, 255, 255, 220))
    colors = [(255, 255, 255), (0, 229, 255), (255, 82, 82), (255, 179, 0), (0, 230, 118), (124, 77, 255)]
    for idx, c in enumerate(colors):
        cx = 240 + idx * 80
        draw.ellipse([cx, 1140, cx + 46, 1186], fill=c, outline=(255, 255, 255, 255) if idx==1 else None, width=3)
        
    # Font Style selector
    fonts_sample = ["Modern Bold", "Elegant Script", "Cyber Mono", "Classic Serif"]
    fw = 160
    for idx, fn in enumerate(fonts_sample):
        fx = 45 + idx * (fw + 20)
        fy = 1240
        is_sel = idx == 0
        draw_rounded_rect(draw, [fx, fy, fx + fw, fy + 70], radius=16, fill=(0, 230, 118, 255) if is_sel else (25, 29, 42, 255))
        draw.text((fx + 18, fy + 22), fn[:8], font=get_font(FONT_TITLE if is_sel else FONT_BODY, 18), fill=(10, 20, 15, 255) if is_sel else (200, 210, 230, 220))
        
    # Action buttons
    draw_rounded_rect(draw, [45, 1420, 763, 1505], radius=40, fill=(0, 230, 118, 255))
    f_cta = get_font(FONT_TITLE, 28)
    draw.text((280, 1445), "EXPORT IN HD", font=f_cta, fill=(10, 25, 15, 255))
    
    return screen

# Main Screenshot Composition
def build_playstore_screenshot(idx, headline, subtitle, badge_txt, screen_content, accent_color):
    canvas = create_vertical_gradient(WIDTH, HEIGHT, (12, 14, 22, 255), (18, 22, 34, 255))
    draw = ImageDraw.Draw(canvas)
    
    # Ambient glowing light behind top and center
    draw_glow(canvas, WIDTH // 2, 850, 480, (accent_color[0], accent_color[1], accent_color[2], 55))
    draw_glow(canvas, WIDTH // 2, 250, 280, (accent_color[0], accent_color[1], accent_color[2], 40))
    
    # Category tag pill at top
    tag_w = 260
    tag_h = 54
    draw_rounded_rect(draw, [(WIDTH - tag_w) // 2, 100, (WIDTH + tag_w) // 2, 100 + tag_h], radius=27, fill=(28, 34, 52, 220), outline=accent_color, width=2)
    f_tag = get_font(FONT_TITLE, 22)
    draw.text(((WIDTH - tag_w) // 2 + 35, 114), badge_txt, font=f_tag, fill=accent_color)
    
    # Main Headline
    f_hl = get_font(FONT_TITLE, 56)
    # Measure text
    bbox = draw.textbbox((0, 0), headline, font=f_hl)
    tw = bbox[2] - bbox[0]
    draw.text(((WIDTH - tw) // 2, 185), headline, font=f_hl, fill=(255, 255, 255, 255))
    
    # Subtitle
    f_sub = get_font(FONT_BODY, 28)
    bbox_s = draw.textbbox((0, 0), subtitle, font=f_sub)
    tsw = bbox_s[2] - bbox_s[0]
    draw.text(((WIDTH - tsw) // 2, 265), subtitle, font=f_sub, fill=(185, 195, 215, 220))
    
    # Render phone chassis
    phone = draw_phone_frame(screen_content)
    
    # Floating shadow under phone
    shadow = Image.new("RGBA", (880, 120), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([40, 20, 840, 100], fill=(0, 0, 0, 180))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=24))
    canvas.alpha_composite(shadow, ((WIDTH - 880) // 2, HEIGHT - 140))
    
    # Paste phone onto canvas
    phone_x = (WIDTH - phone.width) // 2
    phone_y = 350
    canvas.paste(phone, (phone_x, phone_y), phone)
    
    # Save file
    out_file = os.path.join(OUT_DIR, f"screenshot_{idx}.png")
    canvas.save(out_file, "PNG", optimize=True)
    print(f"Generated: {out_file} ({WIDTH}x{HEIGHT})")

def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    
    configs = [
        (1, "ALL-IN-ONE STUDIO", "Enhance, Crop & Transform Your Photos", "ARTIFEX PRO", make_screen_home(), (0, 229, 255)),
        (2, "AI CUTOUT ENGINE", "Remove Backgrounds with 1-Tap Precision", "AI CUTOUT", make_screen_remove_bg(), (0, 229, 255)),
        (3, "CREATIVE FILTERS", "20+ Dynamic Color Grades & Presets", "PRO FILTERS", make_screen_filters(), (124, 77, 255)),
        (4, "CINEMATIC BOKEH", "Selective Radial, Linear & Studio Depth", "PORTRAIT MODE", make_screen_blur(), (255, 82, 82)),
        (5, "SMART OCR SCANNER", "Extract, Copy & Share Text Instantly", "ON-DEVICE ML", make_screen_ocr(), (255, 179, 0)),
        (6, "CUSTOM TYPOGRAPHY", "Add Beautiful Quotes, Fonts & Colors", "TYPOGRAPHY", make_screen_typography(), (0, 230, 118)),
    ]
    
    for idx, hl, sub, badge, scr, color in configs:
        build_playstore_screenshot(idx, hl, sub, badge, scr, color)

if __name__ == "__main__":
    main()
