#SingleInstance,Force

; generally debug > 1 some extra info, > 2 a bit more, > 3 show extra in loops can get annoying, > 4 loops and needless info.
; I don't have any debug > 0 statements so debug=1 doesn't do anything, todo, fix that.
debug=0

; C:\winsupp\primitive_graphics_shapes>c:\winsupp\AutoHotkey\Compiler\Ahk2Exe.exe /in c:\windata_c\filepicker_gui.ahk /out primative_gui.exe

Gui,Add,Edit,x14 y50 w400 h21 vInputFile,(pick a file to read)
Gui,Add,Button,x419 y50 w75 h23 vbtninputfile gsubinputfile,Input File
Gui,Add,Edit,x14 y77 w400 h21 vOutputFile,\temp\primitive_00.jpg
Gui,Add,Button,x419 y77 w75 h23 gsuboutputfile,Output File

Gui,Add,Text,x72 y125 w166 h13,Number of shapes (e.g. 50-200)
Gui,Add,Edit,x12 y121 w54 h21 vnumshapes,100
Gui,Add,UpDown,x68 y122 w18 h21 Range50-5000,UpDown
GuiControl, , Edit3, 201  ; set default value since UpDown Range picks lowest allowed by default

Gui,Add,Text,x372 y125 w166 h13,Output every ## frames
Gui,Add,Edit,x312 y121 w54 h21 vframecount,100
Gui,Add,UpDown,x68 y122 w18 h21 Range1-5000,UpDown
GuiControl, , framecount, 10  ; set default value since UpDown Range picks lowest allowed by default

; m	1	mode: 0=combo, 1=triangle, 2=rect, 3=ellipse, 4=circle, 5=rotatedrect, 6=beziers, 7=rotatedellipse, 8=polygon
Gui,Add,GroupBox,x9 y150 w480 h80,Restrict to Matching Shape(s) [pick one, or none for any shape]
Gui,Add,Checkbox,x26 y172 w70 h13 vopttriangle gsubcheckbox,Triangle
Gui,Add,Checkbox,x108 y172 w70 h13 voptcircle gsubcheckbox,Circle
Gui,Add,Checkbox,x184 y172 w70 h13 voptrect gsubcheckbox,Rectangle
Gui,Add,Checkbox,x266 y172 w140 h13 voptrotrect gsubcheckbox,Rotated Rectangle
Gui,Add,Checkbox,x26 y192 w70 h13 voptpolygon gsubcheckbox,Polygon
Gui,Add,Checkbox,x108 y192 w70 h13 voptbeziers gsubcheckbox,Beziers
Gui,Add,Checkbox,x184 y192 w70 h13 voptellipse gsubcheckbox,Ellipse
Gui,Add,Checkbox,x266 y192 w140 h13 voptrotellipse gsubcheckbox,Rotated Ellipse
Gui,Add,Text,x366 y212 w122 h13 vopttotals,Shape Totals=0


Gui,Add,Text,x74 y250 w154 h21,Background Color (in hex)
Gui,Add,Edit,x14 y248 w54 h21 veditbgcolor,000000

Gui,Add,Text,x374 y250 w154 h21,Alpha value (0-255)
Gui,Add,Edit,x314 y248 w54 h21 veditalpha,128
Gui,Add,UpDown,x328 y304 w18 h21 Range0-255,UpDown
GuiControl,,editalpha,128
; Gui,Add,Slider,x9 y272 w180 h33 gBackground_Color vbgcolorred,0
; Gui,Add,Slider,x189 y272 w180 h33 gBackground_Color vbgcolorgreen,0
; Gui,Add,Slider,x400 y272 w180 h33 gBackground_Color vbgcolorblue,0

Gui,Add,Text,x9 y308 w88 h13,Input size
Gui,Add,Edit,x58 y304 w60 h21 vinheight,Height
Gui,Add,UpDown,x68 y304 w18 h21 Range0-32768,UpDown
GuiControl,,inheight,256
; Gui,Add,Edit,x98 y304 w60 h21 vinwidth,Width
; Gui,Add,UpDown,x100 y304 w18 h21 Range0-32768,UpDown


Gui,Add,Text,x300 y308 w88 h13,Output size
Gui,Add,Edit,x368 y304 w60 h21 voutheight,Height
Gui,Add,UpDown,x378 y304 w18 h21 Range0-32768,UpDown
GuiControl,,outheight,1024
; Gui,Add,Edit,x398 y304 w60 h21 voutwidth,Width
; Gui,Add,UpDown,x400 y304 w18 h21 Range0-32768,UpDown

Gui,Add,Picture,x9 y340 w138 h128 vInputPicture,C:\windata_c\download.png
Gui,Add,Picture,x165 y340 w296 h256 vOutputPicture,C:\windata_c\download.png
Gui,Add,Button,x9 y490 w134 h23 gsubkillprimitive,Kill primitive
Gui,Add,Button,x9 y540 w134 h43 gsubrunprimitive,Run primitive
Gui,Show,w500 h620,primitive Go shape matcher GUI front-end by dboland v1.0
Gui, Add, StatusBar,, Pick input picture file`, some options and Run primitive

; globals
pidrunning=0
opttotals=0 ; shapes allowed, added up to one value

return

subkillprimitive:
; todo, add error checking
if pidrunning = 0
{
	SB_SetText("Primitive.exe not running")
	return
}
process, waitclose, primitive.exe,10
msgbox,0,Primitive Closed,Primitive.exe pid was %ErrorLevel%
pidrunning=0
return

subcheckbox:
; m	1	mode: 0=combo, 1=triangle, 2=rect, 3=ellipse, 4=circle, 5=rotatedrect, 6=beziers, 7=rotatedellipse, 8=polygon
;msgbox, checkbox circle
optionmask:=optionmask+2
; guicontrolget, opttriangle
; if opttriangle
	; optionmask:=optionmask+1
gui, submit, nohide
if debug > 2
	msgbox,0,checkboxes,opttriangle=%opttriangle% optcircle=%optcircle%

myguilist=
opttotals=0 ; program also accepts 0 as option to use "all" shapes
checklist=1:triangle, 2:rect, 3:ellipse, 4:circle, 5:rotrect, 6:beziers, 7:rotellipse, 8:polygon
loop, parse, checklist, `,,%A_Tab%%A_Space%
{
	; %A_LoopField% -- a var from Loop that has the current parse string
	stringsplit, parsevals, A_LoopField, :
	guicontrolget, checked,, opt%parsevals2%
	opttotals:=opttotals+(checked*parsevals1)
	if debug > 3
		msgbox,0,parsing,looking for parsevals2=%parsevals2% multiplier is %parsevals1%`, value=%checked%
	myguilist=%myguilist%`n%parsevals2% multiplier is %parsevals1%`, value=%checked%
}
guicontrol,,opttotals,Shape Totals=%opttotals%
if pidrunning=0
{
	if debug > 2
		msgbox,0,my gui list, %myguilist%`nTotal: %opttotals%
}
else
{
	SB_SetText("Options won't change current primitive run in background")
}
return


Background_Color:
color:=bgcolorred*256*256+bgcolorgreen*256+bgcolorblue
; can't figure out how to make a tiny box of color in autohotkey to show the user
;guicontrol,
return

subinputfile:
;msgbox,0,Input File sub, The filename is %InputFile%
FileSelectFile, SelectedFile , 3, , Picture Input file to be scanned, Pictures (*.jpg; *.png; *.gif; *.bmp)

if SelectedFile =
    MsgBox, 1, File Picker, The user didn't select anything.,10
else
{
	guicontrol,, InputFile, %SelectedFile%
	guicontrol,, InputPicture, %SelectedFile%
	; Separates a file name or URL into its name, directory, extension, and drive.
	; SplitPath, InputVar , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	SplitPath, SelectedFile , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	guicontrol,, OutputFile, %OutDir%\%OutNameNoExt%_primitive_`%s_`%d.%OutExtension%
    if debug > 1
		MsgBox, The user selected the following:`n%SelectedFile%
}
return

suboutputfile:
msgbox,99,Not Yet Supported,That Feature is not yet supported.
Return


Buttonbtninputfile:
msgbox,0,Input File, The filename is %InputFile%

return

subrunprimitive:
; run "gui submit" to push all the edit box values into their variables
Gui, Submit, NoHide


latestoutputfile:=strreplace(OutputFile,"%s","s" opttotals)
if debug > 2
	msgbox,replaced `%s with %opttotals% in `noutputfile: "%OutputFile%"`nto end up with "%latestoutputfile%" 
OutputFile:=latestoutputfile

; with the =nth option you end up with a bunch of files that are neat to flip through,
; it can also give us better time remaining estimates and it can let us preview the
; results as Primitive is doing its shape fitting in the background
; most shape options with input=256 output=1024 (defaults) take about 90 seconds to create 200 frames on my i5-3427U 1.8Ghz notebook PC
; 07/16/2019  12:17 PM           124,212 vlcsnap-2018-11-29-20h43m40s921_primitive_3_80.png
; 07/16/2019  12:17 PM           131,603 vlcsnap-2018-11-29-20h43m40s921_primitive_3_90.png
; 07/16/2019  12:17 PM           139,476 vlcsnap-2018-11-29-20h43m40s921_primitive_3_100.png
; 07/16/2019  12:17 PM           145,516 vlcsnap-2018-11-29-20h43m40s921_primitive_3_110.png
; 07/16/2019  12:17 PM           151,603 vlcsnap-2018-11-29-20h43m40s921_primitive_3_120.png
; 07/16/2019  12:17 PM           156,351 vlcsnap-2018-11-29-20h43m40s921_primitive_3_130.png
; 07/16/2019  12:18 PM           162,558 vlcsnap-2018-11-29-20h43m40s921_primitive_3_140.png
; 07/16/2019  12:18 PM           167,972 vlcsnap-2018-11-29-20h43m40s921_primitive_3_150.png
; 07/16/2019  12:18 PM           173,021 vlcsnap-2018-11-29-20h43m40s921_primitive_3_160.png
; 07/16/2019  12:18 PM           177,456 vlcsnap-2018-11-29-20h43m40s921_primitive_3_170.png
; 07/16/2019  12:18 PM           182,657 vlcsnap-2018-11-29-20h43m40s921_primitive_3_180.png
; 07/16/2019  12:18 PM           188,078 vlcsnap-2018-11-29-20h43m40s921_primitive_3_190.png
; 07/16/2019  12:18 PM           192,013 vlcsnap-2018-11-29-20h43m40s921_primitive_3_200.png
; 07/16/2019  12:18 PM           192,251 vlcsnap-2018-11-29-20h43m40s921_primitive_3_201.png
; time remaining, how many total partial outputs = total frames (200) / nthparm (10) = 20 files expected
; countdown the time it takes to write out 1 file, let's say 10 seconds
; that averages 1 file in 10 seconds
; countdown the time it takes to write out 2 files, let's say 20 seconds
; that averages 2 files in 20 seconds (1 file every 10 seconds)
; That equates to code: countdowndiff / foundfiles = files per second
;
; With an expected rate of 1 file every 10 seconds (0.1s/file) and we have a total of 20 files expected
;  (total frames/nthparm) / outputfilespersecond = 200 seconds total estimates
; time remaining is total estimated time - current countdowndiff.


; todo, Ideas for output filename, include all options in the run, like inputsize,  
primitiveparms= -v -i "%InputFile%" -o "%Outputfile%" -n %numshapes% -m %opttotals% -nth 10 -s %outheight% -r %inheight%
if debug > 1
	msgbox,0,primitive parms,parms: %primitiveparms%
if debug > 4
	msgbox,0, Running primitive, old way - Options:`nInputfile: %InputFile%`nOutputFile: %OutputFile%`n-n %numshapes% -m %opttotals%,15
run, primitive %primitiveparms%,,Min UseErrorLevel,primitivepid
;run, "sleep.exe" 12,,Min UseErrorLevel,primitivepid
pidrunning=1
timermax=5002
countdown:=timermax
foundfiles=0
filespersecond=0
pidstarttime:=A_Now
checkframes:=framecount+1
if checkframes < 1
	checkframes=2
totalexpected:=format("{1:1i}",numshapes/framecount+1.5)
if debug > 2
	msgbox, total expected files %totalexpected%

if debug > 1
	msgbox,0,primitive Running in Background,primitive is making a copy of your picture using rectangles and circles etc (whatever you picked)`nThis will take many minutes,5

sleep, 200
while (pidrunning = 1)
{
	sleep, 950
	Process, Exist, %primitivepid%
	if ErrorLevel <> %primitivepid%  ; i.e. it's not blank or zero.,
	{
		if debug > 2
			MsgBox, The process %primitivepid% does not exist errorlevel=%ErrorLevel%.
		pidrunning=0
	}
	else
	{
		if debug > 4
			MsgBox, The process %primitivepid% exists (errorlevel=%ErrorLevel%).
		countdown:=countdown-1
		countdowndiff:=timermax-countdown
		
		; in function calls the strings are "in quotes" and vars don't need %percent% signs
		SB_SetText("primitive running in background for " countdowndiff " secs (maybe " . countdown . " secs left)")
		pidrunning=1
	}
	; Separates a file name or URL into its name, directory, extension, and drive.
	; SplitPath, InputVar , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	if (mod(countdown,checkframes) = 0)
	{
		;SplitPath, latestoutputfile , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		;guicontrol,, OutputFile, %OutDir%\%OutNameNoExt%_primitive_`%d.%OutExtension%
		outputfilepattern:=strreplace(OutputFile,"%d","*")

		foundfiles=0
		newoutputfiles=0
		newestmatchfilename=
		newestmatchfiletime=0
		if debug > 1
			msgbox, looping for %outputfilepattern%
		loop, files, %outputfilepattern%
		{
			foundfiles:=foundfiles+1
			if debug > 4
				msgbox, 0,fileloop, comparing job start %pidstarttime%`nto timestamp on file %A_LoopFileTimeModified% "%A_LoopFileName%",1
			; The user might re-run with different options, only scan for files created after we started the Primitive job
			; A_LoopFileTimeModified The time the file was last modified. Format YYYYMMDDHH24MISS. 
			if (A_LoopFileTimeModified > pidstarttime)
			{
				;msgbox, 0,fileloop, found a new file %A_LoopFileTimeModified% "%A_LoopFileName%",1
				if debug > 3
					msgbox, 0,fileloop new file, new file matches`ncomparing job start %pidstarttime%`nto timestamp on file %A_LoopFileTimeModified% "%A_LoopFileName%",1
				newoutputfiles:=newoutputfiles+1
				if (A_LoopFileTimeModified > newestmatchfiletime)
				{
					newestmatchfilename:=A_LoopFilePath
					newestmatchfiletime:=A_LoopFileTimeModified
				}
			}
			else
			{
				if debug > 2
					msgbox, 0,fileloop old file, older file does not match`ncomparing job start %pidstarttime%`nto timestamp on file %A_LoopFileTimeModified% "%A_LoopFileName%",1
			}
		}
		countdowndiff:=timermax-countdown
		timeestimate:=newoutputfiles*countdowndiff
		
		if debug > 2
			msgbox, %newoutputfiles% / %foundfiles% 
		SB_SetText("primitive running in background looking for latest " newoutputfiles "/" foundfiles " file (maybe " . countdown . " secs left)")
		if newestmatchfilename
		{
			if debug > 2
				msgbox, newest file preview is: "%newestmatchfile%" %newestmatchfiletime% %newoutputfiles% / %foundfiles% 
			guicontrol,,outputpicture,%newestmatchfilename%
		}
		
	}

}
countdowndiff:=timermax-countdown
SB_SetText("primitive, last run completed in " . countdowndiff . " secs")
process, close, %primitivepid%
return

Exit