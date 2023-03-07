var row_size = 8
var col_size = 32

var font3x5 = [
[ 0xF8, 0x88, 0xF8],
[ 0x90, 0xF8, 0x80],
[ 0xE8, 0xA8, 0xB8],
[ 0xA8, 0xA8, 0xF8],
[ 0x38, 0x20, 0xF8],
[ 0xB8, 0xA8, 0xE8],
[ 0xF8, 0xA8, 0xE8],
[ 0x08, 0xE8, 0x18],
[ 0xF8, 0xA8, 0xF8],
[ 0xB8, 0xA8, 0xF8]
]

var font = font3x5
var font_width = 3
var font_height = 5

var palette = {
    'black': 0x000000,
    'white': 0xFFFFFF,
    'red': 0xFF0000,
    'orange': 0xFFA500,
    'yellow': 0xFFFF00,
    'green': 0x008800,
    'blue': 0x0000FF,
    'indigo': 0x4B0082,
    'violet': 0xEE82EE,
}

class ClockDriver
    var leds
    var strip

    def init()
        print("ClockDriver init")
        self.leds = Leds(row_size*col_size, gpio.pin(gpio.WS2812, 32))
        self.strip = leds.create_matrix(col_size, row_size)
        self.strip.clear()
    end

    def every_second()
        var rtc = tasmota.rtc()
        # print("RTC: ", rtc)
        var time_dump = tasmota.time_dump(rtc['local'])
        # print("Time: ", time_dump)
        # self.binary_clock(time_dump)
        self.digit_clock(time_dump)

        self.strip.show()
    end

    def digit_clock(time_dump)
        var sec = time_dump['sec']
        var min = time_dump['min']
        var hour = time_dump['hour']

        var x_offset = 4
        var y_offset = 1

        self.print_char(hour / 10, 0 + x_offset, 0 + y_offset, palette['red'], 50)
        self.print_char(hour % 10, 4 + x_offset, 0 + y_offset, palette['orange'], 50)
        self.print_char(min / 10, 9 + x_offset, 0 + y_offset, palette['yellow'], 50)
        self.print_char(min % 10, 13 + x_offset, 0 + y_offset, palette['green'], 50)
        # print("sec: ", sec)
        self.print_char(sec / 10, 18 + x_offset, 0 + y_offset, palette['blue'], 50)
        self.print_char(sec % 10, 22 + x_offset, 0 + y_offset, palette['indigo'], 50)
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
                self.set_matrix_pixel_color(column, i, 0x00FF00, 50)
            else
                # print("set pixel ", i, " to 0")
                self.set_matrix_pixel_color(column, i, 0x000000, 50)
            end
        end
    end

    def print_char(char, x, y, color, brightness)
        for i: 0..(font_width-1)
            var code = font[char][i]
            for j: 0..(font_height-1)
                if code & (1 << (j + 3)) != 0
                    self.set_matrix_pixel_color(x+i, y+j, color, brightness)
                else
                    self.set_matrix_pixel_color(x+i, y+j, 0x000000, brightness)
                end
            end
        end
    end
end

# for testing remove previous driver
tasmota.remove_driver(clock)

clock = ClockDriver()

# Test one tick
# clock.every_second()

# Add to Tasmota
tasmota.add_driver(clock)