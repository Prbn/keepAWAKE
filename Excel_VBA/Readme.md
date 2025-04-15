# Steps:

1. Create a new macro-enabled workbook.
2. Open VBE, insert Module.- Paste below code into Module

### On Sheet1:
3. Create two named ranges: "statusmessage" and "TimerStop". The macro will write to these ranges. "statusmessage" will be the current status (i.e. running, or stopped) and the TimerStop will be the random time the macro will stop
4. Create two buttons. Labeled "Start" and "Stop"
5. Start button, assign to "KeepScreenActive" sub routine.
6. Stop button, assign to "stops" sub routine.


```VBA
Global blStopRequested As Boolean
Sub KeepScreenActive() 
blStopRequested = False 
updatemessage "Running", "statusmessage" 
Dim t As Date 
Dim d As Date 
Dim s As Object 
Dim rndMin As Integer 
Dim rndHr As Integer 
t = Time 
d = Now 
'Random number between 17 and 18 
rndHr = Int(17 + rnd * (18 - 17 + 1)) 
'Random number between 0 and 59 
rndMin = Int(0 + rnd * (59 - 0 + 1))
updatemessage TimeSerial(rndHr, rndMin, 0), "TimerStop"

Set s = CreateObject("WScript.Shell")
'Keep screen active - automatically stop at random time after 5pm
Do Until t > TimeSerial(rndHr, rndMin, 0)
    'Send NUMLOCK key to keep screen alive
    s.SendKeys "{NUMLOCK}"
    'Wait for 1 second
    d = Now
    Do While DateDiff("s", d, Now()) < 1
        DoEvents
    Loop
    'Restore NUMLOCK to prior position
    s.SendKeys "{NUMLOCK}"
    'Wait for 1 second
    d = Now
    Do While DateDiff("s", d, Now()) < 1
        DoEvents
    Loop
    
    'wait 2 mins - verify that STOP button hasn't been clicked. Stop if clicked.
    d = Now
    Do While DateDiff("n", d, Now()) < 2
        DoEvents
        If blStopRequested = True Then
            blStopRequested = False
            updatemessage "Stopped", "statusmessage"
            Exit Sub
        End If
    Loop
    t = Time
     
Loop
updatemessage "Stopped", "statusmessage"
End Sub

Sub stops() 
    blStopRequested = True 
End Sub

Sub updatemessage(strMessage As String, strRangeName As String) 'Writes a string to a named range on the worksheet. 
'Inputs: 
' strMessage = The string to write to the worksheet 
' strRangeName = The 'Name' of the target range to write the value. Must be an address, or named range string.
Dim wb As Workbook
Dim ws As Worksheet
Dim rng As Range
Set wb = ThisWorkbook
Set ws = Sheet1

ws.Range(strRangeName).Value = strMessage

Set rng = Nothing
Set ws = Nothing
Set wb = Nothing
End Sub
```

## Source:
Reddit Comment by rnodern:
https://www.reddit.com/r/vba/comments/wdiiho/comment/j9wchib/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
