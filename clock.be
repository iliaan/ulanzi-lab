import printer
import fonts

class ClockDriver
    var printer
    var brightness
    var colors
    var color_index
    var state_list
    var state_index

    def init()
        print("ClockDriver init")
        self.printer = printer.printer

        self.brightness = 50
        self.colors = [ fonts.palette['white'], fonts.palette['red'], fonts.palette['green'], fonts.palette['blue'] ]
        self.color_index = 0

        self.state_list = [ 'time', 'date' ]
        self.state_index = 0

        tasmota.add_rule("Button1#State", / value, trigger, msg -> self.on_button_prev(value, trigger, msg))
        tasmota.add_rule("Button3#State", / value, trigger, msg -> self.on_button_next(value, trigger, msg))
    end

    def every_second()
        self.brightness = self.printer.recommend_brightness()
        
        # do state action
        var state = self.state_list[self.state_index]
        if state == 'time'
            self.print_time()
        elif state == 'date'
            self.print_date()
        else
            print("Unknown state: ", state)
        end

        self.printer.draw()
    end

    def on_button_prev(value, trigger, msg)
        # print(value)
        # print(trigger)
        # print(msg)
        self.state_index = (self.state_index + 1) % size(self.state_list)
        self.printer.clear()
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

    def print_date()
        var rtc = tasmota.rtc()
        var time_dump = tasmota.time_dump(rtc['local'])

        var day = time_dump['day']
        var month = time_dump['month']

        var x_offset = 5
        var y_offset = 1

        self.printer.print_char(str(day / 10), 0 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.printer.print_char(str(day % 10), 4 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.printer.print_char('/',           8 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.printer.print_char(str(month / 10), 12 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.printer.print_char(str(month % 10), 16 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
    end

    def digit_clock(time_dump)
        var sec = time_dump['sec']
        var min = time_dump['min']
        var hour = time_dump['hour']

        var x_offset = 4
        var y_offset = 1

        self.printer.print_char(str(hour / 10), 0 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.printer.print_char(str(hour % 10), 4 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.printer.print_char(str(min / 10), 9 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.printer.print_char(str(min % 10), 13 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        # print("sec: ", sec)
        self.printer.print_char(str(sec / 10), 18 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
        self.printer.print_char(str(sec % 10), 22 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
    end
end

var clock = module("clock")
clock.driver = ClockDriver()

return clock