	.text
	.equ 	HEX0,		0xFF200020	#hex0 address base
	.equ	WAIT_DELAY,			9000000 #I think this might be redundent because wait_dealy is decalred in data.
	.equ	WAIT_DELAY2,		36000000 # longer because of pattern
	.equ	LetterArraySize,		20	#currently we only have []hello_ _ _ in the array
	.equ	threePeat, 	4		#make it repate 3 times, a three peat if you will or a three repeat, threepeat weezyF.
	.global _start
_start:
	movia 	r5, HEX0		# move r5 to be the hex base address.
#make an index
	movia 	r6, LetterArray	#points to first element. offsets allow next element. in array
	ldw		r9, 0(r6)		#load the first element into r9
	stwio	r0, 0(r5)		# Display value off to HEX0
	movia 	r11, LetterArraySize			#execute 4 times, for the 4 display	
	movia 	r13, 9000000		#delay of 9 million cycles?
	#movia 	r14, 4				#USed for the counter for patternC 
	 	

Hello_Buffs:

#	add 	r6, r6, r9		#add r9 (H) to the r6 register.

	#mov		r6, r9			#copy r9 into r6 #REDUNDENT and poor use of memory /registers. delete
	#erase previous display to get scroll. done automatically by the shift left logical imiidiate (SLLI), fills with 0
	stwio	r9, 0(r5)		#display newest thing to screen, display r6 contents to hex
	slli	r9, r9, 8		#shift the H now
	#get next letter: increment array index, add to r9
	addi 	r6, r6, 4		#increment the index/ increment the address.
	ldw		r7, 0(r6)		#load value at that address at r6, load into r7, for keeping, add to r9
	add		r9, r7, r9
	subi 	r11, r11, 1		#DECREMENT, should go 4 times	
#will probably be looping very fast so everything will look lit up.
#at least 4 of them


	beq		r11, r0, SequenceAB
	movia r12, 0	#set the delay counter to 0
	blt		r12, r13, Delay_Hello_Buffs
	br		Hello_Buffs



SequenceAB:
#now transition to the ABABAB pattern
	movia r8, threePeat #needs to go to 3 times to zero, so start at 4 and compare at 0 so only 3 cycles, i was off by 1
	movia r12, WAIT_DELAY2
A:
	movia r6, PatternA #load entire pattern into r6.
	ldwio r9, 0(r6)
	stwio r9, 0(r5)
	subi  r8, r8, 1
	beq	  r8, r0, SequenceCBlank #wiill go to C next. TODO
	movia r12, 0 #r12 is used for the delay
	br Delay_PatternA #wait
	
B:	
	movia r6, PatternB #load entire pattern into r6.
	ldwio r9, 0(r6)
	stwio r9, 0(r5)
	movia r12, 0 #r12 is used for the delay
	br Delay_PatternB #wait

	br SequenceAB

SequenceCBlank:
	movia r8, threePeat #reset the counter so it does the pattner C blnk 3 times.
C:
	movia r6, PatternC #load entire pattern into r6.
	ldwio r9, 0(r6)
	stwio r9, 0(r5)
	subi  r8, r8, 1
	beq	  r8, r0, Restart #wiill go to blank next. TODO
	movia r12, 0 #r12 is used for the delay
	br Delay_PatternC #wait
	
Blank:	
	movia r6, PatternBlank #load entire pattern into r6.
	ldwio r9, 0(r6)
	stwio r9, 0(r5)
	movia r12, 0 #r12 is used for the delay
	br Delay_PatternBlank #wait

	br Restart



Delay_Hello_Buffs:
	addi r12, r12, 1
	beq r12, r13, Hello_Buffs
	br Delay_Hello_Buffs

Delay_PatternA:
	addi r12, r12, 1
	beq r12, r13, B
	br Delay_PatternA

Delay_PatternB:
	addi r12, r12, 1
	beq r12, r13, A
	br Delay_PatternB

Delay_PatternC:
	addi r12, r12, 1
	beq r12, r13, Blank
	br Delay_PatternC

Delay_PatternBlank:
	addi r12, r12, 1
	beq r12, r13, C
	br Delay_PatternBlank


	
Restart:
	#need to  reset everthing.
	movia 	r6, LetterArray	#points to first element. offsets allow next element. in array
	movia r11, LetterArraySize
	ldw		r9, 0(r6)		#load the first element into r9
	br Hello_Buffs



.data
#HEX_INDEX:	.word	4	#counter so we know to loop 4 times
#WAIT_DELAY: .word 	9000000	# simple counter based delay. 
LetterArray: 
	.word  0x00, 0x76, 0x79, 0x38, 0x38,0x3F, 0x00, 0x7F, 0x3E, 0x71, 0x71, 0x6D, 0x40, 0x40,0x40, 0x00, 0x00, 0x00, 0x00
		# off, H	, E ,	L,		L,   0,		_, B, U, F, F, S, _, _
PatternA:
	.word 0x49494949 #Pattern A
PatternB:
	.word 0x36363636 #pattern B
PatternC:
	.word 0x7F7F7F7F #pattern C all on except dot
PatternBlank:
	.word 0x00000000 #pattern Blank all off. 

.end #put this at the end!
