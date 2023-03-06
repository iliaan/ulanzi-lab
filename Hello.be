var palette = [
    0xFF0000, #- red -#
    0xFFA500, #- orange -#
    0xFFFF00, #- yellow -#
    0x008800, #- green -#
    0x0000FF, #- blue -#
    0x4B0082, #- indigo -#
    0xEE82EE, #- violet -#
]

font = {
    'h': [
        0x82, 0x82, 0x82, 0xFE, 0x82, 0x82, 0x82, 0x00,
    ],
    'e': [
        0x00, 0x7c, 0x82, 0xfe, 0x80, 0x80, 0x7e, 0x00,
    ],
    'l': [
        0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0xF0, 0x00,
    ],
    'o': [
        0x00, 0x7C, 0x44, 0x44, 0x44, 0x44, 0x7C, 0x00,
    ]
}

var row_size = 8
var col_size = 32

# x is the column, y is the row from the top left
def set_matrix_pixel_color(strip, x, y, color, brightness)   
    # if y is odd, reverse the order of y
    if y % 2 == 1
        x = col_size - x - 1
    end

    strip.set_matrix_pixel_color(y, x, color, brightness)
end

def print_char(strip, char, x, y, color, brightness)
    for i: 0..7
        for j: 0..7
            var code = font[char][i]
            if code & (0x80 >> j) != 0
                set_matrix_pixel_color(strip, x+j, y+i, color, brightness)
            end
        end
    end
end

var leds = Leds(row_size*col_size, gpio.pin(gpio.WS2812, 32))
var strip = leds.create_matrix(col_size, row_size)
strip.clear()

print_char(strip, 'h', 0, 0, palette[0], 30)
print_char(strip, 'e', 7, 0, palette[1], 30)
print_char(strip, 'l', 15, 0, palette[2], 30)
print_char(strip, 'l', 20, 0, palette[3], 30)
print_char(strip, 'o', 24, 0, palette[4], 30)

strip.show()