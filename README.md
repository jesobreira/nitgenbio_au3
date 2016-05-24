NBioBSP for AutoIt
==================

This lib is to work with Nitgen fingerprint scanners/readers that communicate through the NBioBSP interface.

Example:

```
$iDevices = _NEnumerate() ; Enumerate all devices
_NOpen() ; open device
$sCapture = _NCapture() ; It will generate a string with the fingerprint data (something like a password)
MsgBox(0, "Your fingerprint means:", $sCapture) ; Easy, huh?
```

[Full example](Example.au3)

Functions
----

### _NEnumerate()
Enumerates all connected devices, saves them in the `$objDevicesList` scripting.dictionary object as device number => device ID and returns the number of connected devices.

### _NOpen( [ $iDevice = Default ] )
Opens a device for communicating (device ID is optional, and if not supplied, the latest connected device will be selected).

### _NClose ( [ $iDevice = Default ] )
Closes a device (you must do it before opening a new device).

### _NEnroll ( [ $sPayload = Null ] )
Registers a fingerprint (multiple fingers allowed) and returns its string (note that the lib will not save anything, and you must save the fingerprint strings (FIR) on your database or whatever else). The payload is an optional parameter that can be a string that will be put together onto the FIR string (useful for storing user ID or even name).

### _NCreateTemplate ( $sFIR , $sPayload )
Returns a new FIR with the payload changed to `$sPayload`.

### _NVerify ( $sStoredData )
Asks the user to put finger in the device and checks if it's equal to the FIR string provided as `$sStoredData`. Will return False if not equal, the payload string or True if equal.

### _NVerifyMatch ( $sGotFIR , $sStoredFIR )
Similar to _NVerify but it won't ask the user to put the finger on the reader. The FIR data will be supplied by you as ´$sGotFIR` (it can be the return value of _NCapture() or something from database). Returns the same as _NVerify.

### NCapture()
Ask the user to put his finger and captures it quickly, returning the FIR string (no payload will be added).

### _NSearch_Add( $sFIR , $iUserID )
Adds a new FIR and associated user ID (of your choice) for a search.

### _NSearch_Identify( $sFIR [ , $iSecurity = $NBioAPI_FIR_SECURITY_LEVEL_NORMAL ] )
Searches $sFIR (it can be the return value of _NCapture() or something from database) on the current search stack (managed with _NSearch_Add()) and returns the user ID whose fingerprint is equal to $sFIR or False if no one was found.