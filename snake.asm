TITLE Snake.asm

INCLUDE Irvine32.inc

.data

a	WORD	1920 DUP(0)

tR	BYTE	16d
tC	BYTE	47d
hR	BYTE	13d
hC	BYTE	47d
fR	BYTE	0
fC	BYTE	0

tmpR	BYTE	0
tmpC	BYTE	0

rM	BYTE	0d
cM	BYTE	0d
rP	BYTE	0d
cP	BYTE	0d

eTail	BYTE	1d
search	WORD	0d
eGame	BYTE	0d
cScore	DWORD	0d

d	BYTE	'w'
newD	BYTE	'w'
delTime DWORD	150

menuS	BYTE	"1. Start Game", 0Dh, 0Ah,"2. Select Speed", 0Dh, 0Ah, "3. Select Level", 0Dh, 0Ah, "4. Exit",0Dh, 0Ah, 0
levelS	BYTE	"1. None", 0Dh, 0Ah, "2. Box", 0Dh, 0Ah, "3. Rooms", 0Dh, 0Ah, 0
speedS	BYTE	"1. Earthworm", 0Dh, 0Ah, "2. Centipede", 0Dh, 0Ah, "3. Cobra", 0Dh, 0Ah, "4. Black Mamba", 0Dh, 0Ah, 0
hitS	BYTE	"Game Over!", 0
scoreS	BYTE	"Score: 0", 0

myHandle	DWORD	?
numInp	DWORD	?
temp	BYTE	16 DUP(?)
bRead	DWORD	?

.code

main PROC

	menu:
	CALL Randomize
	CALL ClrScr
	MOV edx, OFFSET menuS
	CALL WriteString
	
	wait1:
	CALL ReadChar
	
	CMP al, '1'
	JE startG
	
	CMP al, '2'
	JE speed
	
	CMP al, '3'
	JE level
	
	CMP al, '4'
	JNE wait1
	
	exit

	level:
	CALL Clrscr
	MOV edx, OFFSET levelS
	CALL WriteString
	
	wait2:
	CALL readchar
	
	CMP al, '1'
	JE level1
	
	CMP al, '2'
	JE level2
	
	CMP al, '3'
	JE level3
	JMP wait2
	
	level1:
	CALL clearMem
	MOV al, 1
	CALL GenLevel
	JMP menu
	
	level2:
	CALL clearMem
	MOV al, 2
	CALL GenLevel
	JMP menu
	
	level3:
	CALL clearMem
	MOV al, 3
	CALL GenLevel
	JMP menu
	
	speed:	
	CALL Clrscr
	MOV edx, OFFSET speedS
	CALL WriteString
	
	wait3:
	CALL ReadChar
	
	CMP al, '1'
	JE speed1
	
	CMP al, '2'
	JE speed2
	
	CMP al, '3'
	JE speed3
	
	CMP al, '4'
	JE speed4
	JMP wait3
	
	speed1:
	MOV delTime, 150
	JMP menu
	
	speed2:
	MOV delTime, 100
	JMP menu
	
	speed3:
	MOV delTime, 50
	JMP menu
	
	speed4:
	MOV delTime, 35
	JMP menu
	
	startG:

	MOV eax, 0
	MOV edx, 0
	CALL Clrscr
	CALL initSnake
	CALL Paint
	CALL createFood
	CALL StartGame
	MOV eax, white + (black * 16)
	CALL SetTextColor
	JMP menu
main ENDP

initSnake PROC USES ebx edx
	MOV dh, 13
	MOV dl, 47
	MOV bx, 1
	CALL saveIndex
	
	MOV dh, 14
	MOV dl, 47
	MOV bx, 2
	CALL saveIndex
	
	MOV dh, 15
	MOV dl, 47
	MOV bx, 3
	CALL saveIndex
	
	MOV dh, 16
	MOV dl, 47
	MOV bx, 4
	CALL saveIndex
	ret
initSnake ENDP

clearMem PROC
	
	MOV dh, 0
	MOV bx, 0
	
	oLoop:
		CMP dh, 24
		JE endOLoop
		
		MOV dl, 0
		iLoop:
			CMP dl, 80
			JE endILoop
			
			CALL saveIndex
			
			INC dl
			JMP iLoop
			
		endILoop:
	
		INC dh
		JMP oLoop
	endOLoop:
	
	MOV tR, 16
	MOV tC, 47
	
	MOV hR, 13
	MOV hC, 47
	
	MOV eGame, 0
	MOV eTail, 1
	MOV d, 'w'
	MOV newD, 'w'
	MOV cScore, 0
	
	ret
clearMem ENDP

startGame PROC USES eax ebx ecx edx
		
		MOV eax, white + (black * 16)
		CALL SetTextColor
		MOV dh, 24
		MOV dl, 0
		CALL GotoXY
		MOV edx, OFFSET scoreS
		CALL WriteString
	
		INVOKE getStdHandle, STD_INPUT_HANDLE
		MOV myHandle, eax
		MOV ecx, 10
		
		INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
		INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
		
	more:
		INVOKE GetNumberOfConsoleInputEvents, myHandle, ADDR numInp
		MOV ecx, numInp
		
		CMP ecx, 0
		JE done
			
		INVOKE ReadConsoleInput, myHandle, ADDR temp, 1, ADDR bRead
		MOV dx, WORD PTR temp
		CMP dx, 1
		JNE SkipEvent
		
			MOV dl, BYTE PTR [temp+4]
			CMP dl, 0
			JE SkipEvent
				MOV dl, BYTE PTR [temp+10]
				
				CMP dl, 1Bh
				JE quit
				
				CMP d, 'w'
				JE case1
				CMP d, 's'
				JE case1
				
				JMP case2
				
				case1:
					CMP dl, 25h
					JE case11
					CMP dl, 27h
					JE case12
					JMP SkipEvent
					
					case11:
						MOV newD, 'a'
						JMP SkipEvent
					case12:
						MOV newD, 'd'
						JMP SkipEvent
				
				case2:
					CMP dl, 26h
					JE case21
					CMP dl, 28h
					JE case22
					JMP SkipEvent
					
					case21:
						MOV newD, 'w'
						JMP SkipEvent
					case22:
						MOV newD, 's'
						JMP SkipEvent
				
	SkipEvent:
		JMP more
		
	done:
		
		MOV bl, newD
		MOV d, bl
		CALL MoveSnake
		MOV eax, DelTime
		CALL Delay
		
		MOV bl, d
		MOV newD, bl
	
		CMP eGame, 1
		JE quit
		
		JMP more
		quit:
		CALL clearMem
		MOV delTime, 150
	ret
startGame ENDP

MoveSnake PROC USES ebx edx

	CMP eTail, 1		;if (eTail == 1)
	JNE NoETail
	
		MOV dh, tR		;search = a[tR][tC]
		MOV dl, tC
		CALL accessIndex
		DEC bx			;search--;
		MOV search, bx
		
		MOV bx, 0
		CALL saveIndex
		
		CALL GotoXY		;erase console[tR][tC]
		MOV eax, white + (black * 16)
		CALL SetTextColor
		MOV al, ' '
		CALL WriteChar
		PUSH edx
		MOV dl, 79
		MOV dh, 23
		CALL GotoXY
		POP edx
		
		MOV al, dh
		DEC al
		MOV rM, al		;rM = tR-1
		ADD al, 2
		MOV rP, al		;rP = tR+1
		
		MOV al, dl
		DEC al
		MOV cM, al		;cM = tC-1
		ADD al, 2
		MOV cP, al		;cP = tC+1
		
		CMP rP, 24		;if (rp == 24)
		JNE next1
			MOV rP, 0	;rP = 0
	
		next1:	
		CMP cP, 80		;if (cP == 80)
		JNE next2
			MOV cP, 0	;cP = 0
		
		next2:
		CMP rM, 0		;if (rM < 0)
		JGE next3	
			MOV rM, 23	;rM = 23
		
		next3:
		CMP cM, 0		;if (cM < 0)
		JGE next4
			MOV cM, 79	;cM = 79
		
		next4:
		
		MOV dh, rM
		MOV dl, tC
		CALL accessIndex
		CMP bx, search		;if (a[rM][tC] == search)
		JNE melseif1
			MOV tR, dh	;tR = rM
			JMP mendif
		
		melseif1:
		MOV dh, rP
		CALL accessIndex
		CMP bx, search		;else if (a[rP][tC] == search)
		JNE melseif2
			MOV tR, dh	;tR = rP
			JMP mendif
		
		melseif2:
		MOV dh, tR
		MOV dl, cM
		CALL accessIndex	;else if (a[tR][cM] == search)
		CMP bx, search
		JNE melse
			MOV tC, dl	;tC = cM
			JMP mendif
		
		melse:
			MOV dl, cP	;else tC = cP
			MOV tC, dl
		
		mendif:
	
	NoETail:
	
	MOV eTail, 1
	MOV dh, tR
	MOV dl, tC
	MOV tmpR, dh
	MOV tmpC, dl
	
	whileTrue:
	
		MOV dh, tmpR
		MOV dl, tmpC
		CALL accessIndex
		DEC bx
		
		MOV search, bx
		
		PUSH ebx
		ADD bx, 2
		CALL saveIndex
		POP ebx
		
		CMP bx, 0
		JE break
		
		MOV al, dh
		DEC al
		MOV rM, al		;rM = tmpR-1
		ADD al, 2
		MOV rP, al		;rP = tmpR+1;
		
		MOV al, dl
		DEC al
		MOV cM, al		;cM = tmpC-1
		ADD al, 2
		MOV cP, al		;cP = tmpC+1
		
		CMP rP, 24		;if (rp == 24)
		JNE next21
			MOV rP, 0	;rP = 0
	
		next21:	
		CMP cP, 80		;if (cP == 80)
		JNE next22
			MOV cP, 0	;cP = 0
		
		next22:
		CMP rM, 0		;if (rM < 0)
		JGE next23	
			MOV rM, 23	;rM = 23
		
		next23:
		CMP cM, 0		;if (cM < 0)
		JGE next24
			MOV cM, 79	;cM = 79
		
		next24:
		
		MOV dh, rM
		MOV dl, tmpC
		CALL accessIndex
		CMP bx, search		;if (a[rM][tmpC] == search)
		JNE elseif21
			MOV tmpR, dh	;tmpR = rM
			JMP endif2
		
		elseif21:
		MOV dh, rP
		CALL accessIndex
		CMP bx, search		;else if (a[rP][tmpC] == search)
		JNE elseif22
			MOV tmpR, dh	;tmpR = rP
			JMP endif2
		
		elseif22:
		MOV dh, tmpR
		MOV dl, cM
		CALL accessIndex	;else if (a[tmpR][cM] == search)
		CMP bx, search
		JNE else2
			MOV tmpC, dl	;tmpC = cM
			JMP endif2
		
		else2:
			MOV dl, cP	;else tmpC = cP
			MOV tmpC, dl
		
		endif2:
		JMP whileTrue
	break:
	
	MOV al, hR
	DEC al
	MOV rM, al		;rM = hR-1
	ADD al, 2
	MOV rP, al		;rP = hC+1;
	
	MOV al, hC
	DEC al
	MOV cM, al		;cM = hC-1
	ADD al, 2
	MOV cP, al		;cP = hC+1
	
	CMP rP, 24		;if (rp == 24)
	JNE next31
		MOV rP, 0	;rP = 0
	
	next31:	
	CMP cP, 80		;if (cP == 80)
	JNE next32
		MOV cP, 0	;cP = 0
	
	next32:
	CMP rM, 0		;if (rM < 0)
	JGE next33	
		MOV rM, 23	;rM = 23
	
	next33:
	CMP cM, 0		;if (cM < 0)
	JGE next34
		MOV cM, 79	;cM = 79
	
	next34:
	
	CMP d, 'w'
	JNE elseif3
		MOV al, rM
		MOV hR, al
		JMP endif3
	
	elseif3:
	CMP d, 's'
	JNE elseif32
		MOV al, rP
		MOV hR, al
		JMP endif3
	
	elseif32:
	CMP d, 'a'
	JNE else3
		MOV al, cM
		MOV hC, al
		JMP endif3
	
	else3:
		MOV al, cP
		MOV hC, al
	
	endif3:
	
	MOV dh, hR
	MOV dl, hC
	
	CALL accessIndex
	CMP bx, 0
	JE NoHit
	
	MOV eax, 4000
	MOV dh, 24
	MOV dl, 11
	
	CALL GotoXY
	MOV edx, OFFSET hitS
	CALL WriteString
	CALL Delay
	MOV eGame, 1
	ret	
	
	NoHit:
	MOV bx, 1
	CALL saveIndex
	
	MOV cl, fC
	MOV ch, fR
	
	CMP cl, dl
	JNE foodNotGobbled
	CMP ch, dh
	JNE foodNotGobbled
	
	CALL createFood
	MOV eTail, 0
	
	MOV eax, white + (black * 16)
	CALL SetTextColor
	
	PUSH edx
	
	MOV dh, 24
	MOV dl, 7
	CALL GotoXY
	MOV eax, cScore
	INC eax
	CALL WriteDec
	MOV cScore, eax
	
	POP edx
	
	foodNotGobbled:
	
	CALL GotoXY
	MOV eax, blue + (white * 16)
	CALL setTextColor
	MOV al, ' '
	CALL WriteChar
	MOV dh, 24
	MOV dl, 79
	CALL GotoXY
	
	ret
MoveSnake ENDP

createFood PROC USES eax ebx edx
	
	redo:
	MOV eax, 24
	CALL RandomRange
	MOV dh, al
	
	MOV eax, 80
	CALL RandomRange
	MOV dl, al
	
	CALL accessIndex
	
	CMP bx, 0
	JNE redo
	
	MOV fR, dh
	MOV fC, dl
	
	MOV eax, white + (cyan * 16)
	CALL setTextColor
	CALL GotoXY
	MOV al, ' '
	CALL WriteChar
	
	ret
createFood ENDP

accessIndex PROC USES eax esi edx
	MOV bl, dh
	MOV al, 80
	MUL bl
	PUSH dx
	MOV dh, 0
	ADD ax, dx
	POP dx
	MOV si, ax
	SHL si, 1
			
	MOV bx, a[si]
	
	ret
accessIndex ENDP

saveIndex PROC USES eax esi edx
	PUSH ebx
	MOV bl, dh
	MOV al, 80
	MUL bl
	PUSH dx
	MOV dh, 0
	ADD ax, dx
	POP dx
	MOV si, ax
		
	POP ebx
	
	SHL si, 1
			
	MOV a[si], bx
	ret
saveIndex ENDP

Paint PROC USES eax edx ebx esi

	MOV eax, blue + (white * 16)
	CALL SetTextColor

	MOV dh, 0
	
	loop1:
		CMP dh, 24
		JGE endLoop1
		
		MOV dl, 0
		
		loop2:
			CMP dl, 80
			JGE endLoop2
			CALL GOTOXY
			
			MOV bl, dh
			MOV al, 80
			MUL bl
			PUSH dx
			MOV dh, 0
			ADD ax, dx
			POP dx
			MOV si, ax
			SHL si,1
			
			MOV bx, a[si]
			
			CMP bx, 0
			JE NoPrint
			
			CMP bx, 0FFFFh
			JE printHurdle
			
			MOV al, ' '
			CALL WriteChar
			JMP noPrint
			
			PrintHurdle:
			
			MOV eax, blue + (gray * 16)
			CALL SetTextColor
			
			MOV al, ' '
			CALL WriteChar
			
			MOV eax, blue + (white * 16)
			CALL SetTextColor
			
			NoPrint:
			
			INC dl
			JMP loop2
		endLoop2:
		
		INC dh
		JMP loop1
	endLoop1:
	
	ret
Paint ENDP

GenLevel PROC
	
	CMP al, 1
	JNE nextL
		
	ret
	
	nextL:
	CMP al, 2
	JNE nextL2
		
		MOV dh, 0
		MOV bx, 0FFFFh
		
		rLoop:	
			CMP dh, 24
			JE endRLoop
			
			MOV dl, 0
			CALL saveIndex
			MOV dl, 79
			CALL saveIndex
			INC dh
			JMP rLoop
		endRLoop:
		
		MOV dl, 0
		
		cLoop:
			CMP dl, 80
			JE endCLoop
			
			MOV dh, 0
			CALL saveIndex
			MOV dh, 23
			CALL saveIndex
			INC dl
			JMP cLoop
			
		endCLoop:
		
	ret
	nextL2:
		
		MOV newD, 'd'
		MOV dh, 11
		MOV dl, 0
		MOV bx, 0FFFFh
		
		cLoop2:
			CMP dl, 80
			JE endCLoop2
			
			CALL saveIndex
			INC dl
			JMP cLoop2
		endCloop2:
		
		MOV dh, 0
		MOV dl, 39
		
		rLoop2:
			CMP dh, 24
			JE endRLoop2
			
			CALL saveIndex
			INC dh
			JMP rLoop2
		
		endRLoop2:
	
	ret
GenLevel ENDP

END main