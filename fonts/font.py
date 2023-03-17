import string

from PIL import ImageFont
from PIL import Image

point_size = 16
font = ImageFont.truetype("./fonts/TinyUnicode.ttf", point_size)

for char in string.ascii_uppercase:
    im = Image.Image()._new(font.getmask(char))
    im.save("./fonts/" + char + ".bmp")