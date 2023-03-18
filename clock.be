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
        var time_str = tasmota.strftime('%H:%M:%S', rtc['local'])
        var x_offset = 0
        var y_offset = 1
        self.printer.print_string(time_str, 0 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
    end

    def print_date()
        var rtc = tasmota.rtc()
        var time_dump = tasmota.time_dump(rtc['local'])

        var day = time_dump['day']
        var month = time_dump['month']
        var weekday = time_dump['weekday']
        var weekday_list = [ 'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT' ]

        var x_offset = 0
        var y_offset = 1
        var date_str = weekday_list[weekday] + '|1' + str(day) + '-' + str(month)
        self.printer.print_string(date_str, 0 + x_offset, 0 + y_offset, self.colors[self.color_index], self.brightness)
    end
end

var clock = module("clock")
clock.driver = ClockDriver()

return clock