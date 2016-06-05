#include-once

#cs
	NBioAPI for AutoIt
	http://github.com/jesobreira/nitgenbio_au3
#ce

Global $oMyError = ObjEvent("AutoIt.Error","MyErrFunc")
OnAutoItExitRegister("_NShutdown")

#Region Constants
Global Const $NBioAPI_FIR_DATA_TYPE_RAW               = 0x00
Global Const $NBioAPI_FIR_DATA_TYPE_INTERMEDIATE      = 0x01
Global Const $NBioAPI_FIR_DATA_TYPE_PROCESSED         = 0x02
Global Const $NBioAPI_FIR_DATA_TYPE_ENCRYPTED         = 0x10
Global Const $NBioAPI_FIR_DATA_TYPE_LINEPATTERN       = 0x20

Global Const $NBioAPI_FIR_PURPOSE_VERIFY                          = 0x01
Global Const $NBioAPI_FIR_PURPOSE_IDENTIFY                        = 0x02
Global Const $NBioAPI_FIR_PURPOSE_ENROLL                          = 0x03
Global Const $NBioAPI_FIR_PURPOSE_ENROLL_FOR_VERIFICATION_ONLY    = 0x04
Global Const $NBioAPI_FIR_PURPOSE_ENROLL_FOR_IDENTIFICATION_ONLY  = 0x05
Global Const $NBioAPI_FIR_PURPOSE_AUDIT                           = 0x06
Global Const $NBioAPI_FIR_PURPOSE_UPDATE                          = 0x10

Global Const $NBioAPI_FIR_FORMAT_STANDARD          = 1
Global Const $NBioAPI_FIR_FORMAT_NBAS              = 2
Global Const $NBioAPI_FIR_FORMAT_EXTENSION         = 3
Global Const $NBioAPI_FIR_FORMAT_STANDARD_AES      = 4
Global Const $NBioAPI_FIR_FORMAT_STANDARD_3DES     = 5
Global Const $NBioAPI_FIR_FORMAT_STANDARD_256AES   = 6

Global Const $NBioAPI_FIR_SECURITY_LEVEL_LOWEST        = 1
Global Const $NBioAPI_FIR_SECURITY_LEVEL_LOWER         = 2
Global Const $NBioAPI_FIR_SECURITY_LEVEL_LOW           = 3
Global Const $NBioAPI_FIR_SECURITY_LEVEL_BELOW_NORMAL  = 4
Global Const $NBioAPI_FIR_SECURITY_LEVEL_NORMAL        = 5
Global Const $NBioAPI_FIR_SECURITY_LEVEL_ABOVE_NORMAL  = 6
Global Const $NBioAPI_FIR_SECURITY_LEVEL_HIGH          = 7
Global Const $NBioAPI_FIR_SECURITY_LEVEL_HIGHER        = 8
Global Const $NBioAPI_FIR_SECURITY_LEVEL_HIGHEST       = 9

Global Const $NBioAPI_DEVICE_ID_NONE   = 0x0000
Global Const $NBioAPI_DEVICE_ID_AUTO   = 0x00ff

Global Const $NBioAPI_DEVICE_NAME_FDP02            = 0x01      ; Parallel type
Global Const $NBioAPI_DEVICE_NAME_FDU01            = 0x02      ; USB type HFDU 01/04/06
Global Const $NBioAPI_DEVICE_NAME_OSU02            = 0x03      ; Not used..
Global Const $NBioAPI_DEVICE_NAME_FDU11            = 0x04      ; USB type HFUD 11/14
Global Const $NBioAPI_DEVICE_NAME_FSC01            = 0x05      ; SmartCombo
Global Const $NBioAPI_DEVICE_NAME_FDU03            = 0x06      ; USB type Mouse
Global Const $NBioAPI_DEVICE_NAME_FDU05            = 0x07      ; USB type HFDU 05/07
Global Const $NBioAPI_DEVICE_NAME_FDU08            = 0x08      ; USB type HFDU 08

Global Const $NBioAPI_DEVICE_NAME_ADDITIONAL       = 0x10      ; Additional Device
Global Const $NBioAPI_DEVICE_NAME_ADDITIONAL_MAX   = 0x9F

Global Const $NBioAPI_DEVICE_NAME_NND_URU4KB       = 0xA1      ; UareU4000B
Global Const $NBioAPI_DEVICE_NAME_NND_FPC6410      = 0xA2      ; FPC6410

Global Const $NBioAPI_MAX_DEVICE                   = 0xfe

Global Const $NBioAPI_FIR_FORM_HANDLE        = 0x02
Global Const $NBioAPI_FIR_FORM_FULLFIR       = 0x03
Global Const $NBioAPI_FIR_FORM_TEXTENCODE    = 0x04

Global Const $NBioAPI_NO_TIMEOUT              = 0
Global Const $NBioAPI_USE_DEFAULT_TIMEOUT     = -1
Global Const $NBioAPI_CONTINUOUS_CAPTRUE      = -2

Global Const $NBioAPI_WINDOW_STYLE_POPUP        = 0
Global Const $NBioAPI_WINDOW_STYLE_INVISIBLE    = 1            ; only for NBioAPI_Capture=
Global Const $NBioAPI_WINDOW_STYLE_CONTINUOUS   = 2

Global Const $NBioAPI_WINDOW_STYLE_NO_FPIMG     = 0x00010000   ; Or flag
Global Const $NBioAPI_WINDOW_STYLE_TOPMOST      = 0x00020000   ; Or flag : default flag and not used after v2.3 = WinCE v1.2
Global Const $NBioAPI_WINDOW_STYLE_NO_WELCOME   = 0x00040000   ; Or flag : only for enroll
Global Const $NBioAPI_WINDOW_STYLE_NO_TOPMOST   = 0x00080000   ; Or flag : additional flag after v2.3 = WinCE v1.2

Global Const $NBioAPI_FINGER_ID_UNKNOWN         = 0
Global Const $NBioAPI_FINGER_ID_RIGHT_THUMB     = 1
Global Const $NBioAPI_FINGER_ID_RIGHT_INDEX     = 2
Global Const $NBioAPI_FINGER_ID_RIGHT_MIDDLE    = 3
Global Const $NBioAPI_FINGER_ID_RIGHT_RING      = 4
Global Const $NBioAPI_FINGER_ID_RIGHT_LITTLE    = 5
Global Const $NBioAPI_FINGER_ID_LEFT_THUMB      = 6
Global Const $NBioAPI_FINGER_ID_LEFT_INDEX      = 7
Global Const $NBioAPI_FINGER_ID_LEFT_MIDDLE     = 8
Global Const $NBioAPI_FINGER_ID_LEFT_RING       = 9
Global Const $NBioAPI_FINGER_ID_LEFT_LITTLE     = 10
Global Const $NBioAPI_FINGER_ID_MAX             = 11

Global Const $NBioAPI_QUALITY_NONE        = 0
Global Const $NBioAPI_QUALITY_BAD         = 1
Global Const $NBioAPI_QUALITY_POOR        = 2
Global Const $NBioAPI_QUALITY_NORMAL      = 3
Global Const $NBioAPI_QUALITY_GOOD        = 4
Global Const $NBioAPI_QUALITY_EXCELLENT   = 5
#EndRegion


; Object instancing
Global $objNBioBSP = ObjCreate("NBioBSPCOM.NBioBSP")
If Not @error Then
   Global $objDevicesList = ObjCreate("Scripting.Dictionary")
   Global $iLastDevice,$iOpenedDevice

   ; Methods/properties
   Global $objDevice = $objNBioBSP.Device
   Global $objExtraction = $objNBioBSP.Extraction
   Global $objMatching = $objNBioBSP.Matching
   Global $objFPData = $objNBioBSP.FPData
   Global $objFPImage = $objNBioBSP.FPImage
   Global $objIndexSearch = $objNBioBSP.IndexSearch
   Global $objNSearch = $objNBioBSP.NSearch

   Global $bUnderError = False
Else
   Global $bUnderError = True
EndIf

Func _NEnumerate()
   If $bUnderError Then Return SetError(1, 0, 0)
	$objDevicesList.RemoveAll
	$objDevice.Enumerate
	For $iDeviceNumber = 0 To $objDevice.EnumCount-1
		$iDeviceID = $objDevice.EnumDeviceID($iDeviceNumber)
		$sDeviceName = $objDevice.EnumDeviceName($iDeviceNumber)
		$objDevicesList.Add($iDeviceNumber, $iDeviceID )
		$iLastDevice = $iDeviceID
		_NDebug("Device found: " & $iDeviceID & $sDeviceName)
	Next
	Return $objDevice.EnumCount
EndFunc

Func _NOpen($iDevice = Default)
   If $bUnderError Then Return SetError(1, 0, 0)
	If $iDevice = Default Then $iDevice = $iLastDevice
	$objDevice.Open($iDevice)
	If $objDevice.ErrorCode Then Return SetError($objDevice.ErrorCode, 0, False)
	$iOpenedDevice = $iDevice
	Return True
EndFunc

Func _NEnroll($sPayload = Null)
   If $bUnderError Then Return SetError(1, 0, 0)
	$objExtraction.Enroll($sPayload, null)
	If $objExtraction.ErrorCode = 0 Then
		Return $objExtraction.TextEncodeFIR
	Else
		Return SetError($objExtraction.ErrorCode, 0, False)
	EndIf
EndFunc

Func _NCreateTemplate($sFIR, $sPayload)
   If $bUnderError Then Return SetError(1, 0, 0)
	$objFPData.CreateTemplate($sFIR, null, $sPayload)
	If $objFPData.ErrorCode = 0 Then
		Return $objFPData.TextEncodeFIR
	Else
		Return SetError($objFPData.ErrorCode, 0, False)
	EndIf
EndFunc

Func _NVerify($sStoredData)
   If $bUnderError Then Return SetError(1, 0, 0)
	$objMatching.Verify($sStoredData)
	Local $result = $objMatching.MatchingResult
	If $result Then
		If $objMatching.ExistPayload Then
			Return $objMatching.TextEncodePayload
		Else
			Return True
		EndIf
	Else
		Return False
	EndIf
EndFunc

Func _NVerifyMatch($sGotFIR, $sStoredFIR)
   If $bUnderError Then Return SetError(1, 0, 0)
	$objMatching.VerifyMatch($sGotFIR, $sStoredFIR)
	Local $result = $objMatching.MatchingResult
	If $result Then
		If $objMatching.ExistPayload Then
			Return $objMatching.TextEncodePayload
		Else
			Return True
		EndIf
	Else
		Return False
	EndIf
EndFunc

Func _NCapture()
   If $bUnderError Then Return SetError(1, 0, 0)
	$objExtraction.Capture($NBioAPI_FIR_PURPOSE_VERIFY)
	If $objExtraction.ErrorCode Then
		Return SetError($objExtraction.ErrorCode, 0, False)
	Else
		Return $objExtraction.TextEncodeFIR
	EndIf
EndFunc

Func _NSearch_Add($sFIR, $iUserID)
   If $bUnderError Then Return SetError(1, 0, 0)
	Return $objNSearch.AddFIR($sFIR, $iUserID)
EndFunc

Func _NSearch_Identify($sFIR, $iSecurity = 5)
   If $bUnderError Then Return SetError(1, 0, 0)
	$objNSearch.IdentifyUser($sFIR, $iSecurity)
	If $objNSearch.ErrorCode Then
		Return SetError($objNSearch.ErrorCode, 0, False)
	Else
		Return $objNSearch.UserID
	EndIf
EndFunc

Func _NClose($iDevice = Default)
   If $bUnderError Then Return SetError(1, 0, 0)
	If $iDevice = Default Then $iDevice = $iOpenedDevice
	$objDevice.Close($iDevice)
EndFunc

Func _NShutdown()
	$objNBioBSP = Null
EndFunc


Func MyErrFunc()
   ;If @Compiled Then Return SetError(@error, @extended, False)
	Local $HexNumber
	Local $strMsg
	$HexNumber = Hex($oMyError.Number, 8)
	$strMsg = "Error Number: " & $HexNumber & @CRLF
	$strMsg &= "WinDescription: " & $oMyError.WinDescription & @CRLF
	$strMsg &= "Script Line: " & $oMyError.ScriptLine & @CRLF
	_NDebug($strMsg)
	SetError(1)
Endfunc

Func _NDebug($ln)
	If Not @compiled Then ConsoleWrite("[NITGEN] " & $ln & @CRLF)
EndFunc
