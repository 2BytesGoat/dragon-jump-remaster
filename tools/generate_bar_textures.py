#!/usr/bin/env python3
"""Generate retro pixel-art medal bar textures (track + fill) for TextureProgressBar."""

import struct
import zlib
import os

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites", "ui")

W = 180
H = 14

BG = (26, 26, 46, 255)        # dark navy
BORDER = (58, 58, 90, 255)    # muted border
SLOT = (13, 13, 26, 255)      # recessed slot
FILL_MAIN = (255, 255, 255, 255)
FILL_SHADOW = (208, 208, 208, 255)
TRANS = (0, 0, 0, 0)

SEGMENT_W = 16
GAP_W = 2
NUM_SEGMENTS = 10
SLOT_Y = 2
SLOT_H = 10


def write_png(filename, width, height, pixels):
    def chunk(ctype, data):
        c = ctype + data
        crc = struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)
        return struct.pack(">I", len(data)) + c + crc

    header = b"\x89PNG\r\n\x1a\n"
    ihdr = chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))

    raw = b""
    for y in range(height):
        raw += b"\x00"
        for x in range(width):
            raw += struct.pack("BBBB", *pixels[y * width + x])

    idat = chunk(b"IDAT", zlib.compress(raw))
    iend = chunk(b"IEND", b"")

    with open(filename, "wb") as f:
        f.write(header + ihdr + idat + iend)


def is_corner(x, y):
    """2px rounded corners."""
    return (
        (x < 2 and y < 2)
        or (x >= W - 2 and y < 2)
        or (x < 2 and y >= H - 2)
        or (x >= W - 2 and y >= H - 2)
    )


def is_border(x, y):
    return x == 0 or x == W - 1 or y == 0 or y == H - 1


def slot_index(x):
    """Return which slot (0..9) pixel x belongs to, or -1 if in a gap/border."""
    pos = x - 1  # skip left border
    if pos < 0:
        return -1
    seg = pos // (SEGMENT_W + GAP_W)
    offset = pos % (SEGMENT_W + GAP_W)
    if seg >= NUM_SEGMENTS:
        return -1
    if offset >= SEGMENT_W:
        return -1  # in gap
    return seg


def in_slot(x, y):
    return slot_index(x) >= 0 and SLOT_Y <= y < SLOT_Y + SLOT_H


def generate_track():
    pixels = []
    for y in range(H):
        for x in range(W):
            if is_corner(x, y):
                pixels.append(TRANS)
            elif is_border(x, y):
                pixels.append(BORDER)
            elif in_slot(x, y):
                pixels.append(SLOT)
            else:
                pixels.append(BG)
    return pixels


def generate_fill():
    pixels = []
    for y in range(H):
        for x in range(W):
            if not in_slot(x, y):
                pixels.append(TRANS)
            elif y >= SLOT_Y + SLOT_H - 1:
                pixels.append(FILL_SHADOW)
            else:
                pixels.append(FILL_MAIN)
    return pixels


if __name__ == "__main__":
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    track_path = os.path.join(OUTPUT_DIR, "medal_bar_track.png")
    fill_path = os.path.join(OUTPUT_DIR, "medal_bar_fill.png")

    write_png(track_path, W, H, generate_track())
    print(f"Wrote {track_path}")

    write_png(fill_path, W, H, generate_fill())
    print(f"Wrote {fill_path}")
