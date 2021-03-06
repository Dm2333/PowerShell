 REM ***************************************************************************  
 REM ***   Program: UserLoggedOn.vbs  
 REM ***   Author: Mick Pletcher  
 REM ***   Created: 10 January 2010  
 REM ***   Edited:  
 REM ***  
 REM ***   Description:   
 REM ***  
 REM ***************************************************************************  
 On Error Resume Next

 REM Define Global Constants  
 CONST ForReading = 1  
 CONST InputFile  = "<LOCATION>\WorkStations.txt"  
 CONST OutputFile = "<LOCATION>\output.txt"

 REM Define Global Objects  
 DIM objFSO      : Set objFSO      = CreateObject("Scripting.FileSystemObject")  
 DIM objTextFile : Set objTextFile = objFSO.OpenTextFile(InputFile, ForReading)  
 DIM objIE       : Set objIE       = CreateObject("InternetExplorer.Application")  
 DIM WshShell    : Set WshShell    = WScript.CreateObject("WScript.Shell")

 REM Define Global Variables       
 DIM arrComputers  : Set arrComputers  = Nothing  
 DIM Count         : Set Count         = Nothing  
 DIM objOutput     : Set objOutput     = Nothing  
 DIM objWMIService : Set objWMIService = Nothing  
 DIM strComputer   : Set strComputer   = Nothing  
 DIM strText       : strText           = objTextFile.ReadAll  
 DIM X             : Set X             = 1  
 DIM Total         : Set Total         = 0  
 DIM PrevTotal     : Set PrevTotal     = Nothing  

 CreateDisplayWindow()  
 objIE.Document.WriteLn "Scanning Systems..." & "<BR>"  
 objIE.Document.Write Total & "% complete" & "<BR>"  
 objTextFile.Close  
 arrComputers = Split(strText, VbCrLf)  
 Count = UBound(arrComputers)  
 Set objOutput = objFSO.CreateTextFile(OutputFile)  
 Set objOutput = objFSO.OpenTextFile  
 For Each strComputer In arrComputers  
      Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")  
      Set colItems = objWMIService.ExecQuery("Select * from Win32_ComputerSystem",,48)  
      For Each objItem in colItems  
           If IsNull(objItem.UserName) then  
                objOutput.WriteLine( strComputer & ": ")            
           else  
                objOutput.WriteLine( strComputer & ": " & objItem.UserName )  
     End IF  
   Next  
      Total = (X / Count) * 100  
      Total = Int(Total)  
      If NOT Total = PrevTotal then  
           CreateDisplayWindow()  
           objIE.Document.WriteLn "Scanning Systems..." & "<BR>"  
           objIE.Document.Write Total & "% complete" & "<BR>"  
      End If  
      PrevTotal = Total  
      X = X + 1  
 Next  
 objOutput.Close  
 Wscript.Echo " Query is complete"

 REM Cleanup Global Variables  
 Set Count         = Nothing  
 Set objFSO        = Nothing  
 Set objTextFile   = Nothing  
 Set arrComputers  = Nothing  
 Set objOutput     = Nothing  
 Set objWMIService = Nothing  
 Set strComputer   = Nothing  
 Set strText       = Nothing  

 '******************************************************************************  
 '******************************************************************************  

 Sub CreateDisplayWindow()  

      REM Define Local Constants  
      CONST strComputer = "."

      REM Define Local Objects  
      DIM objWMIService   : Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")  
      DIM colItems        : Set colItems   = objWMIService.ExecQuery ("Select PelsWidth,PelsHeight From Win32_DisplayConfiguration")  
      DIM objItem         : Set objItem    = Nothing  
      REM Define Local Variables  
      DIM intWidth        : intWidth = 500  
      DIM intHeight       : intHeight = 300  
      DIM intScreenWidth  : Set intScreenWidth = Nothing  
      DIM intScreenHeight : Set intScreenHeight = Nothing

      For Each objItem in colItems  
           intScreenWidth = objItem.PelsWidth  
           intScreenHeight = objItem.PelsHeight  
      Next  
      objIE.Navigate "about:blank"  
      objIE.Document.Title = "Users Logged On"  
      objIE.Toolbar  = 0  
      objIE.StatusBar = 0  
      objIE.AddressBar = 0  
      objIE.MenuBar  = 0  
      objIE.Resizable = 0  
      objIE.Width   = 100  
      objIE.Height   = 100  
      While objIE.ReadyState <> 4  
           WScript.Sleep 100  
      Wend  
      objIE.Left = (intScreenWidth / 2) - (intWidth / 2)  
      objIE.Top = (intScreenHeight / 2) - (intHeight / 2)  
      objIE.Visible = True  
      REM Cleanup Local Variables  
      Set colItems    = Nothing  
      Set intScreenWidth = Nothing  
      Set intScreenHeight = Nothing  
      Set intWidth    = Nothing  
      Set intHeight    = Nothing  
      Set objItem     = Nothing  
      Set objWMIService  = Nothing  
 End Sub  

 '******************************************************************************  
