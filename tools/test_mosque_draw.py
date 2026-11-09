import math
from PIL import Image, ImageDraw, ImageFilter

def create_ultimate_mosque(size=2048, mode='full'):
    """
    mode can be:
      - 'full': Square with rounded frame & deep emerald gradient (legacy ic_launcher.png)
      - 'round': Circle with gold borders (legacy ic_launcher_round.png)
      - 'foreground': Mosque on transparent background, centered in safe zone (adaptive ic_launcher_foreground.png)
      - 'background': Emerald background with subtle Islamic halo/rosette (adaptive ic_launcher_background.png)
      - 'playstore': 512x512 master app icon for Google Play Store
    """
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx = size / 2.0
    cy = size / 2.0
    s = size / 2048.0

    # Palette: Authentic Islamic Deep Emerald & Muted Gold
    gold_highlight = (255, 243, 214, 255) # Bright gold highlight
    gold_light     = (242, 218, 150, 255) # Light warm gold
    gold_main      = (215, 181, 109, 255) # Primary Brand Gold (#D7B56D)
    gold_rich      = (190, 153, 82, 255)  # Rich medium gold (#BE9952)
    gold_deep      = (150, 115, 50, 255)  # Deep shadow gold (#967332)
    void_emerald   = (9, 32, 24, 255)     # Deep emerald for doorway/windows

    # -------------------------------------------------------------
    # 1. BACKGROUND (For 'full', 'round', 'background', 'playstore')
    # -------------------------------------------------------------
    if mode != 'foreground':
        # Deep Emerald Gradient
        for y in range(size):
            t = y / float(size)
            # Subtle curved gradient: #114B3A at top to #061D15 at bottom
            r = int(17 * (1 - t) + 6 * t)
            g = int(75 * (1 - t) + 29 * t)
            b = int(58 * (1 - t) + 21 * t)
            draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

        # Radial soft emerald illumination behind the dome
        glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        gdraw = ImageDraw.Draw(glow)
        glow_center_y = cy - 80 * s
        for rad in range(int(750 * s), 0, -12):
            factor = 1.0 - (rad / (750 * s))
            alpha = int(48 * (factor ** 1.6))
            gdraw.ellipse(
                [cx - rad, glow_center_y - rad, cx + rad, glow_center_y + rad],
                fill=(46, 139, 104, alpha)
            )
        img = Image.alpha_composite(img, glow)
        draw = ImageDraw.Draw(img)

        # Subtle Decorative Arabesque Halo behind the Dome (Pure circles & radial rays, not crossing minarets)
        halo_r = 540 * s
        # Concentric thin gold rings
        draw.ellipse([cx - halo_r, glow_center_y - halo_r, cx + halo_r, glow_center_y + halo_r], outline=(215, 181, 109, 36), width=int(3 * s))
        draw.ellipse([cx - halo_r*0.82, glow_center_y - halo_r*0.82, cx + halo_r*0.82, glow_center_y + halo_r*0.82], outline=(215, 181, 109, 22), width=int(2 * s))
        draw.ellipse([cx - halo_r*0.65, glow_center_y - halo_r*0.65, cx + halo_r*0.65, glow_center_y + halo_r*0.65], outline=(215, 181, 109, 18), width=int(2 * s))
        
        # 16 subtle decorative rays radiating from behind the dome
        for i in range(16):
            ang = math.radians(i * (360 / 16))
            x1 = cx + (halo_r * 0.85) * math.cos(ang)
            y1 = glow_center_y + (halo_r * 0.85) * math.sin(ang)
            x2 = cx + halo_r * math.cos(ang)
            y2 = glow_center_y + halo_r * math.sin(ang)
            draw.line([(x1, y1), (x2, y2)], fill=(242, 218, 150, 40), width=int(3 * s))

    # If only background is requested, return now (for adaptive background)
    if mode == 'background':
        return img

    # -------------------------------------------------------------
    # 2. THE MOSQUE (Artwork)
    # -------------------------------------------------------------
    mosque = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    mdraw = ImageDraw.Draw(mosque)

    # Scale: for adaptive foreground, safe circle radius is ~660 * s (out of 1024)
    # Mosque dimensions: total width ~920 * s, height ~1050 * s
    m_scale = 0.94 if mode == 'foreground' else 0.98
    ms = s * m_scale

    base_y = cy + 440 * ms
    wall_h = 310 * ms
    wall_w = 780 * ms
    wall_top = base_y - wall_h
    wall_left = cx - wall_w / 2
    wall_right = cx + wall_w / 2

    minaret_offset = 430 * ms
    minaret_w = 70 * ms
    minaret_top_y = cy - 430 * ms

    # --- A. BASE FACADE WALL ---
    mdraw.rectangle([wall_left, wall_top, wall_right, base_y], fill=gold_rich)
    # Horizontal Islamic masonry bands (أبلق إسلامي رخامي)
    for b_idx in range(3):
        by_top = wall_top + (b_idx * 2 + 1) * 36 * ms
        mdraw.rectangle([wall_left, by_top, wall_right, by_top + 18 * ms], fill=gold_main)

    # Upper wall cornice & parapet crenellations (شرفات مسننة)
    mdraw.rectangle([wall_left - 12 * ms, wall_top - 20 * ms, wall_right + 12 * ms, wall_top], fill=gold_main)
    cren_count = 13
    cren_w = wall_w / cren_count
    for i in range(cren_count):
        ccx = wall_left + (i + 0.5) * cren_w
        cw = cren_w * 0.44
        mdraw.polygon([
            (ccx - cw, wall_top - 20 * ms),
            (ccx, wall_top - 46 * ms),
            (ccx + cw, wall_top - 20 * ms)
        ], fill=gold_light)

    # --- B. GRAND BULBOUS DOME WITH ELEGANT VERTICAL FLUTES (القبة المضلعة الملكية) ---
    dome_base_y = wall_top - 20 * ms
    dome_apex_y = cy - 400 * ms
    dome_h = dome_base_y - dome_apex_y
    dome_r_base = 265 * ms

    # First, draw base dome silhouette in rich gold
    steps = 60
    def get_dome_points(factor_left=1.0, factor_right=1.0):
        pts = [(cx - dome_r_base * factor_left, dome_base_y)]
        for i in range(steps + 1):
            u = i / float(steps)
            w = math.sqrt(max(0, 1 - u**1.8)) * (1.0 + 0.23 * math.sin((1 - u) * math.pi))
            pts.append((cx - dome_r_base * factor_left * w, dome_base_y - u * dome_h))
        for i in range(steps, -1, -1):
            u = i / float(steps)
            w = math.sqrt(max(0, 1 - u**1.8)) * (1.0 + 0.23 * math.sin((1 - u) * math.pi))
            pts.append((cx + dome_r_base * factor_right * w, dome_base_y - u * dome_h))
        pts.append((cx + dome_r_base * factor_right, dome_base_y))
        return pts

    mdraw.polygon(get_dome_points(1.0, 1.0), fill=gold_main)

    # Draw vertical architectural ribs / flutes across the dome (7 flutes)
    # Flute boundaries from -1.0 to +1.0
    rib_divs = [-1.0, -0.72, -0.44, -0.16, 0.16, 0.44, 0.72, 1.0]
    flute_colors = [
        gold_deep,      # Far left (shadow)
        gold_rich,      # Mid left
        gold_light,     # Center-left (light highlight)
        gold_highlight, # Center (primary luster)
        gold_light,     # Center-right
        gold_rich,      # Mid right
        gold_deep       # Far right (shadow)
    ]

    for f_idx in range(len(rib_divs) - 1):
        x_frac1 = rib_divs[f_idx]
        x_frac2 = rib_divs[f_idx + 1]
        color = flute_colors[f_idx]

        f_pts = []
        # Left boundary of flute going up
        for i in range(steps + 1):
            u = i / float(steps)
            w = math.sqrt(max(0, 1 - u**1.8)) * (1.0 + 0.23 * math.sin((1 - u) * math.pi))
            f_pts.append((cx + dome_r_base * x_frac1 * w, dome_base_y - u * dome_h))
        # Right boundary of flute coming down
        for i in range(steps, -1, -1):
            u = i / float(steps)
            w = math.sqrt(max(0, 1 - u**1.8)) * (1.0 + 0.23 * math.sin((1 - u) * math.pi))
            f_pts.append((cx + dome_r_base * x_frac2 * w, dome_base_y - u * dome_h))
        mdraw.polygon(f_pts, fill=color)

    # Dome Drum (Pedestal beneath dome with arched windows)
    drum_w = dome_r_base * 2.06
    mdraw.rectangle([cx - drum_w/2, dome_base_y - 28*ms, cx + drum_w/2, dome_base_y], fill=gold_deep)
    mdraw.rectangle([cx - drum_w/2, dome_base_y - 6*ms, cx + drum_w/2, dome_base_y], fill=gold_highlight)
    # Drum arched clerestory windows
    for d_off in [-180, -120, -60, 0, 60, 120, 180]:
        dwx = cx + d_off * ms
        mdraw.ellipse([dwx - 14*ms, dome_base_y - 24*ms, dwx + 14*ms, dome_base_y - 8*ms], fill=void_emerald)

    # --- C. DOME FINIAL & BOLD ISLAMIC CRESCENT (الهلال الذهبي الشريف) ---
    finial_base = dome_apex_y
    finial_top = finial_base - 180 * ms
    mdraw.line([(cx, finial_base), (cx, finial_top)], fill=gold_highlight, width=int(16 * ms))
    # Three ornamental graduated orbs (الجامور الإسلامي)
    mdraw.ellipse([cx - 24*ms, finial_base - 60*ms, cx + 24*ms, finial_base - 22*ms], fill=gold_highlight)
    mdraw.ellipse([cx - 19*ms, finial_base - 110*ms, cx + 19*ms, finial_base - 76*ms], fill=gold_highlight)
    mdraw.ellipse([cx - 14*ms, finial_base - 150*ms, cx + 14*ms, finial_base - 124*ms], fill=gold_highlight)

    # Bold Majestic Upturned Crescent Moon
    cres_r = 54 * ms
    cres_cx = cx
    cres_cy = finial_top - cres_r * 0.40
    cres_pts = []
    # Outer arc (-115 to +115 deg)
    for i in range(45):
        ang = math.radians(-115 + i * (230 / 44.0))
        cres_pts.append((cres_cx + cres_r * math.cos(ang), cres_cy + cres_r * math.sin(ang)))
    # Inner arc (smaller radius, shifted to the right)
    inner_r = cres_r * 0.76
    inner_shift = 17 * ms
    for i in range(45, -1, -1):
        ang = math.radians(-125 + i * (250 / 45.0))
        cres_pts.append((cres_cx + inner_shift + inner_r * math.cos(ang), cres_cy + inner_r * math.sin(ang)))
    mdraw.polygon(cres_pts, fill=gold_highlight)

    # Five-point star nestled in the crescent
    star_cx = cres_cx + 30 * ms
    star_cy = cres_cy - 4 * ms
    star_r = 13 * ms
    star_pts = []
    for i in range(10):
        r_cur = star_r if i % 2 == 0 else star_r * 0.44
        ang = math.radians(-90 + i * 36)
        star_pts.append((star_cx + r_cur * math.cos(ang), star_cy + r_cur * math.sin(ang)))
    mdraw.polygon(star_pts, fill=gold_highlight)

    # --- D. TWIN MINARETS (المآذن المتناظرة الشامخة) ---
    for side in (-1, 1):
        mx = cx + side * minaret_offset
        mw = minaret_w

        # Main shaft (base up to balcony 1)
        b1_y = cy - 70 * ms
        mdraw.rectangle([mx - mw/2, b1_y, mx + mw/2, base_y], fill=gold_rich)
        # 3D shading: highlight on left, shadow on right
        mdraw.rectangle([mx - mw/2, b1_y, mx, base_y], fill=gold_light)
        mdraw.rectangle([mx, b1_y, mx + mw/2, base_y], fill=gold_rich)
        # Decorative masonry bands on shaft
        for s_idx in range(4):
            sy = b1_y + (s_idx + 1) * 90 * ms
            mdraw.rectangle([mx - mw/2, sy, mx + mw/2, sy + 10*ms], fill=gold_highlight)

        # Lower Balcony (شرفة الأذان الأولى)
        bw1 = mw * 1.65
        mdraw.rectangle([mx - bw1/2, b1_y - 20*ms, mx + bw1/2, b1_y], fill=gold_deep)
        mdraw.rectangle([mx - bw1/2 - 4*ms, b1_y - 36*ms, mx + bw1/2 + 4*ms, b1_y - 20*ms], fill=gold_highlight)
        # Balcony corbels
        for cb in [-bw1*0.35, 0, bw1*0.35]:
            mdraw.polygon([
                (mx + cb - 5*ms, b1_y),
                (mx + cb, b1_y + 16*ms),
                (mx + cb + 5*ms, b1_y)
            ], fill=gold_deep)

        # Upper shaft (slender second tier)
        mw2 = mw * 0.82
        b2_y = minaret_top_y + 80 * ms
        mdraw.rectangle([mx - mw2/2, b2_y, mx + mw2/2, b1_y - 36*ms], fill=gold_rich)
        mdraw.rectangle([mx - mw2/2, b2_y, mx, b1_y - 36*ms], fill=gold_light)
        # Arched window on upper shaft
        mdraw.ellipse([mx - 8*ms, b1_y - 100*ms, mx + 8*ms, b1_y - 70*ms], fill=void_emerald)

        # Upper Balcony (شرفة الأذان الثانية)
        bw2 = mw * 1.48
        mdraw.rectangle([mx - bw2/2, b2_y - 18*ms, mx + bw2/2, b2_y], fill=gold_deep)
        mdraw.rectangle([mx - bw2/2 - 3*ms, b2_y - 32*ms, mx + bw2/2 + 3*ms, b2_y - 18*ms], fill=gold_highlight)

        # Pavilion / Gallery (المقصورة العلوية)
        pav_w = mw * 0.78
        mdraw.rectangle([mx - pav_w/2, minaret_top_y - 24*ms, mx + pav_w/2, b2_y - 32*ms], fill=gold_light)
        mdraw.ellipse([mx - 8*ms, b2_y - 52*ms, mx + 8*ms, b2_y - 36*ms], fill=void_emerald)

        # Conical Spire (قمة المئذنة)
        spire_top = minaret_top_y - 155 * ms
        mdraw.polygon([
            (mx - pav_w/2 - 4*ms, minaret_top_y - 24*ms),
            (mx, spire_top),
            (mx + pav_w/2 + 4*ms, minaret_top_y - 24*ms)
        ], fill=gold_highlight)
        mdraw.polygon([
            (mx, minaret_top_y - 24*ms),
            (mx, spire_top),
            (mx + pav_w/2 + 4*ms, minaret_top_y - 24*ms)
        ], fill=gold_main)

        # Minaret Finial & Crescent
        mdraw.line([(mx, spire_top), (mx, spire_top - 50*ms)], fill=gold_highlight, width=int(8 * ms))
        m_cres_r = 18 * ms
        m_cx = mx
        m_cy = spire_top - 50*ms - m_cres_r * 0.5
        mc_pts = []
        for i in range(24):
            ang = math.radians(-115 + i * (230 / 23.0))
            mc_pts.append((m_cx + m_cres_r * math.cos(ang), m_cy + m_cres_r * math.sin(ang)))
        for i in range(24, -1, -1):
            ang = math.radians(-125 + i * (250 / 24.0))
            mc_pts.append((m_cx + 5*ms + m_cres_r*0.75 * math.cos(ang), m_cy + m_cres_r*0.75 * math.sin(ang)))
        mdraw.polygon(mc_pts, fill=gold_highlight)

    # --- E. GRAND CENTRAL ISLAMIC ARCHE PORTAL (البوابة الكبرى والمحراب) ---
    portal_w = 236 * ms
    portal_h = 255 * ms
    portal_bottom = base_y
    portal_top = portal_bottom - portal_h

    # Outer decorative Pishtaq frame
    p_frame_w = portal_w + 64 * ms
    mdraw.rectangle([cx - p_frame_w/2, portal_top - 36*ms, cx + p_frame_w/2, portal_bottom], fill=gold_highlight)
    # Triangular pediment crown
    mdraw.polygon([
        (cx - p_frame_w/2, portal_top - 36*ms),
        (cx, portal_top - 70*ms),
        (cx + p_frame_w/2, portal_top - 36*ms)
    ], fill=gold_highlight)
    # Inner gold border
    mdraw.rectangle([cx - p_frame_w/2 + 8*ms, portal_top - 26*ms, cx + p_frame_w/2 - 8*ms, portal_bottom], outline=gold_deep, width=int(4*ms))

    # Pointed Arch Entrance
    arch_pts = [(cx - portal_w/2, portal_bottom)]
    steps_p = 36
    for i in range(steps_p + 1):
        u = i / float(steps_p)
        y = portal_bottom - (portal_h * 0.62) - (portal_h * 0.38) * math.sin(u * math.pi)
        curv = 1.0 - 0.08 * (1.0 - math.sin(u * math.pi))
        x = cx - (portal_w/2 * curv) * math.cos(u * math.pi)
        arch_pts.append((x, y))
    arch_pts.append((cx + portal_w/2, portal_bottom))
    mdraw.polygon(arch_pts, fill=void_emerald)

    # Inner Arch Trim
    trim_pts = [(cx - (portal_w/2 - 14*ms), portal_bottom)]
    for i in range(steps_p + 1):
        u = i / float(steps_p)
        y = portal_bottom - (portal_h * 0.62 - 10*ms) - (portal_h * 0.38 - 14*ms) * math.sin(u * math.pi)
        x = cx - ((portal_w/2 - 14*ms)) * math.cos(u * math.pi)
        trim_pts.append((x, y))
    trim_pts.append((cx + (portal_w/2 - 14*ms), portal_bottom))
    mdraw.polygon(trim_pts, outline=gold_main, width=int(4*ms))

    # Traditional Glowing Mosque Lamp (قنديل مضيء)
    lamp_chain_top = portal_top + 10 * ms
    lamp_y = lamp_chain_top + 48 * ms
    mdraw.line([(cx, lamp_chain_top), (cx, lamp_y)], fill=gold_highlight, width=int(3 * ms))
    # Glowing orb
    mdraw.ellipse([cx - 12*ms, lamp_y - 6*ms, cx + 12*ms, lamp_y + 18*ms], fill=(255, 240, 180, 255))
    mdraw.ellipse([cx - 6*ms, lamp_y + 16*ms, cx + 6*ms, lamp_y + 24*ms], fill=gold_highlight)

    # --- F. SYMMETRICAL ARCHED WINDOWS ON FACADE (النوافذ المقوسة) ---
    for side in (-1, 1):
        for dist in [190 * ms, 312 * ms]:
            wx = cx + side * dist
            ww = 52 * ms
            wh = 96 * ms
            w_bot = base_y - 45 * ms

            # Window frame
            mdraw.rectangle([wx - ww/2 - 6*ms, w_bot - wh - 12*ms, wx + ww/2 + 6*ms, w_bot + 4*ms], fill=gold_highlight)
            
            w_pts = [(wx - ww/2, w_bot)]
            for i in range(21):
                u = i / 20.0
                y = w_bot - (wh * 0.65) - (wh * 0.35) * math.sin(u * math.pi)
                x = wx - (ww/2) * math.cos(u * math.pi)
                w_pts.append((x, y))
            w_pts.append((wx + ww/2, w_bot))
            mdraw.polygon(w_pts, fill=void_emerald)

            # Golden grill work
            mdraw.line([(wx, w_bot - wh), (wx, w_bot)], fill=gold_main, width=int(3*ms))
            mdraw.line([(wx - ww/2 + 4*ms, w_bot - wh*0.5), (wx + ww/2 - 4*ms, w_bot - wh*0.5)], fill=gold_main, width=int(3*ms))

    # --- G. PLINTH & STEPS AT BASE (الدرج الرخامي) ---
    mdraw.rectangle([cx - wall_w/2 - 48*ms, base_y, cx + wall_w/2 + 48*ms, base_y + 26*ms], fill=gold_highlight)
    mdraw.rectangle([cx - wall_w/2 - 80*ms, base_y + 26*ms, cx + wall_w/2 + 80*ms, base_y + 52*ms], fill=gold_rich)
    mdraw.rectangle([cx - wall_w/2 - 110*ms, base_y + 52*ms, cx + wall_w/2 + 110*ms, base_y + 74*ms], fill=gold_deep)

    # Composite mosque onto canvas
    img = Image.alpha_composite(img, mosque)

    # -------------------------------------------------------------
    # 3. OUTPUT FORMAT SHAPING
    # -------------------------------------------------------------
    if mode == 'foreground':
        return mosque

    elif mode == 'round':
        mask = Image.new('L', (size, size), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.ellipse([16*s, 16*s, size - 16*s, size - 16*s], fill=255)

        ring = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        rdraw = ImageDraw.Draw(ring)
        rdraw.ellipse([16*s, 16*s, size - 16*s, size - 16*s], outline=gold_main, width=int(26*s))
        rdraw.ellipse([34*s, 34*s, size - 34*s, size - 34*s], outline=gold_highlight, width=int(6*s))

        output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        output.paste(img, (0, 0), mask)
        output = Image.alpha_composite(output, ring)
        return output

    elif mode in ('full', 'playstore'):
        mask = Image.new('L', (size, size), 0)
        mask_draw = ImageDraw.Draw(mask)
        rad = 440 * s
        mask_draw.rounded_rectangle([16*s, 16*s, size - 16*s, size - 16*s], radius=rad, fill=255)

        border = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        bdraw = ImageDraw.Draw(border)
        bdraw.rounded_rectangle([16*s, 16*s, size - 16*s, size - 16*s], radius=rad, outline=gold_main, width=int(24*s))
        bdraw.rounded_rectangle([34*s, 34*s, size - 34*s, size - 34*s], radius=rad - 18*s, outline=gold_highlight, width=int(6*s))

        output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        output.paste(img, (0, 0), mask)
        output = Image.alpha_composite(output, border)
        return output

    return img

if __name__ == '__main__':
    print('Generating ultimate mosque preview...')
    create_ultimate_mosque(2048, mode='full').save('release/preview_ultimate_full.png')
    create_ultimate_mosque(2048, mode='round').save('release/preview_ultimate_round.png')
    create_ultimate_mosque(2048, mode='foreground').save('release/preview_ultimate_fg.png')
    print('Ultimate previews generated!')
