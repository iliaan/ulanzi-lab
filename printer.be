import math
import json
import fonts

class Printer
    var leds
    var strip
    var font
    var font_width
    var row_size
    var col_size
    var long_string
    var long_string_offset

    def init()
        print("Printer init")
        self.row_size = 8
        self.col_size = 32
        self.long_string = ""
        self.long_string_offset = 0

        self.leds = Leds(self.row_size*self.col_size, gpio.pin(gpio.WS2812, 32))
        self.strip = self.leds.create_matrix(self.col_size, self.row_size)

        self.change_font('MatrixDisplay3x5')

        self.clear()
    end

    def clear()
        self.strip.clear()
    end

    def draw()
        self.strip.show()
    end

    def change_font(font_key)
        self.font = fonts.font_map[font_key]['font']
        self.font_width = fonts.font_map[font_key]['width']
    end

    def recommend_brightness()
        var sensors = json.load(tasmota.read_sensors())
        var illuminance = sensors['ANALOG']['Illuminance2']
        var brightness = int(10 * math.log(illuminance))
        if brightness < 10
            brightness = 10
        end
        if brightness > 90
            brightness = 90
        end
        # print("Brightness: ", self.brightness, ", Illuminance: ", illuminance)
        return brightness
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

        self.strip.set_matrix_pixel_color(y, x, color, brightness)
    end

    # set pixel column to binary value
    def print_binary(value, column, color, brightness)
        for i: 0..7
            if value & (1 << i) != 0
                # print("set pixel ", i, " to 1")
                self.set_matrix_pixel_color(column, i, color, brightness)
            else
                # print("set pixel ", i, " to 0")
                self.set_matrix_pixel_color(column, i, 0x000000, brightness)
            end
        end
    end

    def print_char(char, x, y, color, brightness)
        var actual_width = 0
        if self.font.contains(char) == false
            print("Font does not contain char: ", char)
            return
        end

        var font_width = self.font_width
        var font_height = size(self.font[char])
        for i: 0..(font_height-1)
            var code = self.font[char][i]
            for j: 0..(font_width-1)
                if code & (1 << (7 - j)) != 0
                    self.set_matrix_pixel_color(x+j, y+i, color, brightness)
                    if j > actual_width
                        actual_width = j
                    end
                else
                    self.set_matrix_pixel_color(x+j, y+i, 0x000000, brightness)
                end
            end
        end

        return actual_width + 1
    end

    def print_string(string, x, y, color, brightness)
        var char_offset = 0
        for i: 0..(size(string)-1)
            if x + char_offset > self.col_size
                return true
            end

            var actual_width = 0
            if x + char_offset > 1 - self.font_width
                actual_width = self.print_char(string[i], x + char_offset, y, color, brightness)
            end

            if actual_width == 0
                actual_width = 1
            end

            char_offset += actual_width + 1
            self.print_binary(0, x + char_offset - 1, y, color, brightness)
        end

        return false # no more string to print
    end

    def print_long_string(string, x, y, color, brightness)
        if self.long_string != string
            self.long_string = string
            self.long_string_offset = 0
        end

        var is_continue = self.print_string(self.long_string, x - self.long_string_offset, y, color, brightness)
        if is_continue
            self.long_string_offset += 1
        else
            self.long_string_offset = 0
        end
    end
end

var printer = module("printer")
printer.printer = Printer()

return printer