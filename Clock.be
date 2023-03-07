var row_size = 8
var col_size = 32

font = [
[ 0x3E, 0x63, 0x73, 0x7B, 0x6F, 0x67, 0x3E, 0x00],
[ 0x0C, 0x0E, 0x0C, 0x0C, 0x0C, 0x0C, 0x3F, 0x00],
[ 0x1E, 0x33, 0x30, 0x1C, 0x06, 0x33, 0x3F, 0x00],
[ 0x1E, 0x33, 0x30, 0x1C, 0x30, 0x33, 0x1E, 0x00],
[ 0x38, 0x3C, 0x36, 0x33, 0x7F, 0x30, 0x78, 0x00],
[ 0x3F, 0x03, 0x1F, 0x30, 0x30, 0x33, 0x1E, 0x00],
[ 0x1C, 0x06, 0x03, 0x1F, 0x33, 0x33, 0x1E, 0x00],
[ 0x3F, 0x33, 0x30, 0x18, 0x0C, 0x0C, 0x0C, 0x00],
[ 0x1E, 0x33, 0x33, 0x1E, 0x33, 0x33, 0x1E, 0x00],
[ 0x1E, 0x33, 0x33, 0x3E, 0x30, 0x18, 0x0E, 0x00]
]

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

        self.print_char(hour / 10, 0, 0, 0x0000FF, 50)
        self.print_char(hour % 10, 8, 0, 0x0000FF, 50)
        self.print_char(min / 10, 16, 0, 0x0000FF, 50)
        self.print_char(min % 10, 24, 0, 0x0000FF, 50)
        # self.print_char(sec / 10, 0, 8, 0x0000FF, 50)
        # self.print_char(sec % 10, 8, 8, 0x0000FF, 50)
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
        for i: 0..7
            for j: 0..7
                var code = font[char][i]
                if code & (1 << j) != 0
                    self.set_matrix_pixel_color(x+j, y+i, color, brightness)
                else
                    self.set_matrix_pixel_color(x+j, y+i, 0x000000, 50)
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