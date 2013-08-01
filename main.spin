con

  _clkmode = xtal1 + pll16x                                     ' run @ 80MHz in XTAL mode
  _xinfreq = 5_000_000                                          ' use 5MHz crystal
                                                                                                        
  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  'MS_001   = CLK_FREQ / 1_000
  'US_001   = CLK_FREQ / 1_000_000

OBJ
  pst           : "Parallax Serial Terminal"
  leftStrip     : "RGBStrip" 
  rightStrip    : "RGBStrip"
  pst1  : "FullDuplexSerial"
  XBEE : "FullDuplexSerial"

var
  long c1, c2, v1, buff, incoming
  
pub main | i
  XBEE.Start(2,4,%0000,9_600)
  pst1.Start(0,1,%0000,9_600)
  dira[23]~~
  dira[16]~~
  OUTA[16] := 1
  OUTA[23] := 1
  'leftStrip.start(5,0)
  'rightStrip.start(5,1)
  repeat
   incoming := pst1.RxCheck 
    if(incoming > 0)       
      XBEE.tx(incoming)
      leftStrip.start(incoming, 0)
      rightStrip.start(incoming, 1) 
      incoming := -1
      !OUTA[16]
   buff := XBEE.RxCheck  
    if(buff > 0)
      leftStrip.start(buff, 0)
      rightStrip.start(buff, 1) 
      pst1.tx(buff) 
      buff := -1
      !OUTA[23]
  
 {{ dira[16]~~ 
  repeat
    repeat i from 1 to 1
      !OUTA[16]
      'leftStrip.start(0,0)
      'rightStrip.start(0,1)
      'waitcnt(80_000 + cnt)
      leftStrip.start(i,0)
      rightStrip.start(i,1)
      'pst.dec(c1)
      'pst.str(string(13))
      waitcnt(CLKFREQ*8 + cnt) }}
    
    