import os
import string
from PIL import ImageFont
from PIL import Image

point_size = 16
font_path = os.path.join(".", "fonts", "3x5MatrixDisplay.ttf")
font = ImageFont.truetype(font_path, point_size)

characters = [char for char in string.ascii_uppercase]

def print_hex_as_binary(hex_string):
    binary_string = "".join([bin(int(hex_str, 16))[2:].zfill(8) for hex_str in hex_string.split(", ")])
    for i in range(0, len(binary_string), 8):
        print(binary_string[i:i+8])

for char in characters:
    bitmap = font.getmask(char)
    width, height = bitmap.size
    hex_array = []
    for y in range(height):
        for x in range(0, width, 8):
            byte = 0
            for i in range(8):
                if x+i < width and bitmap.getpixel((x+i, y)):
                    byte |= 1 << (7-i)
            hex_array.append(f"0x{byte:02x}")
        hex_string = ", ".join(hex_array)
    print(f"Char '{char}': {hex_string}")
    print_hex_as_binary(hex_string)
