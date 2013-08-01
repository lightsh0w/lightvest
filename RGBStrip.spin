con
  white         = $808080
  black         = $000000
  leds          = 32
  
OBJ
  pst           : "Parallax Serial Terminal"

var
  long stack[256]
  long MS_001
  long US_001
  long US_1000
  byte SPI_CLK_PIN
  byte SPI_DAT_PIN
  byte cog
  
pub start(show, side, primary, secondary, tertiary)         
  stop
  return cog := cognew(runShow(show, side, primary, secondary, tertiary), @stack)
  
pub stop     
  if(cog)                
    cogstop(cog)
    cog := 0

pub runShow(show, side, primary, secondary, tertiary)
  if(side == 1)
    SPI_CLK_PIN := 6
    SPI_DAT_PIN := 3
  else
    SPI_CLK_PIN := 25
    SPI_DAT_PIN := 27
  
  dira[SPI_CLK_PIN]~~           'set the pin as an output
  dira[SPI_DAT_PIN]~~           'set the pin as an output
  US_001 := CLKFREQ / 1_000_000
  US_1000 := US_001 * 1000              
  MS_001 := CLKFREQ / 1_000

  case show
    "0":
      repeat
        clearStrip
    "1":
      repeat
        larson(primary, secondary)
    "2":
      repeat
        boom(5)                      
        waitcnt(US_1000*1000 + cnt)
    "3":
      repeat
        altCol(primary, secondary)
    "4":
      repeat
        fadeUpDown(primary)
    "5":
      repeat
        rotate(primary, secondary)
    "6":
      repeat
        on(primary)

pub larson(primary, secondary) | i, j
  'Larson Scanner                                                 
  'j = the current RGB LED you are drawing
  'i = the position of the Larson RGB LED on the strip
  repeat j from 1 to leds                        'count up for Larson to go from beggining
    repeat i from 1 to leds
      if i == j
        pushColor(secondary)
      else
        pushColor(primary)
    latchStrip
  repeat j from leds to 1                        'count down to bring larson back to start
    repeat i from 1 to leds
      if i == j
        pushColor(secondary)
      else
        pushColor(primary)
    latchStrip

pub rotate(primary, secondary)| bits, i     
  bits := %00000000000000000000000000000001
  repeat
    repeat i from 1 to leds
      if((bits >> i) == 1)
        pushColor(secondary)
      else
        pushColor(primary)
    latchStrip
    msPause(6)
    bits := bits <- 1

pub boom(count)
  'BOOM is white flash
  'count = how many flashes
  repeat count
    repeat leds                                         'For every LED
      pushColor(white)                                  'set color
    latchStrip
    msPause(2)                                          'need to pause so we can see the flash
    repeat leds
      pushColor(black)                                  'clear strip to blank RGB_LEDS
    msPause(2)

pub altCol(primary, secondary)
  repeat (leds/2)
    pushColor(primary) 
    pushColor(secondary)
  latchStrip
  waitcnt(50_000_000 + cnt)
  repeat (leds/2)
    pushColor(secondary) 
    pushColor(primary)
  latchStrip
  waitcnt(50_000_000 + cnt)

pub fadeUpDown(primary) | i       
  repeat i from $0 to $008080 step $000101
    repeat leds
      pushColor(i)
    latchStrip
    waitcnt(75_000 + cnt)
  repeat i from $008080 to $0 step $000101
    repeat leds
      pushColor(i)
    latchStrip
    waitcnt(75_000 + cnt)

pub on(primary)
  repeat leds
    pushColor(primary)
  latchStrip
  msPause(2)
  
pub clearStrip
  repeat leds
    pushColor(black)
  latchStrip
  msPause(2)

pub pushColor(value)| num_bits_minus_1
  num_bits_minus_1 := 23
  repeat 24
    ' Lower CLK pin
    outa[SPI_CLK_PIN] := 0     
    ' Place next bit out 
    outa[SPI_DAT_PIN] := (((value) >> (num_bits_minus_1--)))
    ' Raise clock
    outa[SPI_CLK_PIN] := 1

   
pub msPause(ms) | t
  'This function will pause for the amount of milliseconds asked
  repeat ms
    waitcnt(MS_001 + cnt)

pub usPause1000(us)
  'This function will pause for 1000 microseconds us amount times  
  repeat us
    waitcnt(US_1000 + cnt)
        
pub latchStrip
  'Must call this function after you have drawn all the RGB LEDs you want to display
  outa[SPI_CLK_PIN] := 0
  usPause1000(1)