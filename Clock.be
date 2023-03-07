var row_size = 8
var col_size = 32

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
        print("RTC: ", rtc)
        var time_dump = tasmota.time_dump(rtc['local'])
        print("Time: ", time_dump)
    end
end

clock = ClockDriver()

# Test
clock.every_second()

# Add to Tasmota
# tasmota.add_driver(clock)