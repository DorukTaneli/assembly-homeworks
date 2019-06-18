
# Register Contents:
# $s0 = n	--> Count
# $s1 = Q 	--> Multiplier
# $s2 = M 	--> Multiplicand
# $s3 = A 	
# $s4 = V 	--> Overflow from A when right-shift
# $s5 = Q-1 	


.data
	
	# Strings
	str_multiplicand:		.asciiz "\nMultiplicand in Decimal: "
	str_multiplier:			.asciiz "\nMultiplier in Decimal: "
	str_result:			.asciiz "\nResult in Binary:\n"


	# Syscall variables
	sys_print_int:			.word 1
	sys_print_binary:		.word 35
	sys_print_string:		.word 4
	sys_read_int:			.word 5
	sys_exit:			.word 10


.text
.globl main

main:
	#initialize N, A, V, Q-1
	addi $s0, $zero, 0	#N=0
	addi $s3, $zero, 0	#A=0
	addi $s4, $zero, 0	#V=0
	addi $s5, $zero, 0	#Q-1=0

	# get multiplier
	lw   $v0, sys_print_string
	la   $a0, str_multiplier
	syscall
	lw   $v0, sys_read_int
	syscall
	add  $s1, $zero, $v0

	# get multiplicand
	lw   $v0, sys_print_string
	la   $a0, str_multiplicand
	syscall
	lw   $v0, sys_read_int
	syscall
	add  $s2, $zero, $v0



check_counter:

	# check for the loop counter
	beq  $s0, 33, exit


	#branching according to Q0 and Q-1
	andi $t0, $s1, 1		# $t0 = Q0
	beq  $t0, $zero, case_0x	# if (Q0 == 0), 0x
	j    case_1x			# if (Q0 == 1), 1x

case_0x: 				# Q0 = 0
	beq  $s5, $zero, case_00	# if (Q-1 == 0), case_00
	j    case_01			# if (Q-1 == 1), case_01

case_1x:				# Q0 = 1
	beq  $s5, $zero, case_10	# if (Q-1 == 0), case_10
	j    case_11			# if (Q-1 == 1), case_11


	#evaluate cases
case_00:
	#Arithmetic Shift
	j    shift			# jump to shifting

case_01:
	#Addition and Arithmetic Shift
	add  $s3, $s3, $s2		# add M to A
	andi $s5, $s5, 0		# Q=0, so Q-1 will be 0
	j    shift			# jump to shifting

case_10:
	#Subtraction and Arithmetic Shift
	sub  $s3, $s3, $s2		# sub M from A
	ori  $s5, $s5, 1		# Q=1, so Q-1 will be1
	j    shift			# jump to shifting

case_11:
	#Arithmetic Shift
	j    shift 			# jump to shifting


shift:
	andi $t0, $s3, 1		# t0 = LSB of A
	bne  $t0, $zero, V		# if LSB of U not zero(overflow), jump to V
	srl  $s4, $s4, 1		# shift right logical V

shift_others:
	sra  $s3, $s3, 1		# shift right arithmetic A
	ror  $s1, $s1, 1		# rotate right Q
	addi $s0, $s0, 1		# decrement loop counter
	beq  $s0, 32, save		# save results if it is the last step
	j    check_counter		# loop again

save:
	add  $t1, $zero, $s3		# save A in $t1
	add  $t2, $zero, $s4		# save V in $t2
	j    check_counter		# loop again	
	
V:
	andi $t0, $s4, 0x80000000	# t0 = MSB of V
	bne  $t0, $zero, v_msb_1	# If MSB == 1, goto v_msb_1
	srl  $s4, $s4, 1		# MSB == 0, so shift right logical V
	ori  $s4, $s4, 0x80000000	# MSB of V = 1
	j    shift_others		# jump to shift other variables

v_msb_1:
	srl  $s4, $s4, 1		# shift right logical V
	ori  $s4, $s4, 0x80000000	# MSB of V = 1
	j    shift_others		# jump to shift other variables



exit:
	# print Result:
	lw   $v0, sys_print_string
	la   $a0, str_result
	syscall
	
	# Print A
	lw   $v0, sys_print_binary
	add  $a0, $zero, $t1
	syscall
	# Print V
	lw   $v0, sys_print_binary
	add  $a0, $zero, $t2
	syscall
	
	# Exit
	lw   $v0, sys_exit
	syscall
