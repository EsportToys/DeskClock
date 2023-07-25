Set WshShell = WScript.CreateObject("WScript.Shell")
If WScript.Arguments.Count > 0 Then 
   WshShell.Run ".\bin\AutoIt3_x64.exe .\bin\clock.au3 " & WScript.Arguments(0)
Else
   WshShell.Run ".\bin\AutoIt3_x64.exe .\bin\clock.au3"
End If 