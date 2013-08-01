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
  LCD  : "FullDuplexSerial"
  XBEE : "FullDuplexSerial"

var
  long buff, incoming, LCD_Status, XBee_Status, p, s, t, rgbState,Show_Num
  
pub main | i
  p := $080000
  s := $000800
  t := $000008
  XBEE.Start(2,4,%0000,9_600)
  LCD.Start(0,1,%0000,9_600)
  dira[23]~~
  dira[16]~~
  OUTA[16] := 1
  OUTA[23] := 1
  LCD_Status := 0
  XBee_Status := 0
  leftStrip.start(5,0, p, s, t) 
  repeat
   incoming := LCD.RxCheck 
    if(incoming => 0)
      case LCD_Status
        0:
          case incoming
            2:       
              LCD_Status := 2
              XBEE.tx(incoming)
          
            16:
              LCD_Status := 16
              XBEE.tx(incoming)
              setState
            18:
              LCD_Status := 18
              XBEE.tx(incoming)
              setState
              rgbState++
        2:
          XBEE.tx(incoming)
          if (incoming == 4)
           LCD_Status :=0

        16: 
          XBEE.tx(incoming)
          if (rgbState == 0)
            Show_Num := incoming      
          buildColors(incoming)      
          if(colorsBuilt)
            leftStrip.start(Show_Num,0,p,s,t)
            rightStrip.start(Show_Num,1,p,s,t)
            LCD_Status := 0
       18:
         XBEE.tx(incoming)
         buildColors(incoming)      
         if(colorsBuilt)
            leftStrip.start("6",0,p,s,t)
            rightStrip.start("6",1,p,s,t)
            LCD_Status := 0
            
    incoming := -1
      !OUTA[16]
 
   buff := XBEE.RxCheck  
    if(buff => 0)
       case XBee_Status
          0:
            case buff
              2:
                 XBee_Status := 2
                 LCD.tx(buff)
          
              16:
               XBee_Status :=16
               setState
             18:
              XBee_Status := 18
              setState
              rgbState++
                
          2:
            LCD.tx(buff)
            if (buff == 4)
             XBee_Status :=0
          16: 
           if (rgbState == 0)
             Show_Num := buff      
           buildColors(buff)      
           if(colorsBuilt)
             leftStrip.start(Show_Num,0,p,s,t)
             rightStrip.start(Show_Num,1,p,s,t)
             XBee_Status := 0
        18:      
         buildColors(buff)      
         if(colorsBuilt)
            leftStrip.start("6",0,p,s,t)
            rightStrip.start("6",1,p,s,t)
            XBee_Status := 0

      buff := -1
      !OUTA[23]
  
pub setState
  p := 0
  s := 0
  t := 0
  rgbState := 0
          
pub buildColors(rgbByte)
  case rgbState
    1, 2:
      p := p + rgbByte
      p <<= 8
    3:
      p := p + rgbByte
    4, 5:
      s := s + rgbByte
      s <<= 8
    6:
      s := s + rgbByte
    7, 8:
      t := t + rgbByte
      t <<= 8
    9:
      t := t + rgbByte
  rgbState++

pub colorsBuilt
  return (rgbState == 10)
    