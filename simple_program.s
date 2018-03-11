	.text
	.equ 	HEX0,		0xFF200020	#hex0 address base
	.equ	WAIT_DELAY,			4000000 #I think this might be redundent because wait_dealy is decalred in data.
	.equ	ScrollArraySize,		8	#currently we only have []hello_ _ _ in the array
	.equ 	BUTTONS, 0xFF200050
	.equ 	LOGICAL_SHIFT, 	8 #Use this so if we need to shift less than 8 for w/e reason 
	.equ 	DEBOUNCE, 10 #tune later for debounce
	.global _start
_start:
	movia 	r5, HEX0		# move r5 to be the hex base address.
	movia 	r8, BUTTONS		# put base address to r8
	movia 	r4, 0x00  	# this is our old state so we can do comparison of buttons
	#make an index
	movia 	r6, ScrollArrayRL	#points to first element. offsets allow next element. in array
	ldw		r9, 0(r6)		#load the first element into r9
	stwio	r0, 0(r5)		# Display value off to HEX0
	movia 	r11, ScrollArraySize			#execute 4 times, for the 4 display	
	movia 	r13, WAIT_DELAY		#delay of 9 million cycles?
	movia 	r10, DEBOUNCE
	movia 	r2, 0X0 #use this as the count.
	movia 	r14, 0x01
	movia 	r15, 0x02

RL_init:
	movia r2, 0
	movia r6, ScrollArrayRL
	ldw	r9, 0(r6) #load base element to r9
	movia r11, ScrollArraySize #reset our counter to keep track of our scroll
RL_Scroll_Loop:
	stwio	r9, 0(r5)		#display newest thing to screen, display r6 contents to hex
	slli	r9, r9, LOGICAL_SHIFT		#shift the H now
	#get next hex: increment array index, add to r9
	addi 	r6, r6, 4		#increment the index/ increment the address.
	ldw		r7, 0(r6)		#load value at that address at r6, load into r7, for keeping, add to r9
	add		r9, r7, r9
	subi 	r11, r11, 1		#DECREMENT, should go 8 times	
	beq		r11, r0, RL_init
	movia r12, 0
	br Delay_RL

br RL_init

SET_VALUE:
br SET_VALUE #THIS IS WHERE THE FLOW CONTROL IS. 

Delay_RL:
	addi r12, r12, 1
	beq r12, r13, RL_Scroll_Loop
	#check the status of buttons. should be fast enough we are in MHz
	#ldwio r3, 0(r8) #read the button put into r3
	movia r2, 0 #reset the debounce counter
	ldwio r3, 0(r8) #READ THE BUTTON SWITCH
	beq r3, r15, COUNT_2
	beq r3, r14, COUNT_1

	br Delay_RL

COUNT_1:
	addi r2, r2, 1
	beq r2, r10, SET_VALUE
	ldwio r3, 0(r8)
	beq r3, r14, COUNT_1
	
br Delay_RL

COUNT_2:	
	

Delay_LR:
	addi r12, r12, 1
	beq r12, r13, LR_Scroll_Loop
	#check the status of buttons. should be fast enough we are in MHz
	ldwio r3, 0(r8) #read the button put into r3
	bne	r3, r4, RL_Scroll_Loop
	mov r4, r3
	br Delay_LR


RESET_RL_SCROLL:
	#need to  reset everthing.
	movia 	r6, ScrollArrayRL	#points to first element. offsets allow next element. in array
	movia r11, ScrollArraySize
	ldw		r9, 0(r6)		#load the first element into r9
	br RL_Scroll_Loop





LR_init:
	movia r6, ScrollArrayLR
	ldw	r9, 0(r6) #load base element to r9
	movia r11, ScrollArraySize #reset our counter to keep track of our scroll
	mov r4, r3
LR_Scroll_Loop:
	stwio	r9, 0(r5)		#display newest thing to screen, display r6 contents to hex
	srli	r9, r9, LOGICAL_SHIFT
	addi	r6, r6, 4	#increment array index
	ldw		r7, 0(r6) # lload next element to r7
	add		r9, r7, r9
	subi 	r11, r11, 1

	beq r11, r0, LR_init #loop this mode again.

	#delay
	movia r12, 0
	blt r12, r13, Delay_LR
br LR_init



.data
ScrollArrayRL: 
	.word  0x79, 0x49, 0x49, 0x49, 0x00,0x00, 0x00, 0x00
	#E, then pattern C from question 1: horizontal segments of display.

ScrollArrayLR: 
	.word 0x00,0x00, 0x00, 0x00,  0x49, 0x49, 0x49, 0x47
	#mirror of the LR pattern, not sure if will work because it will change scroll but it will restart from scratch. 
	#thats fine it says button press > "switch mode of display" I am saying that its design is to start with a blank screen. or not


.end #put this at the end!
