TITLE Final_Project_Steyn.asm
;created by Jacques Steyn
; 11/30/2019
;csci2525


Include Irvine32.inc


.data
	titlePrompt BYTE   "+++++ TIC TAC TOE +++++",0h
	helpPrompt1 BYTE "top row = 1 2 3",0h
	helpPrompt2 BYTE "mid row = 4 5 6",0h
	helpPrompt3 BYTE "bot row = 7 8 9",0h
	option1Prompt BYTE "1. Player Vs Player",0h
	option2Prompt BYTE "2. Player Vs Computer",0h
	option3Prompt BYTE "3. Computer Vs Computer",0h
	exitPrompt BYTE	   "4. exit",0h
	pointyThing BYTE   "->",0h

	board BYTE		  "_", 20h, "|", 20h, "_", 20h, "|", 20h, "_"
		rSize = ($ - board)
					 BYTE "_", 20h, "|", 20h, "_", 20h, "|", 20h, "_"
					 BYTE "_", 20h, "|", 20h, "_", 20h, "|", 20h, "_"

.code


playerVsPlayer PROTO			; main gameplay loop for pvp
displayBoard PROTO				; displays the board on the screen
EnterPlayerDecision PROTO		; takes the users input when playing
checkValid PROTO				; checks the user input while playing
checkWin PROTO					; checks to see if anyone has won
computerVsComputer PROTO		; main gameplay loop for computerVsComputer
EnterComputerDecision PROTO		; computer randomly chooses spots
playerVsComputer PROTO			; main gameplay loop for player vs computer
resetGame PROTO					; 'resets' the game/board(so you can play again)


main PROC	
	mainl1:								;main menu loop
		mov ebx,OFFSET board
		INVOKE resetGame
		call clrscr
		mov edx,OFFSET titlePrompt
		call WriteString
		call crlf
		call crlf
		
		mov edx, OFFSET helpPrompt1
		call writeString
		call crlf
		mov edx, OFFSET helpPrompt2
		call writeString
		call crlf
		mov edx, OFFSET helpPrompt3
		call writeString
		call crlf
		call crlf
		mov edx,OFFSET option1Prompt        ; main menu
		call writeString
		call crlf

		mov edx,OFFSET option2Prompt
		call writeString
		call crlf

		mov edx,OFFSET option3Prompt
		call writeString
		call crlf

		mov edx,OFFSET exitPrompt
		call writeString
		call crlf
		mov edx,OFFSET pointyThing
		call writeString
		call readDec			; letters will be 0s 

		cmp eax,4
		je QuitGame ; exit/quit program
		
		cmp eax,3
		je CvC

		cmp eax,2
		je PvC

		cmp eax,1
		je PvP

		jmp mainl1

		PvP:
			mov ebx,OFFSET board
			INVOKE playerVsPlayer
		jmp mainl1
		PvC:
			mov ebx,OFFSET board
			INVOKE playerVsComputer
		jmp mainl1

		CvC:
			mov ebx,OFFSET board
			INVOKE computerVsComputer
		jmp mainl1

		QuitGame:
		call crlf 
		call waitMsg

		exit
main ENDP


playerVsPlayer PROC
	;Description: this is the main gameplay loop for playing against another person
	;Receives:	ebx with the offset of the board
	;Returns:	nothing (it just plays the game)
	.data
		player1turn BYTE "PLAYER 1's TURN!",0h
		player2turn BYTE "PLAYER 2's TURN!",0h			 
		PlayerHasWonPvP BYTE "s has WON!",0h
		stalematePvPPrompt BYTE "STALEMATE!",0h
	.code
		mov edi,1
		call clrscr
		PvPGameLoop:				; edi = 1 (player 1)
			call clrscr
			INVOKE displayBoard		; edi = 2 (player 2)
			call crlf

			push edi
			push ebx
			INVOKE checkWin		;edx = 1 if x's win
			pop ebx				;edx = 2 if o's win
			pop edi				;edx = 0 if no one has won yet
								;edx = 3 if stalemate
			cmp edx,1
			je XsWonPvP

			cmp edx,2
			je OsWonPvP

			cmp edx,3
			je stalematePvp

			cmp edi,1
			je pTurn1

			cmp edi,2
			je pTurn2
			

			pTurn1:
			mov edx,OFFSET player1turn		;if edi = 1 then player 1's turn
			call writeString
			call crlf
			;call waitMsg

			push ebx
			INVOKE EnterPlayerDecision		;player enters a move
			pop ebx

			mov edi,2						;alternate turns. so after player1 its player2
			jmp PvPGameLoop					; loop runs until someone wins/loses or stalemate

			pTurn2:
			mov edx,OFFSET player2turn		;if edi = 2 then player 2's turn
			call writeString
			call crlf
			;call waitMsg

			push ebx
			INVOKE EnterPlayerDecision		;player enters a move
			pop ebx

			mov edi,1						;alternate turns. so after player2 its player1
			jmp PvPGameLoop					; loop runs until someone wins/loses or stalemate


			call waitMsg
			jmp PvPGameLoop


		XsWonPvP:							; if x's win, this is where it ends
		call crlf
		mov eax,"X"
		call writeChar
		mov edx,OFFSET PlayerHasWonPvP		;display who won
		call writeString
		call crlf
		call waitMsg
		ret									;let players look at board before returning to menu
											; where they can quit or play again/play another mode
		OsWonPvP:							; if o's win, this is where it ends
		call crlf
		mov eax,"O"
		call writeChar
		mov edx,OFFSET PlayerHasWonPvP		;display who won
		call writeString
		call crlf
		call waitMsg
		ret

		stalematePvp:						; this is where it ends if the board is a stalemate
		call crlf
		call crlf
		mov edx, OFFSET stalematePvPPrompt	; tell players it is a stalemate,let them look at board
		call writeString					; then they can return to main menu

		call crlf
		call waitMsg
		ret
playerVsPlayer ENDP



displayBoard PROC
	;Description:	prints out the board and prints X's in red background and
	;				O's in yellow background
	;Receives:	ebx with offset of board
	;Returns: nothing(just prints out board)
	.data
		
	.code
		mov ecx,27
		mov esi,0
		push ebx
		call crlf
		displayLoop:
			cmp esi,9				; there are 9 characters in line
			je makeNewLine			; so make a new line every 9 chars
			jmp DontMakeNewLine
			makeNewLine:
			call crlf
			mov esi,0
			DontMakeNewLine:
			
			mov al,[ebx]

			cmp al,"X"							;if char is an x 
			je printXRed						; then go to print background red

			cmp al,"O"
			je printOYellow						;if char is an o
			jmp printNormal						; then go to print yellow background

			printXRed:							;prints x in red background
			push eax
			mov eax,black + (lightRed * 16)
			call setTextColor

			pop eax			
			call writeChar
			mov eax,white + (black * 16)			;make sure to set colors back to normal
			call setTextColor						
			jmp continueForward

			printOYellow:							;prints o in yellow background
			push eax
			mov eax,black + (yellow * 16)
			call setTextColor

			pop eax
			call writeChar
			mov eax,white + (black * 16)
			call setTextColor
			jmp continueForward

			printNormal:						; if its not an X or O then it goes here
			call writeChar						; and prints without color just normally

			continueForward:
			inc esi							; esi keeps track of how many chars/line
			inc ebx							;go to the next char on/in the board
			loop displayLoop
			pop ebx
		call crlf
		
		ret
displayBoard ENDP


EnterPlayerDecision PROC
	;Description: lets the user enter a move, and then checks if it is valid
	;Receives: ebx with board offset
	;Returns: [ebx]/board with a new x or o in a spot
	.data
		enterPrompt BYTE "Enter Square(1-9)->",0h
	.code	
		SquareInput:
			call crlf
			mov edx, OFFSET enterPrompt
			call WriteString
			call readDec							;eax now has userinput
			push ebx
			INVOKE checkValid
			pop ebx
			cmp edx,0
			je SquareInput			; just go back to the start if input not valid
									; continue if its not 0
			add ebx,eax
			cmp edi,1				;player 1 will have X's
			je inputForPlayer1
			cmp edi,2				;player 2 will have O's
			je inputForPlayer2
			inputForPlayer1:
			mov edx,"X"
			mov [ebx],dl
			ret
			inputForPlayer2:
			mov edx,"O"
			mov [ebx],dl
			
			ret
			
			
		ret
EnterPlayerDecision ENDP

checkValid PROC
	;Description: checks to see if the userinput is valid and returns 0 in edx if it is not and 1 if it is
	;Receives: ebx with offset of the board
	;Returns:	edx = 0 if user input isnt valid. edx = 1 if user input is valid
	.data

	.code
		cmp eax,9
		ja notValid			; if its above 9 then its not valid

		cmp eax,1
		jb notValid			; if its below 1 its not valid

		;now correct the user input to an actual board spot
		cmp eax,9
		je changeTo26

		cmp eax,8
		je changeTo22

		cmp eax,7
		je changeTo18
		
		cmp eax,6
		je changeTo17

		cmp eax,5
		je changeTo13

		cmp eax,4
		je changeTo9

		cmp eax,3
		je changeTo8

		cmp eax,2
		je changeTo4

		cmp eax,1
		je changeTo0

		changeTo0:
			mov eax,0
			jmp keepgoing
		changeTo4:
			mov eax,4
			jmp keepgoing
		changeTo8:
			mov eax,8
			jmp keepgoing
		changeTo9:
			mov eax,9
			jmp keepgoing
		changeTo13:
			mov eax,13
			jmp keepgoing
		changeTo17:
			mov eax,17
			jmp keepgoing
		changeTo18:
			mov eax,18
			jmp keepgoing
		changeTo22:
			mov eax,22
			jmp keepgoing
		changeTo26:
			mov eax,26
			jmp keepgoing
		keepgoing:

		;now check to see if the spot is already taken
		add ebx,eax
		mov edx,"_"
		cmp [ebx],dl		; if the spot is = "_" then it is empty and valid
		je valid1		
		jmp notValid
		valid1:
		mov edx,1		; edx = 1 if the spot is not taken/valid
		ret
		notValid:
		mov edx,0		; edx = 0 if the spot is taken/invalid
		ret	
checkValid ENDP

checkWin PROC

	;Description: searches the rows, columns and 2 diagnols for 3 kinds of the same symbol
	;			  in a row by adding them together (ie 3 X's = someNumber,  3 O's = someNumber)
	;			  and if they are (someNumber for 3Xs) or (someNumber for 3Os) then a one of the players has won(edx = 1 or 2)
	;Receives: ebx with the offset of the board
	;Returns: edx = 1 (player 1 wins), edx = 2 (player 2 wins), edx = 0 (there is no win) edx =3 if stalemate

	.data
		

	.code
		mov edi,0
		push ebx
		mov ecx,3
		rowLoop:
			
			push ecx
			push ebx
			mov ecx,3
			rowLoopInside:				;row loop checks all the rows for 3 symbols in a ...row
				mov eax,0
				mov al, BYTE PTR [ebx]
				add edi,eax
				add ebx,4
				loop rowLoopInside
			pop ebx
			add ebx,9
			pop ecx
			mov eax,108h				;108 h = hex value of 3 X's added together (ie 3 in a row)
			cmp edi,eax					; (looking back on this im not sure what the numbers actually are)
			je XsWinRows				; (but it doesnt matter... it still works in the same way)

			mov eax,0EDh					;ED h = hex value of 3 O's added together (ie 3 in a row)
			cmp edi,eax
			je OsWinRows
			mov edx,0					;edx 0 if no wins found in rows here
			jmp gogogo1

			XsWinRows:
			mov edx,1					; edx = 1 if X's win
			jmp outsideRowLoop

			OsWinRows:
			mov edx,2					; edx = 2 if O's win
			jmp outsideRowLoop

			gogogo1:
			mov edi,0
			
			loop rowLoop
		outsideRowLoop:

		pop ebx

		cmp edx,1
		je done1					;my code is very redundant here
									; but im too lazy to change it now
		cmp edx,2
		je done2
		jmp searchColumnsNext
		done1:
		ret

		done2:
		ret

		searchColumnsNext:
		mov edi,0
		push ebx
		mov ecx,3
		ColumnLoop:
			
			push ecx
			push ebx
			mov ecx,3
			ColumnLoopInside:					; this loop searches the 'columns' of the board for 3 symbols ina row
				mov eax,0
				mov al, BYTE PTR [ebx]
				add edi,eax
				add ebx,9
				loop ColumnLoopInside
			pop ebx
			add ebx,4
			pop ecx
			mov eax,108h				;108 h = hex value of 3 X's added together (ie 3 in a columns)
			cmp edi,eax						;(again.. not sure if these numbers are exactly correct)
			je XsWinRows2

			mov eax,0EDh					;ED h = hex value of 3 O's added together (ie 3 in a columns)
			cmp edi,eax
			je OsWinRows2
			mov edx,0					;edx 0 if no wins found in columns here
			jmp gogogo2

			XsWinRows2:
			mov edx,1					; edx = 1 if X's win
			jmp outsideColumnLoop

			OsWinRows2:
			mov edx,2					; edx = 2 if O's win
			jmp outsideColumnLoop

			gogogo2:
			mov edi,0
			
			loop columnLoop
		outsideColumnLoop:
		pop ebx

		cmp edx,1
		je done3

		cmp edx,2
		je done4
		jmp searchDiagnal1Next
		done3:
		ret

		done4:
		ret

		searchDiagnal1Next:
		mov edi,0
		push ebx

		mov ecx,3
		Diagnal1Loop:				;diagnal from upper left to bottom right
			mov eax,0
			mov al, BYTE PTR [ebx]
			add edi,eax

			add ebx,13
			loop Diagnal1Loop
		pop ebx						; edi now has 108h, EDh or something else

		mov eax,108h				;108 h = hex value of 3 X's added together (ie 3 in a diagnals)
		cmp edi,eax
		je XsWinDiagnal1

		mov eax,0EDh					;108 h = hex value of 3 X's added together (ie 3 in a diagnals)
		cmp edi,eax
		je OsWinDiagnal1
		jmp gogogo3

		OsWinDiagnal1:
		mov edx,2
		ret

		XsWinDiagnal1:
		mov edx,1
		ret


		gogogo3:
		mov edi,0
		push ebx

		mov ecx,3
		add ebx,8
		Diagnal2Loop:			;diagnal from upper right to bottom left
			mov eax,0
			mov al, BYTE PTR [ebx]
			add edi,eax

			add ebx,5
			loop Diagnal2Loop
		pop ebx


		mov eax,108h				;108 h = hex value of 3 X's added together (ie 3 in a columns)
		cmp edi,eax
		je XsWinDiagnal2

		mov eax,0EDh					;108 h = hex value of 3 X's added together (ie 3 in a columns)
		cmp edi,eax
		je OsWinDiagnal2
		jmp gogogo4

		OsWinDiagnal2:
		mov edx,2
		ret

		XsWinDiagnal2:
		mov edx,1
		ret

		gogogo4:
		mov edx,0				; edx = 0 if the game is ongoing but not stale

		mov ecx,27
		push ebx
		mov esi,0
		checkStaleLoop:					; this loop adds 1 to esi if a spot is filled with x or o
			mov al,BYTE PTR [ebx]		; then, we check to see if edi = 9
			mov edi,"X"					; becuase if it got this far(ie no wins), and the board is full
			cmp edi,eax					; then it is a stalemate
			je spotIsFilled
			mov edi,"O"
			cmp edi,eax
			je spotIsFilled

			jmp spotNotFilled

			spotIsFilled:
			add esi,1			;add 1 to esi if spot is x or o
			spotNotFilled:
			inc ebx
			loop checkStaleLoop
			pop ebx

			cmp esi,9
			je gameStale
			mov edx,0			; if game is ongoing but no wins then edx =0
			ret
			gameStale:
			mov edx,3			; if game is a stalemate edx = 3


		ret
checkWin ENDP



computerVsComputer PROC
		;Description: the main gameplay loop for the computers to play
		;Receives:	ebx with the offset of the board
		;Returns: nothing
	.data
		computer1turn BYTE "COMPUTER 1's TURN!",0h
		computer2turn BYTE "COMPUTER 2's TURN!",0h			 
		computerHasWonCvC BYTE "s has WON!",0h
		stalemateCvCPrompt BYTE "STALEMATE!",0h
	.code
		;ebx has board offset
		;INVOKE displayBoard
		mov edi,1
		call clrscr
		CvCGameLoop:				; edi = 1 (player 1)
			call clrscr
			INVOKE displayBoard		; edi = 2 (player 2)
			call crlf

			push edi
			push ebx
			INVOKE checkWin		;edx = 1 if x's win
			pop ebx				;edx = 2 if o's win
			pop edi				;edx = 0 if no one has won
								;edx = 3 if stalemate
			cmp edx,1
			je XsWonCvC1

			cmp edx,2
			je OsWonCvC1

			cmp edx,3
			je stalemateCvC

			cmp edi,1
			je CvCTurn1

			cmp edi,2
			je CvCTurn2
			

			CvCTurn1:						; computer1's turn
			mov edx,OFFSET computer1turn
			call writeString
			call crlf
			;call waitMsg

			push ebx
			mov eax,1000					; i put the 1 second delay here because
			call Delay						; it makes the timing the most constant/reliable
			INVOKE EnterComputerDecision
			pop ebx

			mov edi,2
			jmp CvCGameLoop

			CvCTurn2:						; computer2's turn
			mov edx,OFFSET computer2turn
			call writeString
			call crlf
			;call waitMsg

			push ebx
			mov eax,1000				
			call Delay
			INVOKE EnterComputerDecision
			pop ebx

			mov edi,1
			jmp CvCGameLoop


			call waitMsg
			jmp CvCGameLoop


		XsWonCvC1:								; if the x's won this is where it ends
		call crlf
		mov eax,"X"
		call writeChar
		mov edx,OFFSET computerHasWonCvC
		call writeString
		call crlf
		call waitMsg
		ret

		OsWonCvC1:								; if the o's won this is where it ends
		call crlf
		mov eax,"O"
		call writeChar
		mov edx,OFFSET computerHasWonCvC
		call writeString
		call crlf
		call waitMsg
		ret


		stalemateCvC:							; if the the game is a stalemate this is where it ends
		call crlf
		call crlf
		mov edx, OFFSET stalemateCvCPrompt
		call writeString

		call crlf
		call waitMsg
		ret
computerVsComputer ENDP


EnterComputerDecision PROC
	;Description: the computer(s) 'enter' a move to place an x or o on the board
	;Receives: ebx with offset of board
	;Returns:	ebx with new x or o on the board
	.data
		
		
	.code
		
		ComputerInput:
			
			mov eax,0
			;call crlf
			
			
			call randomize			; seed the random
			
			call random32			; eax now has random large number		
			mov edx,0
			mov esi,9
			div esi					;edx now has remainder 0-8
									; we want 1-9 ,so i add 9 to 0 if it is 0
			mov eax,0
			cmp edx,eax
			je addNinetoZero
			jmp theNumberisFine

			addNinetoZero:
			add edx,9

			mov eax,edx

			theNumberisFine:
			mov eax,edx			;eax has the computer's choice of spot
			push ebx

			push ebx
			add ebx,13			;check to see if the middle spot (number 13 or "5") is taken
			mov edx,"_"			
			cmp [ebx],dl
			je takeTheMiddle	; if it isnt taken then the computer will take it
			jmp doWhatever		; if it is taken then just continue

			takeTheMiddle:
			mov eax,5
			doWhatever:
			pop ebx

			INVOKE checkValid		; here the computer will generate random numbers over and over until 1 is
			pop ebx					; considered valid 
			cmp edx,0
			je ComputerInput		; just go back to the start if input not valid
									; continue if its not 0
			add ebx,eax
			cmp edi,1				;computer 1 will have X's
			je inputForComputer1
			cmp edi,2				;computer 2 will have O's
			je inputForComputer2
			inputForComputer1:
			mov edx,"X"
			mov [ebx],dl
			ret
			inputForComputer2:
			mov edx,"O"
			mov [ebx],dl
			
			ret
			
			
		ret
EnterComputerDecision ENDP 


playerVsComputer PROC
	;Decription: the main gameplay loop of player v computer
	;Receives: ebx with offset of board
	;Returns:	nothing

	.data
		playerTurnPvC BYTE "PLAYER 1's TURN!",0h
		computerTurnPvC BYTE "Computers's TURN!",0h			 
		HasWonPvC BYTE "s has WON!",0h
		stalematePvCPrompt BYTE "STALEMATE!",0h
	.code
		;ebx has board offset
		;INVOKE displayBoard
		mov edi,1
		call clrscr
		PvCGameLoop:				; edi = 1 (player 1)
			call clrscr
			INVOKE displayBoard		; edi = 2 (player 2)
			call crlf

			push edi
			push ebx
			INVOKE checkWin		;edx = 1 if x's win
			pop ebx				;edx = 2 if o's win
			pop edi				;edx = 0 if no one has won
								;edx = 3 if stalemate
			cmp edx,1
			je XsWonPvC			; this loop is basically the same loop as the other 2
								; except that one of the 'players' is a computer and also
			cmp edx,2			; everything is renamed to function correctly
			je OsWonPvC

			cmp edx,3
			je stalematePvC

			cmp edi,1
			je pTurn3

			cmp edi,2
			je CTurn3
			

			pTurn3:
			mov edx,OFFSET playerTurnPvC
			call writeString
			call crlf
			;call waitMsg

			push ebx
													; player makes a mov
			INVOKE EnterPlayerDecision				;player doesnt have delay, but computer does 
			pop ebx			

			mov edi,2
			jmp PvCGameLoop

			CTurn3:
			mov edx,OFFSET computerTurnPvC
			call writeString
			call crlf
			;call waitMsg

			push ebx
			mov eax,1000				
			call Delay
			INVOKE EnterComputerDecision				; computer  makes a move
			pop ebx

			mov edi,1
			jmp PvCGameLoop


			call waitMsg
			jmp PvCGameLoop


		XsWonPvC:					; if x wins(player)
		call crlf
		mov eax,"X"
		call writeChar
		mov edx,OFFSET HasWonPvC
		call writeString
		call crlf
		call waitMsg
		ret

		OsWonPvC:						;if o wins(computer)
		call crlf
		mov eax,"O"
		call writeChar
		mov edx,OFFSET HasWonPvC
		call writeString
		call crlf
		call waitMsg
		ret

		stalematePvC:						;if stalemate
		call crlf
		call crlf
		mov edx, OFFSET stalematePvCPrompt
		call writeString

		call crlf
		call waitMsg
		ret
playerVsComputer ENDP


resetGame PROC
	;Description: resets the board/game if user wants to play more
	;Receives:	ebx with offset of board
	;Returns: ebx/board now empty of x and 0s

	.data

	.code
		mov ecx,27						;there are 27 chars i think in the 'board'
		clearBoardLoop:
				mov al,BYTE PTR [ebx]		;move 1 but of ebx into al

				mov edi,"X"					;mov x or 0 in edi then compare with eax(which has the char from the board)
				cmp eax,edi					;if it is a x or o then make it an _ again
				je cleanSpot				;otherwise continue

				mov edi,"O"
				cmp eax,edi
				je cleanSpot

				jmp CurrSpotFine
				cleanSpot:
				mov eax,5Fh
				mov [ebx],al
				CurrSpotFine:
				inc ebx				;move to next char
			loop clearBoardLoop


			mov eax,0				;clear the registers just to be safe
			mov ebx,0
			mov ecx,0
			mov edx,0
			mov edi,0
			mov esi,0

		ret
resetGame ENDP



END main