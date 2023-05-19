import math
import json
import fonts

class MatrixController
    var leds
    var matrix
    var font
    var font_width
    var row_size
    var col_size
    var long_string
    var long_string_offset

    var prev_color
    var prev_brightness
    var prev_corrected_color

    def init()
        print("MatrixController Init")
        self.row_size = 8
        self.col_size = 32
        self.long_string = ""
        self.long_string_offset = 0

        self.leds = Leds(
            self.row_size * self.col_size,
            gpio.pin(gpio.WS2812, 32), # Look up the correct GPIO pin for WS2812 with ID 2 (1 in Berry)
            Leds.WS2812_GRB,
            3 # There seems to be an RMT conflict with the default one causing pixel corruption
        )
        self.leds.gamma = false
        self.matrix = self.leds.create_matrix(self.col_size, self.row_size)

        self.change_font('MatrixDisplay3x5')

        self.clear()

        self.prev_color = 0
        self.prev_brightness = 0
        self.prev_corrected_color = 0
    end

    def clear()
        for i: 0..size(self.matrix.pix_buffer)-1
            self.matrix.pix_buffer[i] = 0;
        end

        self.matrix.dirty()
    end

    def draw()
        self.matrix.show()
    end

    def change_font(font_key)
        self.font = fonts.font_map[font_key]['font']
        self.font_width = fonts.font_map[font_key]['width']
    end

    # x is the column, y is the row, (0,0) from the top left
    def set_matrix_pixel_color(x, y, color, brightness)
        # if y is odd, reverse the order of y
        if y % 2 == 1
            x = self.col_size - x - 1
        end

        if x < 0 || x >= self.col_size || y < 0 || y >= self.row_size
            # print("Invalid pixel: ", x, ", ", y)
            return
        end

        # Cache brightness calculation and gamma correction for this tuple of bri, color
        if brightness != self.prev_brightness || color != self.prev_color
            self.prev_brightness = brightness
            self.prev_color = color
            self.prev_corrected_color = self.to_gamma(color, brightness)
        end

        # call the native function directly, bypassing set_matrix_pixel_color, to_gamma etc
        # this is faster as otherwise to_gamma would be called for every single pixel even if they are the same
        self.leds.call_native(10, y * self.col_size + x, self.prev_corrected_color)
    end

    # set pixel column to binary value
    def print_binary(value, column, color, brightness)
        for i: 0..7
            if value & (1 << i) != 0
                # print("set pixel ", i, " to 1")
                self.set_matrix_pixel_color(column, i, color, brightness)
            end
        end
    end

    def print_char(char, x, y, collapse, color, brightness)
        var actual_width = collapse ? -1 : self.font_width

        if self.font.contains(char) == false
            print("Font does not contain char: ", char)
            return 0
        end

        var font_height = size(self.font[char])
        for i: 0..(font_height-1)
            var code = self.font[char][i]
            for j: 0..7
                if code & (1 << (7 - j)) != 0
                    self.set_matrix_pixel_color(x+j, y+i, color, brightness)

                    if j > actual_width
                        actual_width = j
                    end
                end
            end
        end

        return collapse ? actual_width + 1 : actual_width
    end

    def print_string(string, x, y, collapse, color, brightness)
        var char_offset = 0

        for i: 0..(size(string)-1)
            var actual_width = 0

            if x + char_offset > 1 - self.font_width
                actual_width = self.print_char(string[i], x + char_offset, y, collapse, color, brightness)
            end

            if actual_width == 0
                actual_width = 1
            end

            char_offset += actual_width + 1
            self.print_binary(0, x + char_offset, y, color, brightness)
        end
    end

    # Taken straight from the tasmota berry source-code
    # https://github.com/arendst/Tasmota/blob/e9d1e8c7250d89a24ade0c42a64731d6c492bbb2/lib/libesp32/berry_tasmota/src/embedded/leds.be#L158-L172
    def to_gamma(rgbw, bri)
       bri = (bri != nil) ? bri : 100
       var r = tasmota.scale_uint(bri, 0, 100, 0, (rgbw & 0xFF0000) >> 16)
       var g = tasmota.scale_uint(bri, 0, 100, 0, (rgbw & 0x00FF00) >> 8)
       var b = tasmota.scale_uint(bri, 0, 100, 0, (rgbw & 0x0000FF))

       return light.gamma8(r) << 16 |
              light.gamma8(g) <<  8 |
              light.gamma8(b)
    end
end

return MatrixController