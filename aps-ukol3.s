.data
						; windlx hack (to have nice rows in memory view)
hovno:	.space	40
						; matrix data
matrix:	.float	 2, 2, 3, 4, 5, 2, 2, 3, 4, 5, 7
row_2:	.float	 7, 9, 9,10,11, 7, 9, 9,10,11,14
row_3:	.float	13,14,16,16,17,13,14,16,16,17,21
row_4:	.float	19,20,21,23,23,19,20,21,23,23,28
row_5:	.float	25,26,27,28,30,25,26,27,28,30,35
row_6:	.float	 2, 2, 3, 4, 5, 2, 2, 3, 4, 5, 7
row_7:	.float	 7, 9, 9,10,11, 7, 9, 9,10,11,14
row_8:	.float	13,14,16,16,17,13,14,16,16,17,21
row_9:	.float	19,20,21,23,23,19,20,21,23,23,28
row_A:	.float	25,26,27,28,30,25,26,27,28,30,35

;
;
;
;
;
;
;	postup - WinDLX, memory (single float), "matrix", roztahnout na 11 znaku per radek
;
;
;
;
;
;

.text
	addui	r1, r0, 10			; N (user input)
	lhi	r2, matrix >> 16		; load matrix address
	addui	r2, r2, matrix & 0xffff


						; calculate the pointer to the row following the base row
						; 	baseRow + wordLength*(N + 1)
	shl	r7, r1, 2			; N * 4
	addui	r6, r2, 4			; nextRow = baseRow + wordLength
	addu	r6, r6, r7			; nextRow += N * 4


						; this is the "middle" loop. It is responsible for processing
						; a single row (calc the ratio) and mult/sub all following rows

	subui	r7, r1,	1			; loop ctrl (N-1 rows to process)
loop1:	subui	r7, r7, 1
	addu	r5, r0, r2			; base row pointer reset
						; first we calculate the ratio to multiply the row with
	lf	f0, (r5)
	lf	f1, (r6)

	divf	f2, f1, f0			; f2 = ratio to multiply row elements

						; now we step in the most-inner loop, to iterate over row elements
						; to multiply and subtract them from the rest of the rows

	addui	r3, r1, 1			; loop ctrl (N+1 cols)
loop2:	subui	r3, r3, 1
	
	lf	f0, (r5)
	lf	f1, (r6)

	multf	f0, f0, f2
	subf	f0, f1, f0
	
	sf	(r6), f0

	addui	r5, r5, 4
	addui	r6, r6, 4

	bnez	r3, loop2
	bnez	r7, loop1


exit:	trap	0