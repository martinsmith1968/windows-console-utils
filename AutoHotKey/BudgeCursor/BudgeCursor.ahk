While True
   Local $pos = MouseGetPos()
   MouseMove($pos[0]-1, $pos[1]-1, 0)
   MouseMove($pos[0], $pos[1], 0)
   Sleep(540000)
WEnd
