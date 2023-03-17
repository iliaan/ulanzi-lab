import os
import string
from PIL import ImageFont
from PIL import Image

point_size = 16
font_path = os.path.join(".", "fonts", "3x5MatrixDisplay.ttf")
font = ImageFont.truetype(font_path, point_size)

characters = [char for char in string.ascii_uppercase]

for char in characters:
    char_box = font.getbbox(char)[2:]
    print(char, char_box)
    with Image.new("1", (char_box)) as im:
        im.putdata(font.getmask(char))
        #print image size
        print(char, font.getbbox(char))
        print(char, font.getlength(char))
        print(char, font.getsize(char))
        im.save(os.path.join(".", "fonts", char + ".bmp"))
