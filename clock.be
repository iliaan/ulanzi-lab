import math
import json
import fonts

var font_key = '3x5'
var font = fonts.font_map[font_key]['font']
var font_width = fonts.font_map[font_key]['width']
var font_height = fonts.font_map[font_key]['height']
var font_offset = fonts.font_map[font_key]['offset']

var row_size = 8
var col_size = 32

class ClockDriver
    var leds
    var strip
    var colors
    var color_index
    var brightness

    def init()
        print("ClockDriver init")
        self.leds = Leds(row_size*col_size, gpio.pin(gpio.WS2812, 32))
        self.strip = self.leds.create_matrix(col_size, row_size)
        self.strip.clear()

        self.colors = [ fonts.palette['white'], fonts.palette['red'], fonts.palette['green'], fonts.palette['blue'] ]
        self.color_index = 0
        self.brightness = 50

        tasmota.add_rule("Button3#State", / value, trigger, msg -> self.on_button_next(value, trigger, msg))
    end

    def every_second()
        self.update_brightness()
        self.print_time()
        self.strip.show()
    end

    def on_button_next(value, trigger, msg)
        print(value)
        print(trigger)
        print(msg)

        self.color_index = (self.color_index + 1) % size(self.colors)
    end

    def update_brightness()
        var sensors = json.load(tasmota.read_sensors())
        var illuminance = sensors['ANALOG']['Illuminance2']
        self.brightness = int(10 * math.log(illuminance))
        if self.brightness < 10
            self.brightness = 10
        end
        if self.brightness > 90
            self.brightness = 90
        end
        # print("Brightness: ", self.brightness, ", Illuminance: ", illuminance)
    end

    def print_time()
        var rtc = tasmota.rtc()
        # print("RTC: ", rtc)
        var time_dump = tasmota.time_dump(rtc['local'])
        # print("Time: ", time_dump)
        # self.binary_clock(time_dump)
        self.digit_clock(time_dump)
    end

    def digit_clock(time_dump)
        var sec = time_dump['sec']
        var min = time_dump['min']
        var hour = time_dump['hour']

        var x_offset = 4
        var y_offset = 1

        self.print_char(hour / 10, 0 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.print_char(hour % 10, 4 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.print_char(min / 10, 9 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.print_char(min % 10, 13 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        # print("sec: ", sec)
        self.print_char(sec / 10, 18 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.print_char(sec % 10, 22 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
    end

    def binary_clock(time_dump)
        var sec = time_dump['sec']
        self.set_value_to_column(sec, 1)

        var min = time_dump['min']
        self.set_value_to_column(min, 3)

        var hour = time_dump['hour']
        self.set_value_to_column(hour, 5)
    end

    # x is the column, y is the row from the top left
    def set_matrix_pixel_color(x, y, color, brightness)   
        # if y is odd, reverse the order of y
        if y % 2 == 1
            x = col_size - x - 1
        end

        self.strip.set_matrix_pixel_color(y, x, color, brightness)
    end

    # set pixel column to binary value
    def set_value_to_column(value, column)
        for i: 0..7
            if value & (1 << i) != 0
                # print("set pixel ", i, " to 1")
                self.set_matrix_pixel_color(column, i, self.colors[self.color_index], self.brightness)
            else
                # print("set pixel ", i, " to 0")
                self.set_matrix_pixel_color(column, i, 0x000000, self.brightness)
            end
        end
    end

    def print_char(char, x, y, color, brightness)
        for i: 0..(font_width-1)
            var code = font[char][i]
            for j: 0..(font_height-1)
                if code & (1 << (j + font_offset)) != 0
                    self.set_matrix_pixel_color(x+i, y+j, color, brightness)
                else
                    self.set_matrix_pixel_color(x+i, y+j, 0x000000, brightness)
                end
            end
        end
    end
end

var clock = module("clock")
clock.driver = ClockDriver()

return clock