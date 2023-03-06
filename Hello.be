var palette = [
    0xFF0000, #- red -#
    0xFFA500, #- orange -#
    0xFFFF00, #- yellow -#
    0x008800, #- green -#
    0x0000FF, #- blue -#
    0x4B0082, #- indigo -#
    0xEE82EE, #- violet -#
]

var row_size = 8
var col_size = 32

var leds = Leds(row_size*col_size, gpio.pin(gpio.WS2812, 32))
var strip = leds.create_matrix(row_size,col_size)
strip.clear()

var i = 0
while i < strip.pixel_count()
    var y = i / col_size
    # print(row)
    var x = i % col_size
    strip.set_matrix_pixel_color(x, y, palette[4], 30)
    i += 1
end

strip.show()