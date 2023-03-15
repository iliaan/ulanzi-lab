class Buttons
    var driver_list = []

    def add_driver(driver)
        driver_list.push(driver)
    end

    def on_button_prev(value, trigger, msg)
        print(value)
        print(trigger)
        print(msg)
    end

    def on_button_action(value, trigger, msg)
        print(value)
        print(trigger)
        print(msg)
    end

    def on_button_next(value, trigger, msg)
        print(value)
        print(trigger)
        print(msg)
    end

    def init()
        print("Buttons init")
        tasmota.add_rule("Button1#State", / value, trigger, msg -> self.on_button_prev(value, trigger, msg))
        tasmota.add_rule("Button2#State", / value, trigger, msg -> self.on_button_action(value, trigger, msg))
        tasmota.add_rule("Button3#State", / value, trigger, msg -> self.on_button_next(value, trigger, msg))
    end
end

bb = Buttons()