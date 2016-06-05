#include 'NGenBio.au3'


; Enumerate devices
$numberOfDevices = _NEnumerate() ; Enumerate all connected devices

If @error Then ; SDK is not installed
	MsgBox(0, "Error", "Nitgen SDK is not installed.")
	Exit
EndIf

If Not $numberOfDevices Then ; no device connected
	MsgBox(0, "Error", "You have no connected devices or the drivers are missing.")
	Exit
EndIf

; The solution for the two errors above are on the README.md file.

_NOpen() ; Open device (no argument = open latest connected device)

; ======================================================================
; Example 1: just get a fingerprint and display the string associated to it

MsgBox(0, "Your fingerprint means:", _NCapture())

; ======================================================================
; Example 2: verification (expecting for a specified person)

; Ask for name (to show how to work with payloads and store info on the fingerprint data)
$sName = InputBox("Test", "Enter your name")

$tmpData = _NEnroll($sName) ; Register a fingerprint (we will have a string to save in DB if we want; $sName will be saved together with the data)

If Not $tmpData Then Exit ; User canceled

$check = _NVerify($tmpData) ; Verify fingerprint (from the string that the registration gave us - it could have come from a database)

If $check Then
	MsgBox(0, '', 'That''s you, ' & $check & "!") ; Correct fingerprint
Else
	MsgBox(0, '', 'That''s not you!') ; Wrong fingerprint
EndIf

; ======================================================================
; Example 3: identification (expecting for anyone of a group of persons)

; Add the already saved FIR data from the previous example as ID #1
_NSearch_Add($tmpData, 1)

MsgBox(0, "", "You are now user 1. Please call someone else to register (or use different fingers/hand) to test the registration of a second person.")

$secondPersonName = InputBox("Test", "What's the name of the second person?")

; Get data
$secondperson = _NEnroll($secondPersonName)

_NSearch_Add($secondperson, 2)

; Let's ask for the fingerprint to search for
$capture = _NCapture()
$user = _NSearch_Identify($capture)
If $user Then
	MsgBox(0, "", "User: " & $user)
Else
	MsgBox(0, "", "User not found!")
EndIf


_NClose() ; Close device (no argument = close latest opened device)
