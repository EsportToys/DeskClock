Set WshShell = WScript.CreateObject("WScript.Shell")
If WScript.Arguments.Count > 0 Then 
   WshShell.Run ".\src\AutoIt3_x64.exe .\src\clock.au3 " & WScript.Arguments(0)
Else
   WshShell.Run ".\src\AutoIt3_x64.exe .\src\clock.au3"
End If 