#kushal kharel
#simon game

.text
main:
	jal GenerateRandom		# generate random number ($ao hold the random number
	# store random value to memory
	la $t0, randomvalue
	sw $a0, 0($t0)
	la $a1, sequence
	jal save_sequence	# save sequence to memory sequence
	jal increment_max

	li	$v0, 11 #new line
	li	$a0, 10
	syscall
	jal blink_light
	jal user_check

	li	$v0, 11 #new line
	li	$a0, 10
	syscall

#$a0 hold the random number
#$a1 = seed for that generator
GenerateRandom:
	# get the system time
 	li $v0, 30
 	syscall
 	move $a1, $a0		# move the lower 32 bit of systemtime to $a1
 	li $a0, 1		# random generator id
	li $v0, 40		# seed random number grnerator syscall
	syscall
	li	$a1, 5	# upper bound of the range
	li	$v0, 42		# random int range
	syscall
	jr $ra
# set $a0 = number of milliseconds to wait
Wait:
	li $a0, 800
 	move $t0, $a0 	# save timeout to $a0
 	li $v0, 30	# get initial time
 	syscall
 	move $t1, $a0	#save initial time to $t1
 ploop:
 	syscall
 	subu $t2, $a0, $t1	#elapsed = current - initial
 	bltu $t2, $t0, ploop	#is elapsed meout, loop
 	jr $ra
# works fine
 # $ao =  random number
 # $a1 point to text sstring in memory in memory
 # store $a0 to sequence  memory
save_sequence:
	la $t0, randomvalue
	lw $a0, 0($t0)
	la $t3, max
	lw $t4, 0($t3)
	# to save the sequence to right memory addresss
	sll $t4, $t4, 2			#$t4 = $t4 * 4 where $t4 is max value
	add $a1, $a1, $t4
	sw $a0, ($a1)
	jr $ra
# works fine
# $a1 point to the .word in meory
# increment the max by 1 and save it back to memory in max
increment_max:
	la $a1, max
	lw $t0, 0($a1)		# $t0 = 0($a1)
	add $t0, $t0, 1	# $t0 +=1
	sw $t0, 0($a1)		# save it back to )($a0) memory 
	jr $ra
# works fine
# display sequence
#$a1 point to memory address where sequence is store
display_seq:
 	# saving the return address
 	add $sp, $sp, -4
	sw $ra, 0($sp)
 	la $a1, sequence
	sll $t6, $t5, 2
	add $a1, $a1, $t6
 	lw $a0, 0($a1)
 	# branch to specific branch depending on sequence
 	beq, $a0,1, display_one
 	beq, $a0,2, display_two
 	beq, $a0,3, display_three
 	beq, $a0,4, display_four
 # display box one when sequemce is 1
 display_one:
 	li $a0, 4
	li $a1, 4
	li $a2, 1
	li $a3, 10
	jal draw_box
	# restore return address
	lw $ra, 0($sp)
	add $sp, $sp, 4
 	jr $ra
# display box one when sequence is 2
display_two:
 	li $a0, 18
	li $a1, 4
	li $a2, 2
	li $a3, 10
	jal draw_box
	# restore return address
	lw $ra, 0($sp)
	add $sp, $sp, 4
 	jr $ra
# display box three when sequence is 3
display_three:
 	li $a0, 4
	li $a1, 18
	li $a2, 3
	li $a3, 10
	jal draw_box
	# restore return address
	lw $ra, 0($sp)
	add $sp, $sp, 4
 	jr $ra
#display box four when sequence is 4
display_four:
 	li $a0, 18
	li $a1, 18
	li $a2, 4
	li $a3, 10
	jal draw_box
 	# restore return address
 	lw $ra, 0($sp)
	add $sp, $sp, 4
 	jr $ra
#works fine
#Displays a prompt to the user and then wait for input
#$a2 points to the text string that will get displayed to the user
# a0 point to date .word in memory memory
user_entry:
	li $v0,4
	move $a0, $a2		# movie addresss $a2 to $a0
	syscall
	#getting the  number from the user
	li $v0, 12	# prompt the user to enter a number
	syscall
	la $a0, user_input
	subi $v0, $v0, 48
	sw $v0, 0($a0)
	jr $ra
# $t3 hold the max value
# call display sequence to display sequence
# loop while max != 0
blink_light:
	la $t3, max
	lw $t4, 0($t3)
	li $t5, 0		# for memory location to display sequence
	# saving the return address
	add $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)
loop:
	jal display_seq
	jal Wait
	jal clear_display
	add $t5, $t5, 1			#  to calculate memory address in display_seq
	sub $t4, $t4, 1			# $t1 = $t1-1
	bne $t4, 0, loop 		# keep looping until max is not eqial to 0
	# loading return address
	la $s2, 0($sp)
	sw $s1, 4($sp)
	lw $s0, 8($sp)
	lw $ra, 12($sp)
	add $sp, $sp, 16
	jr $ra
# call get entry function
# compare with sequence[i]	 where "i" is address of sequence
# if match loop (while max!= 0 )else display loose
# if pass and max <5 go back to main and do the process agian
# if max > 5 display win
#$t0 hold max
#$t3 hold sequence
# $t4 hold user entry
user_check:
	la $t1, max
	lw $t0, 0($t1)	# set $t0 = max
	li $t5, 0
	# saving the return address
	add $sp, $sp, -8
	#sw $ra, 8($sp)
	sw $ra, 4($sp)
	sw $s1, 0($sp)
loop2:
	la $a2, user_prompt
	jal user_entry	# go to user entry function
	la $a1, sequence
	sll $t6, $t5, 2
	add $a1, $a1, $t6
	lw $t3, ($a1)	# set $t3 = sequence[i] where "i" is address
	la $t6, user_input
	lw $t4, 0($t6)	# set $t0 = max
	add $t5, $t5, 1		# increemnt $t5 so you can get the next value from memory
	bne $t3, $t4, LoseFunction
	#this adds a newline
	li	$v0, 11
	li	$a0, 10
	syscall
	# display correct text
	li $v0, 4
	la $a0, correct
	syscall
	#this adds a newline
	li	$v0, 11
	li	$a0, 10
	syscall
	# loading return address
	la $s1, 0($sp)
	sw $ra, 4($sp)
	#lw $ra, 8($sp)
	add $sp, $sp, 8
	sub $t0, $t0, 1			# subtract max by 1
	bne $t0, 0, loop2
check_max:
	la $a1, max
	lw $t0, 0($a1)
	blt $t0, 5, main	# branch to main if $t0 < 5
	#this adds a newline
	li	$v0, 11
	li	$a0, 10
	syscall
	li $v0, 4
	la $a0, win #tells player they won
	syscall
	j EndProg
# DISPLAY LOSE
LoseFunction:

	li $v0, 11 #new line
	li $a0, 10
	syscall
	li $v0, 4
	la $a0, doesnotmatch
	syscall
	#this adds a newline
	li $v0, 11
	li $a0, 10
	syscall
	li $v0, 4
	la $a0, lose
	syscall
	j EndProg
# $a0 = X cordinate (0-31)
# $a1 = Y cordinate (0-31)
# return $v0 = memory address
calc_address:
	#v0 = base +$a0 * 4 + $a1 * 32 *4
	li $t0, 0x10040000
	sll $a0, $a0, 2		# $a0 * 4
	sll $a1, $a1, 5		# $a1 * 32
	sll $a1, $a1, 2		# $a1 * 4
	add $v0, $t0, $a0	# $v0= t0+ao
	add $v0, $v0, $a1	# $v0 = v0 + a1
	jr $ra
# $a2 = color number (0-7)
# return $v1 = actual numbe to write to the display
get_color:
	la $t0, color_table		# load base
	sll $a2, $a2, 2			# index *4 is offset
	add $a2, $a2, $t0		# adder  base + offset
	lw $v1, 0($a2)			# get actual color from memory
	jr $ra
# $a0 = X cordinate (0-30)
# $a1 = Y cordinate (0-31)
# $a2 = color number (0-7)
draw_dot:
	addiu $sp, $sp, -8	#adjust stack pointer, 2 words
	sw $ra, 4($sp)		#store $ra
	sw $a2, 0($sp)		#store $a2
	jal calc_address	#$vo has address for pixel
	lw $a2, 0($sp)		# restore $a2
	sw $v0, 0($sp)		# store $v0 in spot freed by $a2
	jal get_color		# $v1 has color
	lw $v0, ($sp)		# restor $v0
	sw $v1, 0($v0)		# make dot
	lw $ra, 4($sp)		#load original $ra
	addiu $sp, $sp, 8	# adjust $sp
	jr $ra
#draw a horizontal line
# $a0 = X cordinate (0-30)
# $a1 = Y cordinate (0-31)
# $a2 = color number (0-7)
# $a3 = length of the line (1-32)
horz_line:
	#error check here
	addiu $sp, $sp, -20	#adjust stack pointer, 2 words
	sw $ra, 16($sp)		#store $ra
horzloop:
	#store a regiser here
	sw $a0, 12($sp)		#store $a0
	sw $a1, 8($sp)		#store $a1
	sw $a2, 4($sp)		#store $a2
	sw $a3, 0($sp)		#store $a3
	jal draw_dot
	# restore a register
	lw $a3, 0($sp)		# restore $a3
	lw $a2, 4($sp)		# restore $a2
	lw $a1, 8($sp)		# restore $a1
	lw $a0, 12($sp)		# restore $a0
	add $a0, $a0, 1		#increment x cordinate ( a0)
	addiu $a3, $a3, -1	#decrement the length of the line left (a3)
	bne $a3, $0, horzloop
	lw $ra, 16($sp)		# restore $ra
	addiu $sp, $sp, 20	# adjust $sp
	jr $ra
#draw a vertical line
# $a0 = X cordinate (0-30)
# $a1 = Y cordinate (0-31)
# $a2 = color number (0-7)
# $a3 = length of the line (1-32)
vert_line:
	#error check here
	addiu $sp, $sp, -20	#adjust stack pointer, 2 words
	sw $ra, 16($sp)		#store $ra
vertloop:
	#store a regiser here
	sw $a0, 12($sp)		#store $a0
	sw $a1, 8($sp)		#store $a1
	sw $a2, 4($sp)		#store $a2
	sw $a3, 0($sp)		#store $a3
	jal draw_dot
	# restore a register
	lw $a3, 0($sp)		# restore $a3
	lw $a2, 4($sp)		# restore $a2
	lw $a1, 8($sp)		# restore $a1
	lw $a0, 12($sp)		# restore $a0
	add $a1, $a1, 1		#increment y cordinate ( a1)
	addiu $a3, $a3, -1	#decrement the length of the line left (a3)
	bne $a3, $0, vertloop
	lw $ra, 16($sp)		# restore $ra
	addiu $sp, $sp, 20	# adjust $sp
	jr $ra
# $a0 = X cordinate (0-30)
# $a1 = Y cordinate (0-31)
# $a2 = color number (0-7)
# $a3 = size of the box (1-32)
draw_box:
	move $s0, $a3 		# $t0 = $a3
	addiu $sp, $sp, -24	#adjust stack pointer, 2 words
	sw $ra, 20($sp)		#store $ra
	sw $s0, 16($sp)		#store $s0
boxloop:
	#save a register to stack
	sw $a3, 12($sp)
	sw $a0, 8($sp)		#store $a0
	sw $a1, 4($sp)		#store $a1
	sw $a2, 0($sp)		#store $a2
	jal horz_line
	# restore a register
	lw $a2, 0($sp)		# restore $a2
	lw $a1, 4($sp)		# restore $a1
	lw $a0, 8($sp)		# restore $
	lw $a3, 12($sp)
	add $a1, $a1, 1		#increment y cordinate
	addiu $s0, $s0, -1		#decrement counter
	bne $s0, $0, boxloop
	lw $s0, 16($sp)		#store $s0
	lw $ra, 20($sp)		# restore $ra
	addiu $sp, $sp, 24	# adjust $sp
	jr $ra
clear_display:
		addiu $sp, $sp, -4	#adjust stack pointer
		sw $ra, 0($sp)		#store $ra
		li $a0, 0		#start at 0 (a0=0)
		li $a1, 0		#start at 0(a1 = 0)
		li $a2, 0		#black color (a2 = 0)
		li $a3, 32		#save screen sixe $a3 =32
		jal draw_box
		lw $ra, 0($sp)		# restore $ra
		addiu $sp, $sp, 4	# adjust $sp
		jr $ra

EndProg: #ends the program
	li $v0, 10
	syscall
.data
	color_table:
			.word 0x000000		#black
			.word 0x0000ff		#blue
			.word 0x00ff00		#green
			.word 0xff0000		#red
			.word 0xff00ff		#blue + green
			.word 0xffff00		#green + red
			.word 0xffffff		# white color

	sequence: .word 0,0,0,0,0
	seq_address: .word 0	# sequense address for new sequence
	max:.word 0		# max value
	user_prompt: .asciiz "Enter a value to match sequence: "
	win:   .asciiz "YOU WIN!"
	lose: .asciiz "YOU LOSE!"
	doesnotmatch: .asciiz "Sequence don't MATCH! "

	sequence_string: .asciiz "sequence is: "
	correct : .asciiz "correct"
	randomvalue: .word 0, 0
	user_input: .word 0
