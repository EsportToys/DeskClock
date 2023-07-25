# DeskClock
A simple analog clock written in AutoIt

![image](https://github.com/EsportToys/DeskClock/assets/98432183/e04adf43-0d30-417c-9edc-a18229639d99)

## Features
* Literally just a clock
* Draggable and always on top, but does not steal window focus.
* Tray icon to toggle visibility. No extra icon in taskbar.
* Customization via .ini, timezone offset via cmdline flag

## Configuration
Edit the `options.ini` file located at the script's working directory.

Out-of-box values:
```
[Options]
ClockRadius=60
HoursRadius=25
MinutesRadius=42
SecondsRadius=50
InnerRadius60=57
InnerRadius12=45
HubRadius=2
ClockColor=0xffffff
BaseColor=0x000000
BaseOpacity=192
HoursColor=0xffff00
MinutesColor=0x00ffff
SecondsColor=0xff00ff
```

## Command Line

You can change the hours offset from your system time by launching with the desired value as a flag.

For example:

```
<regular command to launch DeskClock> -3
```

will launch the clock with a negative three hour offset from the system hour.

You can set the flag as a shortcut to the .vbs stub itself:

![image](https://github.com/EsportToys/DeskClock/assets/98432183/bcb2fd55-5806-416c-a217-979a091f30df)
