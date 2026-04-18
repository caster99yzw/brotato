import struct
import zlib
import os

def create_png(width, height, pixels):
    def png_chunk(chunk_type, data):
        chunk = chunk_type + data
        crc = zlib.crc32(chunk) & 0xffffffff
        return struct.pack('>I', len(data)) + chunk + struct.pack('>I', crc)
    signature = b'\x89PNG\r\n\x1a\n'
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr = png_chunk(b'IHDR', ihdr_data)
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'
        for x in range(width):
            idx = y * width + x
            raw_data += bytes(pixels[idx])
    compressed = zlib.compress(raw_data, 9)
    idat = png_chunk(b'IDAT', compressed)
    iend = png_chunk(b'IEND', b'')
    return signature + ihdr + idat + iend

YELLOW = (255, 214, 0, 255)
ORANGE = (255, 128, 0, 255)
TRANSPARENT = (0, 0, 0, 0)

def full_pattern(pixels):
    result = []
    for row in pixels:
        result.extend(row)
    return result

def pistol():
    p = [[0]*32 for _ in range(32)]
    for x in range(10, 22):
        for y in range(12, 20):
            p[y][x] = 1
    return full_pattern(p)

def shotgun():
    p = [[0]*32 for _ in range(32)]
    for x in range(10, 22):
        for y in range(12, 20):
            if (x + y) % 2 == 0:
                p[y][x] = 1
    return full_pattern(p)

def rifle():
    p = [[0]*32 for _ in range(32)]
    for x in range(8, 24):
        for y in range(13, 19):
            p[y][x] = 1
    return full_pattern(p)

def grenade():
    p = [[0]*32 for _ in range(32)]
    for x in range(10, 22):
        for y in range(10, 22):
            p[y][x] = 1
    return full_pattern(p)

def spinner():
    p = [[0]*32 for _ in range(32)]
    cx, cy = 16, 16
    for x in range(8, 24):
        for y in range(8, 24):
            if (x-cx)*(x-cx) + (y-cy)*(y-cy) < 100:
                p[y][x] = 1
    return full_pattern(p)

def missile():
    p = [[0]*32 for _ in range(32)]
    for x in range(12, 20):
        for y in range(8, 20):
            p[y][x] = 1
    for x in range(10, 22):
        for y in range(20, 26):
            p[y][x] = 2
    return full_pattern(p)

def magic():
    p = [[0]*32 for _ in range(32)]
    cx, cy = 16, 16
    for x in range(10, 22):
        for y in range(10, 22):
            if abs(x-cx) + abs(y-cy) < 8:
                p[y][x] = 1
    return full_pattern(p)

def boomerang():
    p = [[0]*32 for _ in range(32)]
    for x in range(6, 16):
        y = 20 - (x - 6) // 2
        p[y][x] = 1
    for x in range(16, 26):
        y = 10 + (x - 16) // 2
        p[y][x] = 1
    for x in range(10, 22):
        p[16][x] = 1
    return full_pattern(p)

def slash():
    p = [[0]*32 for _ in range(32)]
    for i in range(8, 24):
        p[i][20 + i//4] = 1
        p[i][12 + i//4] = 1
    return full_pattern(p)

def arrow_rain():
    p = [[0]*32 for _ in range(32)]
    for y in range(4, 28):
        p[y][16] = 1
    p[4][15] = 1
    p[4][16] = 1
    p[4][17] = 1
    return full_pattern(p)

BULLET_PATTERNS = {
    "pistol_bullet": pistol(),
    "shotgun_bullet": shotgun(),
    "rifle_bullet": rifle(),
    "grenade_bullet": grenade(),
    "spinner_bullet": spinner(),
    "missile_bullet": missile(),
    "magic_bullet": magic(),
    "boomerang_bullet": boomerang(),
    "slash_bullet": slash(),
    "arrow_rain_bullet": arrow_rain(),
}

def generate_bullet(name, pattern):
    pixels = []
    for val in pattern:
        if val == 1:
            pixels.append(YELLOW)
        elif val == 2:
            pixels.append(ORANGE)
        else:
            pixels.append(TRANSPARENT)
    return create_png(32, 32, pixels)

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(script_dir, "..", "resources", "sprites", "bullets")
    os.makedirs(output_dir, exist_ok=True)
    for name, pattern in BULLET_PATTERNS.items():
        png_data = generate_bullet(name, pattern)
        filepath = os.path.join(output_dir, f"{name}.png")
        with open(filepath, 'wb') as f:
            f.write(png_data)
        print(f"Generated: {filepath}")
    print("Done!")

if __name__ == "__main__":
    main()