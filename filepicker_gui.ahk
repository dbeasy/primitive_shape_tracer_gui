#SingleInstance,Force



Gui,Add,Edit,x14 y50 w400 h21 vInputFile,(pick a file to read)
Gui,Add,Button,x419 y50 w75 h23 vbtninputfile gsubinputfile,Input File
Gui,Add,Edit,x14 y77 w400 h21 vOutputFile,\temp\primitive_00.jpg
Gui,Add,Button,x419 y77 w75 h23 gsuboutputfile,Output File

Gui,Add,Text,x72 y125 w166 h13,Number of shapes (e.g. 50-200)
Gui,Add,Edit,x12 y121 w54 h21 vnumshapes,100
Gui,Add,UpDown,x68 y122 w18 h21 Range50-5000,UpDown
GuiControl, , Edit3, 201  ; set default value since UpDown Range picks lowest allowed by default

; m	1	mode: 0=combo, 1=triangle, 2=rect, 3=ellipse, 4=circle, 5=rotatedrect, 6=beziers, 7=rotatedellipse, 8=polygon
Gui,Add,GroupBox,x9 y150 w480 h80,Restrict to Matching Shape(s)
Gui,Add,Checkbox,x26 y172 w70 h13 vopttriangle gsubcheckbox,Triangle
Gui,Add,Checkbox,x108 y172 w70 h13 voptcircle gsubcheckbox,Circle
Gui,Add,Checkbox,x184 y172 w70 h13 voptrect gsubcheckbox,Rectangle
Gui,Add,Checkbox,x266 y172 w140 h13 voptrotrect gsubcheckbox,Rotated Rectangle
Gui,Add,Checkbox,x26 y192 w70 h13 voptpolygon gsubcheckbox,Polygon
Gui,Add,Checkbox,x108 y192 w70 h13 voptbeziers gsubcheckbox,Beziers
Gui,Add,Checkbox,x184 y192 w70 h13 voptellipse gsubcheckbox,Ellipse
Gui,Add,Checkbox,x266 y192 w140 h13 voptrotellipse gsubcheckbox,Rotated Ellipse
Gui,Add,Text,x366 y212 w122 h13 vopttotals,Shape Totals=0

Gui,Add,Edit,x14 y248 w54 h21 veditbgcolor,BgColor
Gui,Add,Slider,x9 y272 w180 h33 gBackground_Color vbgcolorred,0
Gui,Add,Slider,x189 y272 w180 h33 gBackground_Color vbgcolorgreen,0
Gui,Add,Slider,x400 y272 w180 h33 gBackground_Color vbgcolorblue,0
Gui,Add,Text,x9 y304 w88 h13,W x H
Gui,Add,Edit,x128 y304 w55 h21 voutheight,Height
Gui,Add,UpDown,x148 y304 w18 h21,UpDown
Gui,Add,Edit,x203 y304 w55 h21 voutwidth,Width
Gui,Add,UpDown,x243 y304 w18 h21,UpDown

Gui,Add,Picture,x15 y340 w128 h128 vInputPicture,C:\windata_c\download.png
Gui,Add,Picture,x315 y340 w128 h128 vOutputPicture,C:\windata_c\download.png
Gui,Add,Button,x162 y450 w144 h23 gsubrunprimitive,Run primitive
Gui,Show,w500 h500,primitive Go shape matcher GUI front-end by dboland v1.0
Gui, Add, StatusBar,, Pick input picture file`, some options and Run primitive

pidrunning=0
opttotals=0 ; shapes allowed, added up to one value

return

subcheckbox:
; m	1	mode: 0=combo, 1=triangle, 2=rect, 3=ellipse, 4=circle, 5=rotatedrect, 6=beziers, 7=rotatedellipse, 8=polygon
;msgbox, checkbox circle
optionmask:=optionmask+2
; guicontrolget, opttriangle
; if opttriangle
	; optionmask:=optionmask+1
; gui, submit, nohide
; msgbox,0,checkboxes,opttriangle=%opttriangle% optcircle=%optcircle%

myguilist=
opttotals=0 ; program also accepts 0 as option to use "all" shapes
checklist=1:triangle, 2:rect, 3:ellipse, 4:circle, 5:rotrect, 6:beziers, 7:rotellipse, 8:polygon
loop, parse, checklist, `,,%A_Tab%%A_Space%
{
	; %A_LoopField% -- a var from Loop that has the current parse string
	stringsplit, parsevals, A_LoopField, :
	guicontrolget, checked,, opt%parsevals2%
	opttotals:=opttotals+(checked*parsevals1)
	;msgbox,0,parsing,looking for parsevals2=%parsevals2% multiplier is %parsevals1%`, value=%checked%
	myguilist=%myguilist%`n%parsevals2% multiplier is %parsevals1%`, value=%checked%
}
guicontrol,,opttotals,Shape Totals=%opttotals%
if pidrunning=0
{
	;msgbox,0,my gui list, %myguilist%`nTotal: %opttotals%
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
    MsgBox, The user didn't select anything.
else
{
	guicontrol,, InputFile, %SelectedFile%
	guicontrol,, InputPicture, %SelectedFile%
	; Separates a file name or URL into its name, directory, extension, and drive.
	; SplitPath, InputVar , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	SplitPath, SelectedFile , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	guicontrol,, OutputFile, %OutDir%\%OutNameNoExt%_primitive_`%d.%OutExtension%
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
msgbox,0, Running primitive, Options:`nInputfile: %InputFile%`nOutputFile: %OutputFile%`n-n %numshapes% -m %opttotals%,15
run, primitive -i "%InputFile%" -o "%Outputfile%" -n %numshapes% -m %opttotals% -nth 10,,Min UseErrorLevel,primitivepid
;run, "sleep.exe" 12,,Min UseErrorLevel,primitivepid
msgbox,0,primitive Running in Background,primitive is making a copy of your picture using rectangles and circles etc (whatever you picked)`nThis will take many minutes,5
pidrunning=1
timermax=5000
countdown:=timermax
sleep, 200
while (pidrunning = 1)
{
	sleep, 950
	Process, Exist, %primitivepid%
	if ErrorLevel <> %primitivepid%  ; i.e. it's not blank or zero.,
	{
		;MsgBox, The process %primitivepid% does not exist errorlevel=%ErrorLevel%.
		pidrunning=0
	}
	else
	{
		;MsgBox, The process %primitivepid% exists (errorlevel=%ErrorLevel%).
		countdown:=countdown-1
		; in function calls the strings are "in quotes" and vars don't need %percent% signs
		SB_SetText("primitive running in background (maybe " . countdown . " secs left)")
		pidrunning=1
	}
}
countdowndiff:=timermax-countdown
SB_SetText("primitive, last run completed in " . countdowndiff . " secs")
process, close, %primitivepid%
return

Exit