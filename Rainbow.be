import animate
class Rainbow_stripes : Leds_animator
  var cur_offset     # current offset in the palette
  static palette = [ 0xFF0000, #- red -#
                     0xFFA500, #- orange -#
                     0xFFFF00, #- yellow -#
                     0x008800, #- green -#
                     0x0000FF, #- blue -#
                     0x4B0082, #- indigo -#
                     0xEE82EE, #- violet -#
                  ]

  # duration in seconds
  def init(strip, duration)
    super(self).init(strip)
    self.cur_offset = 0
    # add an animator to change `self.cur_offset` to each value of the palette
    self.add_anim(animate.rotate(def(v) self.cur_offset = v end, 0, size(self.palette), int(duration * 1000)))
  end

  def animate()
    var i = 0
    while i < self.pixel_count    # doing a loop rather than a `for` prevents from allocating a new object
      var col = self.palette[(self.cur_offset + i) % size(self.palette)]
      self.strip.set_pixel_color(i, col, self.bri)   # simulate the method call without GETMET
      i += 1
    end
    self.strip.show()
  end
end

var leds = Leds(256, gpio.pin(gpio.WS2812, 32))
var strip = leds.create_matrix(8,32)
var r = Rainbow_stripes(strip, 15.0)
r.start()