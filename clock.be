import printer
import fonts
import json

class ClockDriver
    var printer
    var brightness
    var color_list
    var color_index
    var state_time_list
    var state_sensor_list
    var state
    var stopwatch_start_time
    var stopwatch_stop_time
    var stopwatch_is_running
    var message

    def init()
        print("ClockDriver init")
        self.printer = printer.printer

        # set brightness to 50%
        self.brightness = 50
        self.color_list = [ fonts.palette['white'], fonts.palette['red'], fonts.palette['green'], fonts.palette['blue'] ]
        self.color_index = 0

        self.state_time_list = [ 'time', 'date', 'stopwatch', 'message' ]
        self.state_sensor_list = [ 'temperature', 'humidity', 'dewpoint', 'battery' ]
        self.state = 'time'

        self.stopwatch_start_time = 0
        self.stopwatch_stop_time = 0
        self.stopwatch_is_running = false

        self.message = 'FOLLOW THE WHITE RABBIT.'

        tasmota.add_rule("Button1#State", / value, trigger, msg -> self.on_button_prev(value, trigger, msg))
        tasmota.add_rule("Button2#State", / value, trigger, msg -> self.on_button_action(value, trigger, msg))
        tasmota.add_rule("Button3#State", / value, trigger, msg -> self.on_button_next(value, trigger, msg))
    end

    def every_second()
        self.brightness = self.printer.recommend_brightness()
        self.printer.change_font('MatrixDisplay3x5')

        # do state action
        var state = self.state
        if state == 'time'
            self.print_time()
        elif state == 'date'
            self.print_date()
        elif state == 'stopwatch'
            self.print_stopwatch()
        elif state == 'message'
            self.printer.change_font('TinyUnicode')
            self.print_message()
        elif state == 'temperature'
            self.print_temperature()
        elif state == 'humidity'
            self.print_humidity()
        elif state == 'dewpoint'
            self.print_dewpoint()
        elif state == 'battery'
            self.print_battery()
        else
            print("Unknown state: ", state)
        end

        self.printer.draw()
    end

    def on_button_prev(value, trigger, msg)
        # print(value)
        # print(trigger)
        # print(msg)

        var state_index = self.state_time_list.find(self.state)
        if nil == state_index
            state_index = 0
        else
            state_index = (state_index + 1) % size(self.state_time_list)
        end

        self.state = self.state_time_list[state_index]
        self.printer.clear()
    end

    def on_button_action(value, trigger, msg)
        # print(value)
        # print(trigger)
        # print(msg)

        var state = self.state
        if state == 'stopwatch'
            var rtc = tasmota.rtc()
            if self.stopwatch_is_running
                self.stopwatch_stop_time = rtc['local']
                self.stopwatch_is_running = false
            else
                self.stopwatch_start_time = rtc['local']
                self.stopwatch_is_running = true
                self.stopwatch_stop_time = 0
            end
        elif state == 'message'
            self.message = 'KNOK, KNOK, NEO.'
        else
            self.color_index = (self.color_index + 1) % size(self.color_list)
        end
    end

    def on_button_next(value, trigger, msg)
        # print(value)
        # print(trigger)
        # print(msg)

        var state_index = self.state_sensor_list.find(self.state)
        if nil == state_index
            state_index = 0
        else
            state_index = (state_index + 1) % size(self.state_sensor_list)
        end

        self.state = self.state_sensor_list[state_index]
        self.printer.clear()
    end

    def print_time()
        var rtc = tasmota.rtc()
        # print("RTC: ", rtc)
        var time_str = tasmota.strftime('%H:%M:%S', rtc['local'])
        var x_offset = 0
        var y_offset = 1
        self.printer.print_string(time_str, 0 + x_offset, 0 + y_offset, self.color_list[self.color_index], self.brightness)
    end

    def print_date()
        var rtc = tasmota.rtc()
        var time_dump = tasmota.time_dump(rtc['local'])

        var day = str(time_dump['day'])
        var month = str(time_dump['month'])
        var weekday = time_dump['weekday']
        var weekday_list = [ 'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT' ]

        var x_offset = 0
        var y_offset = 1

        # add zero to single digit day and month
        if time_dump['day'] < 10
            day = '0' + str(day)
        end
        if time_dump['month'] < 10
            month = '0' + str(month)
        end

        var date_str = weekday_list[weekday] + '|1' + day + '/' + month
        self.printer.print_string(date_str, 0 + x_offset, 0 + y_offset, self.color_list[self.color_index], self.brightness)
    end

    def print_stopwatch()
        var rtc = tasmota.rtc()
        var time_str = ''
        if self.stopwatch_is_running
            var time_diff = rtc['local'] - self.stopwatch_start_time
            time_str = tasmota.strftime('%H:%M:%S', time_diff)
        else
            if self.stopwatch_stop_time > 0
                var time_diff = self.stopwatch_stop_time - self.stopwatch_start_time
                time_str = tasmota.strftime('%H:%M:%S', time_diff)
            else
                time_str = '00:00:00'
            end
        end

        var x_offset = 0
        var y_offset = 1
        self.printer.print_string(time_str, 0 + x_offset, 0 + y_offset, self.color_list[self.color_index], self.brightness)
    end

    def print_temperature()
        var sensors = json.load(tasmota.read_sensors())
        var value = sensors['SHT3X']['Temperature']
        var valueUnit = sensors['TempUnit']
        var temp_str = str(value) + valueUnit
        var x_offset = 0
        var y_offset = 1
        self.printer.print_string(temp_str, 0 + x_offset, 0 + y_offset, self.color_list[self.color_index], self.brightness)
    end

    def print_humidity()
        var sensors = json.load(tasmota.read_sensors())
        var value = sensors['SHT3X']['Humidity']
        var valueUnit = '%'
        var temp_str = 'RH' + '|1' + str(value) + valueUnit
        var x_offset = 0
        var y_offset = 1
        self.printer.print_string(temp_str, 0 + x_offset, 0 + y_offset, self.color_list[self.color_index], self.brightness)
    end

    def print_dewpoint()
        var sensors = json.load(tasmota.read_sensors())
        var value = sensors['SHT3X']['DewPoint']
        var valueUnit = sensors['TempUnit']
        var temp_str = 'DP' + '|1' + str(value) + valueUnit
        var x_offset = 0
        var y_offset = 1
        self.printer.print_string(temp_str, 0 + x_offset, 0 + y_offset, self.color_list[self.color_index], self.brightness)
    end

    def print_battery()
        var sensors = json.load(tasmota.read_sensors())
        var value = sensors['ANALOG']['A1']
        var valueUnit = '%'
        var min = 2000
        var max = 2600
        if value < min
            value = min
        end
        if value > max
            value = max
        end
        value = int(((value - min) * 100) / (max - min))
        var temp_str = 'BAT' + '|1' + str(value) + valueUnit + '  '
        var x_offset = 0
        var y_offset = 1
        self.printer.print_string(temp_str, 0 + x_offset, 0 + y_offset, self.color_list[self.color_index], self.brightness)
    end

    def print_message()
        var x_offset = 0
        var y_offset = 1
        self.printer.print_long_string(self.message, 0 + x_offset, 0 + y_offset, 0x03A062, self.brightness)
    end
end

var clock = module("clock")
clock.driver = ClockDriver()

return clock