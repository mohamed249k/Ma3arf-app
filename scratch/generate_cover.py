import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import arabic_reshaper
from bidi.algorithm import get_display

# Arabic Reshaper configuration: clean presentation forms without problematic ligatures
config = {
    'delete_harakat': True,
    'support_ligatures': False
}
reshaper = arabic_reshaper.ArabicReshaper(config)

def fix_ar(text):
    return get_display(reshaper.reshape(text))

# Target specs: 1024 x 500 (Google Play Store Feature Graphic)
W, H = 1024, 500
img = Image.new("RGBA", (W, H), (8, 20, 15, 255))
draw = ImageDraw.Draw(img)

# 1. Background Gradient (Deep Islamic Royal Emerald)
for y in range(H):
    for x in range(0, W, 4):
        # Radial focal distance: Left center (icon: 230, 250) and Right center (content: 720, 250)
        d1 = math.sqrt(((x - 230) / 380.0) ** 2 + ((y - 250) / 280.0) ** 2)
        d2 = math.sqrt(((x - 720) / 460.0) ** 2 + ((y - 250) / 280.0) ** 2)
        dist = min(d1, d2)
        dist = min(1.3, dist)
        
        factor = max(0.0, 1.0 - (dist / 1.3))
        # Deep emerald gradient
        r = int(7 + 14 * factor)
        g = int(17 + 45 * factor)
        b = int(13 + 32 * factor)
        draw.rectangle([x, y, x + 4, y + 1], fill=(r, g, b, 255))

# 2. Subtle Islamic Geometric Star Pattern
pattern_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
pdraw = ImageDraw.Draw(pattern_layer)

def draw_star(draw_ctx, cx, cy, r_out, r_in, fill_col, outline_col):
    pts = []
    for i in range(16):
        r = r_out if i % 2 == 0 else r_in
        ang = i * (math.pi / 8.0)
        px = cx + r * math.cos(ang)
        py = cy + r * math.sin(ang)
        pts.append((px, py))
    draw_ctx.polygon(pts, fill=fill_col, outline=outline_col)

for cx in range(-20, W + 100, 100):
    for cy in range(-20, H + 100, 100):
        draw_star(pdraw, cx, cy, 32, 18, (198, 161, 91, 10), (216, 189, 131, 20))
        pdraw.ellipse([cx - 3, cy - 3, cx + 3, cy + 3], fill=(198, 161, 91, 26))

img = Image.alpha_composite(img, pattern_layer)

# 3. Ambient Gold Glow Behind Icon
glow_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
gdraw = ImageDraw.Draw(glow_layer)
gdraw.ellipse([80, 90, 390, 410], fill=(215, 181, 109, 45))
glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(40))
img = Image.alpha_composite(img, glow_layer)

# 4. App Icon (x=110, y=125, size=250)
icon_path = "release/ma3arf-icon-512.png"
if os.path.exists(icon_path):
    app_icon = Image.open(icon_path).convert("RGBA")
    icon_size = 250
    app_icon = app_icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    
    icon_x = 105
    icon_y = (H - icon_size) // 2
    
    # Drop shadow
    shadow_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow_layer)
    sdraw.rounded_rectangle([icon_x - 8, icon_y - 4, icon_x + icon_size + 8, icon_y + icon_size + 16], radius=48, fill=(0, 0, 0, 160))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(14))
    img = Image.alpha_composite(img, shadow_layer)
    
    # Outer gold rim
    fdraw = ImageDraw.Draw(img)
    fdraw.rounded_rectangle([icon_x - 6, icon_y - 6, icon_x + icon_size + 6, icon_y + icon_size + 6], radius=46, outline=(215, 181, 109, 230), width=3)
    fdraw.rounded_rectangle([icon_x - 2, icon_y - 2, icon_x + icon_size + 2, icon_y + icon_size + 2], radius=40, outline=(198, 161, 91, 110), width=1)
    
    # Rounded corner mask for icon
    mask = Image.new("L", (icon_size, icon_size), 0)
    mdraw = ImageDraw.Draw(mask)
    mdraw.rounded_rectangle([0, 0, icon_size, icon_size], radius=38, fill=255)
    img.paste(app_icon, (icon_x, icon_y), mask)

# 5. Arabic & English Fonts (Using C:/Windows/Fonts/segoeuib.ttf)
font_title = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 66)
font_sub = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 24)
font_en = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 15)
font_badge = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 17)
font_credit = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 14)

draw = ImageDraw.Draw(img)

# Layout constants for right side
right_margin = W - 65

# A. Brand Title: مَعارِف
title_str = fix_ar("معارف")
# Shadow
draw.text((right_margin + 2, 60), title_str, font=font_title, fill=(5, 15, 10, 210), anchor="ra")
# Matte Gold Title
draw.text((right_margin, 58), title_str, font=font_title, fill=(215, 181, 109, 255), anchor="ra")

# B. English Brand Tagline: MA3ARF • ISLAMIC QUIZ APP
draw.text((430, 84), "MA3ARF  •  ISLAMIC QUIZ APP", font=font_en, fill=(185, 199, 189, 220))

# C. Subtitle: بنك المعرفة والعلوم الإسلامية
sub_str = fix_ar("بنك المعرفة والعلوم الإسلامية")
draw.text((right_margin, 146), sub_str, font=font_sub, fill=(244, 241, 232, 255), anchor="ra")

# D. Golden Divider Line with Diamond Center
div_left = 430
div_right = right_margin
div_y = 192
draw.line([(div_left, div_y), (div_right, div_y)], fill=(198, 161, 91, 130), width=2)
# Center Diamond Accent
mid_x = (div_left + div_right) // 2
draw.polygon([(mid_x, div_y - 5), (mid_x + 6, div_y), (mid_x, div_y + 5), (mid_x - 6, div_y)], fill=(215, 181, 109, 255))
draw.ellipse([(div_left - 3, div_y - 3), (div_left + 3, div_y + 3)], fill=(215, 181, 109, 220))
draw.ellipse([(div_right - 3, div_y - 3), (div_right + 3, div_y + 3)], fill=(215, 181, 109, 220))

# E. 3 Distinct Feature Badges
badges_data = [
    ("١,٠٠٠ سؤال موثق من الكتاب والسنة", 218),
    ("١٠ أقسام وتصنيفات شرعية شاملة", 272),
    ("يعمل ١٠٠٪ بدون إنترنت • صدقة جارية", 326),
]

pill_w = 485
pill_h = 40
for b_text, b_y in badges_data:
    pill_x2 = right_margin
    pill_x1 = pill_x2 - pill_w
    
    # Frosted Emerald Pill
    draw.rounded_rectangle([pill_x1, b_y, pill_x2, b_y + pill_h], radius=12, fill=(18, 44, 34, 215), outline=(46, 76, 62, 230), width=1)
    
    # Gold Diamond Bullet
    dia_x = pill_x2 - 18
    dia_y = b_y + (pill_h // 2)
    draw.polygon([(dia_x, dia_y - 5), (dia_x + 5, dia_y), (dia_x, dia_y + 5), (dia_x - 5, dia_y)], fill=(215, 181, 109, 255))
    
    # Badge Arabic Text
    b_ar = fix_ar(b_text)
    draw.text((pill_x2 - 34, b_y + 8), b_ar, font=font_badge, fill=(244, 241, 232, 245), anchor="ra")

# F. Luxury Outer Double Border
draw.rectangle([8, 8, W - 8, H - 8], outline=(198, 161, 91, 110), width=1)
draw.rectangle([12, 12, W - 12, H - 12], outline=(215, 181, 109, 55), width=1)

# Corner Diamond Ornaments
for cx, cy in [(8, 8), (W - 8, 8), (8, H - 8), (W - 8, H - 8)]:
    draw.rectangle([cx - 4, cy - 4, cx + 4, cy + 4], fill=(215, 181, 109, 200))

# G. Footer Attribution
footer_str = fix_ar("فكرة وإعداد وتطوير: محمد كرم (Mohamed Karam)")
draw.text((right_margin, 428), footer_str, font=font_credit, fill=(185, 199, 189, 200), anchor="ra")

# 6. Save in release/ directory
out_png = "release/ma3arf-feature-graphic.png"
out_cover = "release/ma3arf-cover-1024x500.png"
out_jpg = "release/ma3arf-feature-graphic.jpg"

img.save(out_png, "PNG")
img.save(out_cover, "PNG")

rgb_img = Image.new("RGB", (W, H), (8, 20, 15))
rgb_img.paste(img, (0, 0), img)
rgb_img.save(out_jpg, "JPEG", quality=98)

print("Cover graphic generated perfectly:")
print(" - PNG:", out_png)
print(" - JPG:", out_jpg)
print(" - Cover:", out_cover)
