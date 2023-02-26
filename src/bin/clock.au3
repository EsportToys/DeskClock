#OnAutoItStartRegister SetProcessDPIAware

Global Const $iniPath = 'options.ini'
Global Const $user32 = DllOpen('user32.dll')
Global Const $CLOCK_RADIUS = IniRead($iniPath,'Options','ClockRadius',120)
Global Const $CLOCK_WIDTH = $CLOCK_RADIUS*2 + 1
Global Const $CLOCK_HRS_RADIUS = IniRead($iniPath,'Options','HoursRadius',50)
Global Const $CLOCK_MIN_RADIUS = IniRead($iniPath,'Options','MinutesRadius',95)
Global Const $CLOCK_SEC_RADIUS = IniRead($iniPath,'Options','SecondsRadius',100)
Global Const $CLOCK_INNER_RADIUS_60 = IniRead($iniPath,'Options','InnerRadius60',110)
Global Const $CLOCK_INNER_RADIUS_12 = IniRead($iniPath,'Options','InnerRadius12',100)
Global Const $CLOCK_HUB_RADIUS = IniRead($iniPath,'Options','HubRadius',5)
Global Const $DEFAULT_CLOCK_COLOR = IniRead($iniPath,'Options','ClockColor',0xffffff)
Global Const $DEFAULT_BASE_COLOR = IniRead($iniPath,'Options','BaseColor',0x000000)
Global Const $DEFAULT_BASE_OPACITY = IniRead($iniPath,'Options','BaseOpacity',128)
Global Const $CLOCK_HRS_COLOR = IniRead($iniPath,'Options','HoursColor',$DEFAULT_CLOCK_COLOR)
Global Const $CLOCK_MIN_COLOR = IniRead($iniPath,'Options','MinutesColor',$DEFAULT_CLOCK_COLOR)
Global Const $CLOCK_SEC_COLOR = IniRead($iniPath,'Options','SecondsColor',$DEFAULT_CLOCK_COLOR)
Global $HOURS_OFFSET = 0
If $CmdLine[0]>0 Then
   If $CmdLine[1]<>0 Then $HOURS_OFFSET = Round($CmdLine[1])
EndIf


Opt('GUIOnEventMode',1)
Opt('TrayMenuMode',1+2)
Opt("TrayOnEventMode", 1)
TraySetClick(16)
TraySetOnEvent(-8,ToggleVisible)
TrayItemSetOnEvent(TrayCreateItem('Reset'),ResetPosition)
TrayItemSetOnEvent(TrayCreateItem('Quit'),Quit)

Global $isDragging = False


Global $hSysTray = WinGetHandle('[Class:Shell_TrayWnd]')
Global $clockColor = $DEFAULT_CLOCK_COLOR, $baseColor = $DEFAULT_BASE_COLOR
Global $winWidth = $CLOCK_WIDTH, $winHeight = $CLOCK_WIDTH
Global $winPos = CalculateWinPos($winWidth,$winHeight,WinGetPos($hSysTray))

Global $hOverlay = GUICreate('',$winWidth,$winHeight,$winPos[0],$winPos[1],0x80000000,0x0A080088)
GUISetBkColor($clockColor,$hOverlay)
GUISetOnEvent(-7,OnPrimaryDown)
GUISetOnEvent(-10,ToggleVisible)
Global $hBase = GUICtrlCreateGraphic($winWidth/2,$winHeight/2,0,0)
GUICtrlSetGraphic($hBase, 8, $baseColor, $baseColor)
GUICtrlSetGraphic($hBase,12,-$CLOCK_RADIUS,-$CLOCK_RADIUS,$CLOCK_RADIUS*2+1,$CLOCK_RADIUS*2+1)
DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $hOverlay, "INT", BitShift($clockColor,16) + BitAnd(0x00ff00,$clockColor) + BitShift(BitAnd(0x0000ff,$clockColor),-16), "byte", $DEFAULT_BASE_OPACITY, "dword", 0x03)

Global $hWnd = GUICreate('',$winWidth,$winHeight,3,3,0x80000000,0x0A080048,$hOverlay)
GUISetBkColor(0xfe00fe,$hWnd)
GUISetOnEvent(-7,OnPrimaryDown)
GUISetOnEvent(-10,ToggleVisible)
DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $hWnd, "INT", 0x00fe00fe, "byte", 255, "dword", 0x03)
Global $hBuffer = [GUICtrlCreateGraphic($winWidth/2,$winHeight/2,0,0),GUICtrlCreateGraphic($winWidth/2,$winHeight/2,0,0)]
Global $hFront = 0, $lastSecAng = @SEC*6
Global $hTicks = DrawTicks($hWnd,$clockColor)
Global $CURRENT_HANDS_WINDOW = $hWnd
DrawHands($CURRENT_HANDS_WINDOW)
GUISetState(@SW_SHOW,$hOverlay)
GUISetState(@SW_SHOW,$hWnd)
AdlibRegister(UpdateHands,50)

While Sleep(1000)
WEnd
Func OnPrimaryDown()
     DllCall($user32,"int","SendMessage","hWnd", $hOverlay,"int",0xA1,"int", 2,"int", 0)
     GUISetOnEvent(-11,OnMouseMove,$hOverlay)
     GUISetOnEvent(-11,OnMouseMove,$hWnd)
     GUISetOnEvent(-8,Unsubscribe,$hOverlay)
     GUISetOnEvent(-8,Unsubscribe,$hWnd)
EndFunc
Func Unsubscribe()
     GUISetOnEvent(-11,'',$hOverlay)
     GUISetOnEvent(-11,'',$hWnd)
     GUISetOnEvent(-8,'',$hOverlay)
     GUISetOnEvent(-8,'',$hWnd)
EndFunc
Func OnMouseMove()
     If BitAnd(0x8000,DllCall($user32,'short','GetAsyncKeyState','int',1)[0]) Then DllCall($user32,"int","SendMessage","hWnd", $hOverlay,"int",0xA1,"int", 2,"int", 0)
EndFunc
Func CalculateWinPos($w,$h,$trayPos)
     Local $a = [0,0]
     If $trayPos[0]>0 Then ; Right
        $a[0] = @DesktopWidth-$trayPos[2]-$w
        $a[1] = @DesktopHeight - $h
     ElseIf $trayPos[1]>0 Then ; Bottom
        $a[0] = @DesktopWidth - $w
        $a[1] = @DesktopHeight-$trayPos[3]-$h
     ElseIf $trayPos[2]>$trayPos[3] Then ; Top
        $a[0] = @DesktopWidth - $w
        $a[1] = $trayPos[3]
     Else ; $Left
        $a[0] = $trayPos[2]
        $a[1] = @DesktopHeight - $h
     EndIf
     Return $a
Endfunc

Func Quit()
     Exit
EndFunc

Func ToggleVisible()
     Local Static $visible = True
     $visible = not $visible
     GUISetState($visible?@SW_SHOW:@SW_HIDE,$hOverlay)
     GUISetState($visible?@SW_SHOW:@SW_HIDE,$hWnd)
EndFunc

Func ResetPosition()
     Local $pos = CalculateWinPos($winWidth,$winHeight,WinGetPos($hSysTray))
     WinMove($hOverlay,'',$pos[0],$pos[1])
EndFunc

Func DrawTicks($target,$color)
     GUISwitch($target)
     Local $h = GUICtrlCreateGraphic($winWidth/2,$winHeight/2,0,0), $R = Round
     GUICtrlSetState($h,32)
     For $i=0 to 59
         Local $inner = Mod($i,5)?$CLOCK_INNER_RADIUS_60:$CLOCK_INNER_RADIUS_12, $outer = $CLOCK_RADIUS+1
         GUICtrlSetGraphic($h,24, 1)
         GUICtrlSetGraphic($h, 8, $color)
         GUICtrlSetGraphic($h, 6, $R($inner*sin(Rad($i*6))), -$R($inner*cos(Rad($i*6))))
         GUICtrlSetGraphic($h, 2, $R($outer*sin(Rad($i*6))), -$R($outer*cos(Rad($i*6))))
     Next
     GUICtrlSetGraphic($h, 8, $clockColor, $clockColor)
     GUICtrlSetGraphic($h,12,-$CLOCK_HUB_RADIUS,-$CLOCK_HUB_RADIUS,$CLOCK_HUB_RADIUS*2+1,$CLOCK_HUB_RADIUS*2+1)
     GUICtrlSetState($h,16)
     Return $h
EndFunc

Func UpdateHands()
     If $lastSecAng = @SEC*6 Then Return
     DrawHands($CURRENT_HANDS_WINDOW)
EndFunc

Func DrawHands($target)
     Local $angSec = 6*@SEC
     Local $angMin = 6*@MIN + $angSec/60
     Local $angHrs = 30*Mod( @HOUR+$HOURS_OFFSET , 12 ) + $angMin/12
     $lastSecAng = $angSec
     Local $frontIndex = $hFront
     Local $backIndex = not $frontIndex
     GUISwitch($target)
     Local $new = GUICtrlCreateGraphic($winWidth/2,$winHeight/2,0,0), $R = Round
     GUICtrlSetState($new,32)
     GUICtrlSetGraphic($new, 6, 0, 0)
     GUICtrlSetGraphic($new,24, 3)
     GUICtrlSetGraphic($new, 8, $CLOCK_MIN_COLOR)
     GUICtrlSetGraphic($new, 2, $R($CLOCK_MIN_RADIUS*sin(Rad($angMin))), -$R($CLOCK_MIN_RADIUS*cos(Rad($angMin))))
     GUICtrlSetGraphic($new, 6, 0, 0)
     GUICtrlSetGraphic($new,24, 3)
     GUICtrlSetGraphic($new, 8, $CLOCK_HRS_COLOR)
     GUICtrlSetGraphic($new, 2, $R($CLOCK_HRS_RADIUS*sin(Rad($angHrs))), -$R($CLOCK_HRS_RADIUS*cos(Rad($angHrs))))
     GUICtrlSetGraphic($new, 6, 0, 0)
     GUICtrlSetGraphic($new,24, 1)
     GUICtrlSetGraphic($new, 8, $CLOCK_SEC_COLOR)
     GUICtrlSetGraphic($new, 2, $R($CLOCK_SEC_RADIUS*sin(Rad($angSec))), -$R($CLOCK_SEC_RADIUS*cos(Rad($angSec))))
     GUICtrlDelete($hBuffer[$backIndex])
     $hBuffer[$backIndex] = $new
     GUICtrlSetState($hBuffer[$backIndex],16)
     GUICtrlSetState($hBuffer[$frontIndex],32)
     $hFront = not $hFront
EndFunc

Func Rad($deg)
     Local Static $fac = Atan(1) / 45
     Return $deg * $fac
EndFunc

Func SetProcessDPIAware()
     GUICreate("")
     DllCall("user32.dll", "bool", "SetProcessDPIAware")
     GUIDelete()
EndFunc
