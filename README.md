# Ulanzi TC001
<img src="https://templates.blakadder.com/assets/images/logo.svg" alt="Tasmota" width="300"/>

## Flash Tasmota firmware

### **Warning**: 
Flashing Tasmota firmware on your device may potentially brick or damage the device. It is important to proceed with caution and to understand the risks involved before attempting to flash the firmware. Please note that any modifications to the device's firmware may void the manufacturer's warranty and may result in permanent damage to the device. It is strongly recommended to thoroughly research the flashing process and to follow instructions carefully. The user assumes all responsibility and risk associated with flashing the firmware.

To install Tasmota firmware on the Ulanzi TC001, follow these steps:

1. Download the Tasmota firmware from the [official Tasmota website](http://ota.tasmota.com/tasmota32/release/).
2. Follow installation guide [here](https://templates.blakadder.com/ulanzi_TC001.html).
3. In the Tasmota web interface, go to "Consoles" and select "Console". Enter the command "Pixels 256" to enable the 256-pixel display mode.
4. Set the time zone via the console by entering the command "Timezone +2:00".

**********************
## [Berry](https://tasmota.github.io/docs/Berry/) Rainbow
* Following guide from [here](https://tasmota.github.io/docs/Berry_Addressable-LED/)
* Go to Consoles -> Berry Scripting console
* Copy code from [Rainbow.be](Rainbow.be) to console and run
* To [Auto start](https://tasmota.github.io/docs/UFS/#autoexecbe) rainbow

![](doc/Ulanzi_Manage_File_system.png)

**********************
## Clock
* Copy [clock.be](clock.be) to [autoexec.be](https://tasmota.github.io/docs/UFS/#autoexecbe)
**********************
## Ideas
* Clock
* Sensors
* Poll some web data
* Print text in running line : News
* Alarm Clock
* Pixel Art
* Snake
**********************
## Links
* https://github.com/dhepper/font8x8
* https://github.com/Ameba8195/Arduino/blob/master/hardware_v2/cores/arduino/font5x7.h
* https://github.com/mikerr/codebug-arduino/blob/master/font4x5.h
* https://www.espruino.com/modules/Font4x4Numeric.js
* https://github.com/ninjablocks/arduino/blob/master/DMD/Font3x5.h