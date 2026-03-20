#!/usr/bin/env python3
"""Re-Link 앱 아이콘 생성기 — 스플래시 Bezier 곡선 마크 기반 (v2)"""

from PIL import Image, ImageDraw, ImageFilter
import os

SIZE = 1024

# ── 색상 ──────────────────────────────────────────────────────────────────
BG_TOP_LEFT = (13, 17, 23)       # 0xFF0D1117
BG_BOTTOM_RIGHT = (30, 40, 64)   # 0xFF1E2840
MARK_COLOR = (110, 198, 202)     # 0xFF6EC6CA — primary mint


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def create_gradient_bg(size):
    """빠른 대각선 그라디언트"""
    small = 256
    img = Image.new('RGB', (small, small))
    for y in range(small):
        for x in range(small):
            t = x / small * 0.5 + y / small * 0.5
            img.putpixel((x, y), lerp_color(BG_TOP_LEFT, BG_BOTTOM_RIGHT, t))
    return img.resize((size, size), Image.LANCZOS).convert('RGBA')


def bezier3(p0, p1, p2, p3, t):
    """3차 베지어 점"""
    u = 1 - t
    return (
        u**3 * p0[0] + 3*u**2*t * p1[0] + 3*u*t**2 * p2[0] + t**3 * p3[0],
        u**3 * p0[1] + 3*u**2*t * p1[1] + 3*u*t**2 * p2[1] + t**3 * p3[1],
    )


def sample_path(segments, steps_per_seg=300):
    """여러 세그먼트(직선/베지어)를 연속 점 리스트로 변환"""
    points = []
    for seg in segments:
        if len(seg) == 2:  # 직선
            p0, p1 = seg
            for i in range(steps_per_seg + 1):
                t = i / steps_per_seg
                points.append((p0[0] + (p1[0]-p0[0])*t, p0[1] + (p1[1]-p0[1])*t))
        elif len(seg) == 4:  # 3차 베지어
            for i in range(steps_per_seg + 1):
                t = i / steps_per_seg
                points.append(bezier3(*seg, t))
    return points


def draw_path(draw, points, color, width):
    """점 리스트를 따라 두꺼운 선 그리기 (원 연속 배치)"""
    r = width / 2
    for x, y in points:
        draw.ellipse([x-r, y-r, x+r, y+r], fill=color)


def generate_icon():
    print("아이콘 생성 중...")
    bg = create_gradient_bg(SIZE)

    # ── 마크 좌표 계산 ──
    # 스플래시 _BezierMarkPainter 비율 그대로, 아이콘 크기에 맞게 스케일
    mark_w = 560
    mark_h = 280
    ox = (SIZE - mark_w) / 2
    oy = (SIZE - mark_h) / 2 + 20  # 살짝 아래 (시각 중심)

    def s(fx, fy):
        """비율 → 절대 좌표"""
        return (ox + mark_w * fx, oy + mark_h * fy)

    # 스플래시 코드 기반 전체 경로 (4개 세그먼트)
    segments = [
        # 1. 왼쪽 직선: (0, 0.7) → (0.2, 0.7)
        (s(0.0, 0.7), s(0.2, 0.7)),
        # 2. 상승 곡선: (0.2, 0.7) → cp(0.4, 0.7) → cp(0.45, 0.1) → (0.55, 0.3)
        (s(0.2, 0.7), s(0.4, 0.7), s(0.45, 0.1), s(0.55, 0.3)),
        # 3. 하강 곡선: (0.55, 0.3) → cp(0.65, 0.5) → cp(0.6, 0.7) → (0.8, 0.7)
        (s(0.55, 0.3), s(0.65, 0.5), s(0.6, 0.7), s(0.8, 0.7)),
        # 4. 오른쪽 직선: (0.8, 0.7) → (1.0, 0.7)
        (s(0.8, 0.7), s(1.0, 0.7)),
    ]

    # 전체 경로를 하나의 연속 점 리스트로
    all_points = sample_path(segments, steps_per_seg=400)

    # ── 글로우 레이어 (큰 블러) ──
    glow_layer = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)
    draw_path(glow_draw, all_points, (*MARK_COLOR, 50), width=50)
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=25))

    # ── 중간 글로우 ──
    mid_glow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    mid_draw = ImageDraw.Draw(mid_glow)
    draw_path(mid_draw, all_points, (*MARK_COLOR, 80), width=30)
    mid_glow = mid_glow.filter(ImageFilter.GaussianBlur(radius=10))

    # ── 메인 라인 ──
    line_layer = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    line_draw = ImageDraw.Draw(line_layer)
    draw_path(line_draw, all_points, (*MARK_COLOR, 255), width=16)

    # ── 하이라이트 (얇은 밝은 선) ──
    hl_layer = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    hl_draw = ImageDraw.Draw(hl_layer)
    draw_path(hl_draw, all_points, (200, 240, 245, 120), width=6)

    # ── 양쪽 끝 점 (노드) ──
    dot_layer = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    dot_draw = ImageDraw.Draw(dot_layer)

    left_dot = s(0.0, 0.7)
    right_dot = s(1.0, 0.7)
    dot_r = 26

    for cx, cy in [left_dot, right_dot]:
        # 점 글로우
        for mult, alpha in [(4.0, 15), (2.5, 25), (1.8, 40)]:
            r = dot_r * mult
            dot_draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(*MARK_COLOR, alpha))
        # 메인 점
        dot_draw.ellipse([cx-dot_r, cy-dot_r, cx+dot_r, cy+dot_r], fill=(*MARK_COLOR, 255))
        # 내부 밝은 원
        ir = dot_r * 0.5
        dot_draw.ellipse([cx-ir, cy-ir, cx+ir, cy+ir], fill=(180, 230, 235, 200))
        # 하이라이트
        hr = dot_r * 0.25
        hx, hy = cx - dot_r * 0.25, cy - dot_r * 0.3
        dot_draw.ellipse([hx-hr, hy-hr, hx+hr, hy+hr], fill=(255, 255, 255, 140))

    # ── 합성 ──
    result = bg.copy()
    result = Image.alpha_composite(result, glow_layer)
    result = Image.alpha_composite(result, mid_glow)
    result = Image.alpha_composite(result, line_layer)
    result = Image.alpha_composite(result, hl_layer)
    result = Image.alpha_composite(result, dot_layer)

    # 저장
    out_path = os.path.join(os.path.dirname(__file__), '..', 'assets', 'app_icon_1024.png')
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    result.convert('RGB').save(out_path, 'PNG', quality=100)
    print(f"✅ 아이콘 저장: {os.path.abspath(out_path)}")
    return out_path


if __name__ == '__main__':
    generate_icon()
