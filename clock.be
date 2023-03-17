import printer
import fonts

class ClockDriver
    var printer
    var colors
    var color_index

    def init()
        print("ClockDriver init")
        self.printer = printer.printer

        self.colors = [ fonts.palette['white'], fonts.palette['red'], fonts.palette['green'], fonts.palette['blue'] ]
        self.color_index = 0

        tasmota.add_rule("Button3#State", / value, trigger, msg -> self.on_button_next(value, trigger, msg))
    end

    def every_second()
        self.printer.update_brightness()
        self.print_time()
        self.printer.strip.show()
    end

    def on_button_next(value, trigger, msg)
        # print(value)
        # print(trigger)
        # print(msg)
        self.color_index = (self.color_index + 1) % size(self.colors)
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

        self.printer.print_char(str(hour / 10), 0 + x_offset, 0 + y_offset, self.colors[self.color_index], self.printer.brightness)
        self.printer.print_char(str(hour % 10), 4 + x_offset, 0 + y_offset, self.colors[self.color_index], self.printer.brightness)
        self.printer.print_char(str(min / 10), 9 + x_offset, 0 + y_offset, self.colors[self.color_index], self.printer.brightness)
        self.printer.print_char(str(min % 10), 13 + x_offset, 0 + y_offset, self.colors[self.color_index], self.printer.brightness)
        # print("sec: ", sec)
        self.printer.print_char(str(sec / 10), 18 + x_offset, 0 + y_offset, self.colors[self.color_index], self.printer.brightness)
        self.printer.print_char(str(sec % 10), 22 + x_offset, 0 + y_offset, self.colors[self.color_index], self.printer.brightness)
    end

    def binary_clock(time_dump)
        var sec = time_dump['sec']
        self.printer.print_binary(sec, 1)

        var min = time_dump['min']
        self.printer.print_binary(min, 3)

        var hour = time_dump['hour']
        self.printer.print_binary(hour, 5)
    end
end

var clock = module("clock")
clock.driver = ClockDriver()

return clock