import math
import json
import fonts

var font_key = 'MatrixDisplay3x5'
var font = fonts.font_map[font_key]['font']

var row_size = 8
var col_size = 32

class Printer
    var leds
    var strip

    def init()
        print("Printer init")
        self.leds = Leds(row_size*col_size, gpio.pin(gpio.WS2812, 32))
        self.strip = self.leds.create_matrix(col_size, row_size)
        self.strip.clear()
    end

    def clear()
        self.strip.clear()
    end

    def draw()
        self.strip.show()
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

    # x is the column, y is the row from the top left
    def set_matrix_pixel_color(x, y, color, brightness)   
        # if y is odd, reverse the order of y
        if y % 2 == 1
            x = col_size - x - 1
        end

        if x < 0 || x >= col_size || y < 0 || y >= row_size
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
        if font.contains(char) == false
            print("Font does not contain char: ", char)
            return
        end

        var font_width = 8
        var font_height = size(font[char])
        for i: 0..(font_height-1)
            var code = font[char][i]
            for j: 0..(font_width-1)
                if code & (1 << (font_width - j - 1)) != 0
                    self.set_matrix_pixel_color(x+j, y+i, color, brightness)
                else
                    self.set_matrix_pixel_color(x+j, y+i, 0x000000, brightness)
                end
            end
        end
    end
end

var printer = module("printer")
printer.printer = Printer()

return printer