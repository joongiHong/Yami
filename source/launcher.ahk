/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\launcher.exe
[VERSION]
Set_Version_Info=1
Company_Name=Joongi Hong (ZERO)
File_Description=Yami! 1.0.0
File_Version=1.0.0.0
Inc_File_Version=0
Legal_Copyright=Copyright 2020. Joongi Hong. All rights reserved.
Original_Filename=launcher.exe
Product_Name=Yami!
Product_Version=1.0.0.0
Language_ID=79
[ICONS]
Icon_1=%In_Dir%\theme\icon.ico

* * * Compile_AHK SETTINGS END * * *
*/

; 버전 정보 선언
version := "1.0.0"

; 트레이 아이콘
Menu, tray, NoStandard
Menu, tray, add, 급식보기, food
Menu, tray, add, 급식편람 도우미, dfood
Menu, tray, add
Menu, tray, add, 기초설정 도우미, mfind
Menu, tray, add, 나이스 코드 수정, sucode
Menu, tray, add
Menu, tray, add, 설정, setting
Menu, tray, add, 종료, exit

; 아무대나 잡아도 상관 없도록
OnMessage(0x201, "WM_LBUTTONDOWN")

; 기초 설정 파일 유무 확인
IfExist, school_info.ini
{
	IfExist, *.csv
	{
		goto, food
		return
	}
	else
	{
		MsgBox, 52, Yami! %version%, 급식편람 파일이 존재하지 않습니다.`n급식편람 도우미를 실행하시겠습니까?
		IfMsgBox, Yes
		{
			goto, dfood
			return
		}
		IfMsgBox, No
		{
			goto, wc
			return
		}
		return
	}
}
else
{
	MsgBox, 52, Yami! %version%, 학교 기초설정 파일이 존재하지 않습니다.`n학교 기초설정 도우미를 실행하시겠습니까?
	IfMsgBox, Yes
	{
		goto, mfind
		return
	}
	IfMsgBox, No
	{
		goto, exit2
		return
	}
	return
}

; ----------- 기초설정 도우미 파트 --------------

; 찾기 전 메뉴
mfind:
IfExist, school_info.ini
{
	MsgBox, 52, Yami! %version%, 이미 기초정보 파일이 존재합니다.`n기존의 기초정보 파일을 삭제하고 다시 진행하시겠습니까?
}

IfMsgBox, No
{
	goto, wc
}
else
{
	FileDelete, school_info.ini
}

Gui, Destroy
Gui, -caption
Gui, Color, 444444
Gui, Font, S18 CFFFFFF Bold, 맑은 고딕
Gui, Add, Picture, x-7 y-2 w470 h172 , theme\sfind_top.png ; 배너 사진
Gui, Add, Picture, x424 y7 w28 h28 gexit2, theme\exit.png ; 나가기 아이콘
Gui, Font, S30 CFFFFFF Bold, 맑은 고딕
Gui, Add, Text, x31 y103 w182 h57 , 학교 찾기
Gui, Font, S10 CFFFFFF, 맑은 고딕
Gui, Add, Text, x31 y199 w403 h48 , 학교 설정을 위하여 설치 후 최초 1회 학교 찾기를 진행합니다.     급식 정보를 불러올 학교의 이름을 자세하게 입력하여 주십시오.
Gui, Font, S15 Cdefault, 맑은 고딕
Gui, Add, Edit, x31 y275 w297 h38 vsname, 불러올 학교 이름을 입력하세요.
Gui, Add, Button, x338 y275 w96 h38 gsfind, 검색
Gui, Show, w460 h371, Yami! %version%
return

; 학교 찾기
sfind:
Gui,2:-caption
Gui,2:Color, 444444
Gui,2:Font, S25 CFFFFFF Bold, 맑은 고딕
Gui,2:Add, Text, x55 y45 w201 h48 , 학교찾는중... ; 로딩중 표시
Gui,2:Show, w321 h163, Yami! %version%

Gui, Submit, Nohide
runwait, python yami.py school_find %sname%,,hide

Gui,2:Destroy ; 로딩중 제거

FileRead, schoollist, school_find.txt
if ErrorLevel = 1
{
	MsgBox, 16, Yami! %version%, 학교를 찾지 못하였습니다.`n학교 이름이 올바른지 확인하여 주시고`,`n입력 시 공백이나 특수문자를 입력하지 말아주십시오.`n`nError code: E_LIST_NOTFOUND
	goto, mfind
}
FileDelete, school_find.txt

Gui, Destroy
Gui, -caption
Gui, Color, 444444
Gui, Font, S18 CFFFFFF Bold, 맑은 고딕
Gui, Add, Picture, x-7 y-2 w470 h172 , theme\sfind_top.png ; 배너 사진
Gui, Add, Picture, x424 y7 w28 h28 gexit2, theme\exit.png ; 나가기 아이콘
Gui, Font, S30 CFFFFFF Bold, 맑은 고딕
Gui, Add, Text, x31 y103 w182 h57 , 학교 찾기
Gui, Font, S10 CFFFFFF, 맑은 고딕
Gui, Add, Text, x31 y199 w403 h48 , 학교를 찾았습니다. 급식 정보를 불러올 학교를 선택하세요.        목록에 없을 경우 나이스 전산 상에 학교 정보가 없는 경우입니다.
Gui, Font, S10 Cdefault, 맑은 고딕
Gui, Add, ListBox, x31 y285 w297 h40 vsnum, %schoollist%
Gui, Font, S15 Cdefault, 맑은 고딕
Gui, Add, Button, x338 y285 w96 h38 gsooe, 선택
Gui, Show, w460 h371, Yami! %version%
return

; 교육청 선택

sooe:
Gui,2:-caption
Gui,2:Color, 444444
Gui,2:Font, S25 CFFFFFF Bold, 맑은 고딕
Gui,2:Add, Text, x55 y45 w201 h48 , 코드기록중... ; 로딩중 표시
Gui,2:Show, w321 h163, Yami! %version%

Gui, Submit, Nohide
StringReplace, schoollist2, schoollist, |, `r`n, 1

FileAppend, %schoollist2%, schoollist2.txt

i = 0

loop, Read, schoollist2.txt
{
	if A_LoopReadLine = %snum%
	{
		break
	}
	i++
	return
}

runwait, python yami.py school_code %sname% %i%,,hide

FileRead, schoolcode, school_code.txt
if ErrorLevel = 1
{
	MsgBox, 16, Yami! %version%, 학교 코드를 찾지 못하였습니다.`n학교 이름이 올바른지 확인하여 주시고`,`n나이스 등재 학교인지 확인하여 주십시오.`n`nError code: E_CODE_NOTFOUND
	goto, sfind
}
FileDelete, schoollist2.txt

FileReadLine, schoolcode, school_code.txt, 1
FileReadLine, schooltype, school_code.txt, 2

IfEqual, schooltype, elementary
{
	IniWrite, 2, school_info.ini, school, type
	IniWrite, %schoolcode%, school_info.ini, school, code
	goto, sooe2
}
IfEqual, schooltype, middle
{
	IniWrite, 3, school_info.ini, school, type
	IniWrite, %schoolcode%, school_info.ini, school, code
	goto, sooe2
}
IfEqual, schooltype, high
{
	IniWrite, 4, school_info.ini, school, type
	IniWrite, %schoolcode%, school_info.ini, school, code
	goto, sooe2
}
IfEqual, schooltype, special
{
	MsgBox, 16, Yami! %verson%, 특수학교의 경우 급식 정보 제공이 어렵습니다.`n따라서 야미 또한 사용이 어렵습니다.`n`nError code: E_SCHOOL_TYPE
	ExitApp
}

sooe2:

FileDelete, school_code.txt

Gui,2:Destroy ; 로딩중 제거

Gui, Destroy
Gui, -caption
Gui, Color, 444444
Gui, Font, S18 CFFFFFF Bold, 맑은 고딕
Gui, Add, Picture, x-7 y-2 w470 h172 , theme\sfind_top.png ; 배너 사진
Gui, Add, Picture, x424 y7 w28 h28 gexit2, theme\exit.png ; 나가기 아이콘
Gui, Font, S30 CFFFFFF Bold, 맑은 고딕
Gui, Add, Text, x31 y103 w182 h57 , 교육청
Gui, Font, S10 CFFFFFF, 맑은 고딕
Gui, Add, Text, x31 y199 w403 h48 , 나이스 서버 접속을 위한 학교 관할 교육청을 선택하여 주십시오.  지역 관할이 아닌 학교 기준의 교육청입니다.
Gui, Font, S10 Cdefault, 맑은 고딕
Gui, Add, ListBox, x31 y285 w297 h40 vssooe, 서울특별시교육청|부산광역시교육청|대구광역시교육청|인천광역시교육청|광주광역시교육청|대전광역시교육청|울산광역시교육청|세종특별자치시교육청|경기도교육청|강원도교육청|충청북도교육청|충청남도교육청|전라북도교육청|전라남도교육청|경상북도교육청|경상남도교육청|제주특별자치도교육청
Gui, Font, S15 Cdefault, 맑은 고딕
Gui, Add, Button, x338 y285 w96 h38 gafood, 선택
Gui, Show, w460 h371, Yami! %version%
return

afood:
Gui, Submit, Nohide
IfEqual, ssooe, 서울특별시교육청
{
IniWrite, sen, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 부산광역시교육청
{
IniWrite, pen, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 대구광역시교육청
{
IniWrite, dge, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 인천광역시교육청
{
IniWrite, ice, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 광주광역시교육청
{
IniWrite, gen, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 대전광역시교육청
{
IniWrite, dje, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 울산광역시교육청
{
IniWrite, use, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 세종특별자치시교육청
{
IniWrite, sje, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 경기도교육청
{
IniWrite, goe, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 강원도교육청
{
IniWrite, kwe, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 충청북도교육청
{
IniWrite, cbe, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 충청남도교육청
{
IniWrite, cne, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 전라북도교육청
{
IniWrite, jbe, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 전라남도교육청
{
IniWrite, jne, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 경상북도교육청
{
IniWrite, gbe, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 경상남도교육청
{
IniWrite, gne, school_info.ini, school, ooe
goto, dfood1
}

IfEqual, ssooe, 제주특별자치도교육청
{
IniWrite, jje, school_info.ini, school, ooe
goto, dfood1
}
return

; 다운로드 여부 확인
dfood1:
Gui, Destroy
MsgBox, 36, Yami! %version%, 기초 설정이 모두 완료되었습니다.`n급식편람 도우미를 진행하시겠습니까?
IfMsgBox, Yes
{
	goto, dfood
}
IfMsgBox, No
{
	goto, wc
}

; 학교 코드 직접 입력
sucode:
Gui, Destroy
Gui, -caption
Gui, Color, 444444
Gui, Font, S18 CFFFFFF Bold, 맑은 고딕
Gui, Add, Picture, x-7 y-2 w470 h172 , theme\sfind_top.png ; 배너 사진
Gui, Add, Picture, x424 y7 w28 h28 gwc, theme\exit.png ; 나가기 아이콘
Gui, Font, S30 CFFFFFF Bold, 맑은 고딕
Gui, Add, Text, x31 y103 w182 h57 , 코드 수정
Gui, Font, S10 CFFFFFF, 맑은 고딕
Gui, Add, Text, x31 y199 w403 h48 , 나이스에서 사용하는 학교 구분 코드를 알고 계시면                   급식 정보를 불러올 학교 코드를 직접 수정하실 수 있습니다.
Gui, Font, S15 Cdefault, 맑은 고딕
Gui, Add, Edit, x31 y285 w297 h38 vscode, 불러올 학교 코드를 입력하세요.
Gui, Add, Button, x338 y285 w96 h38 gsucode2, 설정
Gui, Show, w460 h371, Yami! %version%
return

sucode2:
Gui, Submit, Nohide
IniWrite, %scode%, school_info.ini, school, code
MsgBox, 64, Yami! %version%, 나이스 학교 코드 수정을 완료하였습니다.`n이제부터 급식 편람을 정상적으로 불러올 수 있습니다.
goto, wc

; ----------- 급식편람 도우미 파트 --------------

; 급식 다운로드
dfood:
Gui, Destroy
Gui, -caption
Gui, Color, 444444
Gui, Font, S18 CFFFFFF Bold, 맑은 고딕
Gui, Add, Picture, x-7 y-2 w470 h172 , theme\main_top.png ; 배너 사진
Gui, Add, Picture, x424 y7 w28 h28 gexit3, theme\exit.png ; 나가기 아이콘
Gui, Font, S30 CFFFFFF Bold, 맑은 고딕
Gui, Add, Text, x31 y103 w280 h57 , 급식편람 받기
Gui, Font, S10 CFFFFFF, 맑은 고딕
Gui, Add, Text, x31 y199 w403 h48 , 급식편람 다운로드를 위하여 급식편람 설정을 진행합니다.        다운받을 편람의 종류를 선택하여 주십시오.
Gui, Font, S8 CFFFFFF, 맑은 고딕
Gui, Add, CheckBox, x69 y266 w67 h28 vbf, 조식편람
Gui, Add, CheckBox, x194 y266 w67 h28 vlc checked, 중식편람
Gui, Add, CheckBox, x328 y266 w67 h28 vdn, 석식편람
Gui, Font, S20 CFFFFFF, 맑은 고딕
Gui, Add, Button, x117 y314 w230 h38 gdfood_date, 설정
Gui, Show, w460 h371, Yami! %version%
return

;날짜 지정
dfood_date:
Gui, Submit, Nohide
Gui, Destroy
Gui, -caption
Gui, Color, 444444
Gui, Font, S18 CFFFFFF Bold, 맑은 고딕
Gui, Add, Picture, x-7 y-2 w470 h172 , theme\main_top.png ; 배너 사진
Gui, Add, Picture, x424 y7 w28 h28 gexit3, theme\exit.png ; 나가기 아이콘
Gui, Font, S30 CFFFFFF Bold, 맑은 고딕
Gui, Add, Text, x31 y103 w280 h57 , 급식편람 받기
Gui, Font, S10 CFFFFFF, 맑은 고딕
Gui, Add, Text, x31 y199 w403 h48 , 급식편람 다운로드를 위하여 급식편람 설정을 진행합니다.        다운받을 편람의 날짜를 반드시 클릭하여 주십시오.
Gui, Font, S10 Cdefault, 맑은 고딕
Gui, Add, ListBox, x31 y285 w297 h20 vyear, 년도를 선택해 주십시오.|2019년|2020년|
Gui, Add, ListBox, x31 y309 w297 h20 vmonth, 월을 선택해 주십시오.|01월|02월|03월|04월|05월|06월|07월|08월|09월|10월|11월|12월
Gui, Font, S15 Cdefault, 맑은 고딕
Gui, Add, Button, x338 y285 w96 h44 gddfood, 설정
Gui, Show, w460 h371, Yami! %version%
return

ddfood:
Gui, Submit, Nohide

IniRead, type, school_info.ini, school, type
IniRead, code, school_info.ini, school, code
IniRead, ooe, school_info.ini, school, ooe

ayear := SubStr(year,1,4)
amonth := SubStr(month,1,2)

Gui,2:-caption
Gui,2:Color, 444444
Gui,2:Font, S25 CFFFFFF Bold, 맑은 고딕
Gui,2:Add, Text, x55 y45 w201 h48 , 편람다운중... ; 로딩중 표시
Gui,2:Show, w321 h163, Yami! %version%

if bf = 1
{
	runwait, python yami.py school_food_save %ooe% %code% %ayear% %amonth% %type% 1,,hide
	IfNotExist, Yami_%ayear%_%amonth%_1.csv
	{
		MsgBox, 16, Yami! %version%, 조식편람을 다운로드 하지 못하였습니다.`n조식이 제공되지 않고 있거나`, 나이스 서버가 점검 중입니다.`n`nError code: E_BREAKFAST_NOTDOWNLOAD
	}
	else
	{
		MsgBox, 64, Yami! %version%, 조식편람을 다운로드 하였습니다.
	}
}

if lc = 1
{
	runwait, python yami.py school_food_save %ooe% %code% %ayear% %amonth% %type% 2,,hide
	IfNotExist, Yami_%ayear%_%amonth%_2.csv
	{
		MsgBox, 16, Yami! %version%, 중식편람을 다운로드 하지 못하였습니다.`n중식이 제공되지 않고 있거나`, 나이스 서버가 점검 중입니다.`n`nError code: E_LUNCH_NOTDOWNLOAD
	}
	else
	{
		MsgBox, 64, Yami! %version%, 중식편람을 다운로드 하였습니다.
	}
}

if dn = 1
{
	runwait, python yami.py school_food_save %ooe% %code% %ayear% %amonth% %type% 3,,hide
	IfNotExist, Yami_%ayear%_%amonth%_3.csv
	{
		MsgBox, 16, Yami! %version%, 석식편람을 다운로드 하지 못하였습니다.`n석식이 제공되지 않고 있거나`, 나이스 서버가 점검 중입니다.`n`nError code: E_DINNER_NOTDOWNLOAD
	}
	else
	{
		MsgBox, 64, Yami! %version%, 석식편람을 다운로드 하였습니다.
	}
}

Gui,2:Destroy ; 로딩중 제거

MsgBox, 64, Yami! %version%, 급식편람 다운로드가 완료되었습니다.`n급식편람 도우미를 종료하겠습니다.
goto, wc

; ----------- 급식 조회 파트 --------------

; 급식 표시
food: ; 오늘치 급식

IfNotExist, Yami_%A_YYYY%_%A_MM%_1.csv ; 이번달 급식편람 유무 확인
{
	MsgBox, 68, Yami! %version%, 이번달 조식편람이 존재하지 않습니다.`n급식편람 도우미를 실행하시겠습니까?
	IfMsgBox, Yes
	{
		goto,  dfood
	}
}

IfNotExist, Yami_%A_YYYY%_%A_MM%_2.csv ; 이번달 급식편람 유무 확인
{
	MsgBox, 68, Yami! %version%, 이번달 중식편람이 존재하지 않습니다.`n급식편람 도우미를 실행하시겠습니까?
	IfMsgBox, Yes
	{
		goto,  dfood
	}
}

IfNotExist, Yami_%A_YYYY%_%A_MM%_3.csv ; 이번달 급식편람 유무 확인
{
	MsgBox, 68, Yami! %version%, 이번달 석식편람이 존재하지 않습니다.`n급식편람 도우미를 실행하시겠습니까?
	IfMsgBox, Yes
	{
		goto,  dfood
	}
}

FileReadLine, food1, Yami_%A_YYYY%_%A_MM%_1.csv, %A_DD% ; 급식 편람을 불러와서
FileReadLine, food2, Yami_%A_YYYY%_%A_MM%_2.csv, %A_DD%
FileReadLine, food3, Yami_%A_YYYY%_%A_MM%_3.csv, %A_DD%

StringSplit, food11, food1, `, ; CSV 형식으로 나누고
StringSplit, food22, food2, `,
StringSplit, food33, food3, `,

StringReplace, food112, food112, <br/>, `n, 1 ; html의 개행 문자를 오토핫키 개행으로 수정한다.
StringReplace, food222, food222, <br/>, `n, 1
StringReplace, food332, food332, <br/>, `n, 1

if food112 =
{
	food112 = 급식편람이 존재하지 않아 불러올 수 없습니다. ; 급식편람 데이터가 존재하지 않으면 급식편람 안내
}

if food222 =
{
	food222 = 급식편람이 존재하지 않아 불러올 수 없습니다.
}

if food332 =
{
	food332 = 급식편람이 존재하지 않아 불러올 수 없습니다.
}

Gui, Submit, Nohide
Gui, Destroy
Gui, -caption
Gui, Color, 444444
Gui, Font, S18 CFFFFFF Bold, 맑은 고딕
Gui, Add, Picture, x-7 y-2 w470 h172 , theme\main_top.png ; 배너 사진
Gui, Add, Picture, x424 y7 w28 h28 gwc, theme\exit.png ; 나가기 아이콘
Gui, Font, S30 CFFFFFF Bold, 맑은 고딕
Gui, Add, Text, x31 y103 w280 h57 , 급식편람 조회
Gui, Font, S10 Cdefault, 맑은 고딕
Gui, Add, DateTime, x31 y199 w197 h20 vdate, yyyy M d
Gui, Add, Button, x250 y199 w96 h20 gnfood, 조회
Gui, Font, S10 CFFFFFF, 맑은 고딕
Gui, Add, Tab2, x31 h200, 조식|중식||석식
Gui, Tab, 1
Gui, Add, Text, w300 h150, %food112% ; 조식 표시
Gui, Tab, 2
Gui, Add, Text, w300 h150, %food222% ; 중식 표시
Gui, Tab, 3
Gui, Add, Text, w300 h150, %food332% ; 석식 표시
Gui, Show, w460 h450, Yami! %version%
return

nfood:
Gui, Submit, Nohide
date := SubStr(date,1,8)
year := SubStr(date,1,4)
month := SubStr(date,5,2)
day := SubStr(date,7,2)

FileReadLine, food1, Yami_%year%_%month%_1.csv, %day% ; 급식 편람을 불러와서
FileReadLine, food2, Yami_%year%_%month%_2.csv, %day%
FileReadLine, food3, Yami_%year%_%month%_3.csv, %day%

StringSplit, food11, food1, `, ; CSV 형식으로 나누고
StringSplit, food22, food2, `,
StringSplit, food33, food3, `,

StringReplace, food112, food112, <br/>, `n, 1 ; html의 개행 문자를 오토핫키 개행으로 수정한다.
StringReplace, food222, food222, <br/>, `n, 1
StringReplace, food332, food332, <br/>, `n, 1

if food112 =
{
	food112 = 급식편람이 존재하지 않아 불러올 수 없습니다. ; 급식편람 데이터가 존재하지 않으면 급식편람 안내
}

if food222 =
{
	food222 = 급식편람이 존재하지 않아 불러올 수 없습니다.
}

if food332 =
{
	food332 = 급식편람이 존재하지 않아 불러올 수 없습니다.
}

Gui, Submit, Nohide
Gui, Destroy
Gui, -caption
Gui, Color, 444444
Gui, Font, S18 CFFFFFF Bold, 맑은 고딕
Gui, Add, Picture, x-7 y-2 w470 h172 , theme\main_top.png ; 배너 사진
Gui, Add, Picture, x424 y7 w28 h28 gwc, theme\exit.png ; 나가기 아이콘
Gui, Font, S30 CFFFFFF Bold, 맑은 고딕
Gui, Add, Text, x31 y103 w280 h57 , 급식편람 조회
Gui, Font, S10 Cdefault, 맑은 고딕
Gui, Add, DateTime, x31 y199 w197 h20 vdate Choose%date%, yyyy M d
Gui, Add, Button, x250 y199 w96 h20 gnfood, 조회
Gui, Font, S10 CFFFFFF, 맑은 고딕
Gui, Add, Tab2, x31 h200, 조식|중식||석식
Gui, Tab, 1
Gui, Add, Text, w300 h150, %food112% ; 조식 표시
Gui, Tab, 2
Gui, Add, Text, w300 h150, %food222% ; 중식 표시
Gui, Tab, 3
Gui, Add, Text, w300 h150, %food332% ; 석식 표시
Gui, Show, w460 h450, Yami! %version%
return

; ----------- 설정 파트 --------------

setting:
Gui, Submit, Nohide
Gui, Destroy
Gui, -caption
Gui, Color, 444444
Gui, Font, S18 CFFFFFF Bold, 맑은 고딕
Gui, Add, Picture, x-7 y-2 w470 h172 , theme\setting_top.png ; 배너 사진
Gui, Add, Picture, x424 y7 w28 h28 gwc, theme\exit.png ; 나가기 아이콘
Gui, Font, S30 CFFFFFF Bold, 맑은 고딕
Gui, Add, Text, x31 y103 w280 h57 , 설정
Gui, Font, S10 Cdefault, 맑은 고딕
Gui, Add, DateTime, x31 y199 w197 h20 vdate Choose%date%, yyyy M d
Gui, Add, Button, x250 y199 w96 h20 gnfood, 조회
Gui, Font, S10 CFFFFFF, 맑은 고딕
Gui, Add, Tab2, x31 h200, 조식|중식||석식
Gui, Tab, 1
Gui, Add, Text, w300 h150, %food111% ; 조식 표시
Gui, Tab, 2
Gui, Add, Text, w300 h150, %food222% ; 중식 표시
Gui, Tab, 3
Gui, Add, Text, w300 h150, %food333% ; 석식 표시
Gui, Show, w460 h450, Yami! %version%
return

; ----------- 기타 파트 --------------

; 어디를 잡아도 움직일 수 있도록 수정
WM_LBUTTONDOWN(wParam, IParam)
{
	PostMessage, 0xA1, 2,,, A
	return
}

; 엑시트
exit2:
MsgBox, 49, Yami! %version%, 학교 기초설정을 하지 않으실 경우 급식을 불러올 수 없습니다.`n추후 기초설정 도우미를 다시 진행하시겠습니까?
IfMsgBox, OK
{
	FileDelete, school_info.ini
	goto, wc
	return
}
IfMsgBox, Cancel
{
	FileDelete, school_info.ini
	goto, mfind
	return
}
return

exit3:
MsgBox, 49, Yami! %version%, 급식편람 다운로드를 하지 않으실 경우 급식을 불러올 수 없습니다.`n추후 급식편람 도우미를 다시 진행하시겠습니까?
IfMsgBox, OK
{
	goto, wc
	return
}
IfMsgBox, Cancel
{
	goto, dfood
	return
}
return

wc:
WinClose
TrayTip, Yami! %version%, 안정적인 알림을 위해 최소화 됩니다.`n종료를 원하시면 종료를 클릭해 주세요., , 33
return

exit:
ExitApp
return