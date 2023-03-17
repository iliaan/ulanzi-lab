import os
import string
from PIL import ImageFont

def print_hex_as_binary(hex_string):
    binary_string = "".join([bin(int(hex_str, 16))[2:].zfill(8) for hex_str in hex_string.split(", ")])
    for i in range(0, len(binary_string), 8):
        print(binary_string[i:i+8])

def generate_hex_strings(font_path, point_size, characters):
    font = ImageFont.truetype(font_path, point_size)
    hex_strings = {}
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
        hex_strings[char] = hex_string
    return hex_strings

def save_hex_strings_to_file(hex_strings, filename):
    with open(filename, 'w') as f:
        for char, hex_string in hex_strings.items():
            f.write(f"Char '{char}': {hex_string}\n")
            binary_string = "".join([bin(int(hex_str, 16))[2:].zfill(8) for hex_str in hex_string.split(", ")])
            for i in range(0, len(binary_string), 8):
                f.write(f"{binary_string[i:i+8]}\n")
            f.write("\n")

def main():
    point_size = 16
    font_path = os.path.join(".", "fonts", "TinyUnicode.ttf")
    characters = [char for char in string.ascii_uppercase]
    hex_strings = generate_hex_strings(font_path, point_size, characters)
    filename = "hex_strings.txt"
    save_hex_strings_to_file(hex_strings, filename)

if __name__ == "__main__":
    main()
