def on_button(value, trigger, msg)
    print(value)
    print(trigger)
    print(msg)
end
tasmota.add_rule("Button1#State", on_button)
tasmota.add_rule("Button2#State", on_button)
tasmota.add_rule("Button3#State", on_button)