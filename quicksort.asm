# These are similar to #define statements in a C program.
# However, the .eqv directions *cannot* include arithmetic.

.eqv  MAX_WORD_LEN 32
.eqv  MAX_WORD_LEN_SHIFT 5
.eqv  MAX_NUM_WORDS 100
.eqv  WORD_ARRAY_SIZE 3200  # MAX_WORD_LEN * MAX_NUM_WORDS
.eqv NEW_LINE_ASCII 10

# Global data

.data
WORD_ARRAY: 	.space WORD_ARRAY_SIZE
NUM_WORDS: 	.space 4
MESSAGE1:	.asciiz "Number of words in string array: "
MESSAGE2:	.asciiz "Contents of string array:\n"
MESSAGE3:	.asciiz "Enter strings (blank string indicates end):\n"
SPACE:		.asciiz " "
NEW_LINE:	.asciiz "\n"
EMPTY_LINE:	.asciiz ""

# For strcmp testing...
MESSAGE_A:	.asciiz "Enter first word: "
MESSAGE_B:	.asciiz "Enter second word: "
BUFFER_A:	.space MAX_WORD_LEN
BUFFER_B:	.space MAX_WORD_LEN

	.text
#####
#####	
INIT:
	# Save $s0, $s1 and $s2 on stack.
	addi $t0, $sp, 12
	sub $sp, $sp, $t0
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	
	la $a0, MESSAGE3
	li $v0, 4
	syscall
	
	# Initialize NUM_WORDS to zero.
	#
	# Load start of word array into $s0; we'll directly read
	# input words into this array/buffer. 
	la $t0, NUM_WORDS
	sw $zero, 0($t0)
	la $s0, WORD_ARRAY
		
READ_WORD:
	add $a0, $s0, $zero
	li $a1, MAX_WORD_LEN
	li $v0, 8
	syscall
	
	# Empty string? If so, finish. An emtpy string
	# consists of the single newline character.
	lbu $t0, 0($s0)
	li $t1, NEW_LINE_ASCII
	beq $t0, $t1, CALL_QUICKSORT
	
	# Increment # of words; at the maximum??
	la $t0, NUM_WORDS
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)
	addi $t2, $zero, MAX_NUM_WORDS
	beq $t1, $t2, CALL_QUICKSORT
	
	# Otherwise proceed to the next work
	addi $s0, $s0, MAX_WORD_LEN
	j READ_WORD
	

	
CALL_QUICKSORT:	
	# Before call to quicksort
	jal FUNCTION_PRINT_WORDS
	
	# Assemble arguments
	la $a0, WORD_ARRAY
	li $a1, 0
	la $t0, NUM_WORDS
	lw $a2, 0($t0)
	addi $a2, $a2, -1
	jal FUNCTION_HOARE_QUICKSORT
			
	# Restore from stack the callee-save registers used in this code
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	
	# After call to quicksort
	jal FUNCTION_PRINT_WORDS

EXiT:
	li $v0, 10
	syscall
	
	
	
#####
#####	
FUNCTION_PRINT_WORDS:
	la $a0, MESSAGE1
	li $v0, 4
	syscall
	
	la $t0, NUM_WORDS
	lw $a0, 0($t0)
	li $v0, 1
	syscall
	
	la $a0, NEW_LINE
	li $v0, 4
	syscall
	
	la $a0, MESSAGE2
	li $v0, 4
	syscall
	
	li $t0, 0
	la $t1, WORD_ARRAY
	la $t2, NUM_WORDS
	lw $t2, 0($t2)
	
LOOP_FPW:
	beq $t0, $t2, EXIT_FPW
	add $a0, $t1, $zero
	li $v0, 4
	syscall
	addi $t0, $t0, 1
	addi $t1, $t1, MAX_WORD_LEN
	j LOOP_FPW
	
EXIT_FPW:
	jr $ra
	
	
#####
#####

#
# $a0 contains the starting address of the array of strings,
#    where each string occupies up to MAX_WORD_LEN chars.
# $a1 contains the starting index for the partition
# $a2 contains the ending index for the partition
# $v0 contains the index that is to be returned by the
#    partition algorithm
#

FUNCTION_PARTITION:
	addi $sp, $sp, -28
	add $s0, $a0, $zero
	add $s1, $a1, $zero
    	add $s2, $a2, $zero
    	add $s4, $ra, $zero
    	# pivot address
	add $s3, $s1, $s2 	# lo + hi
    	srl $s3, $s3, 1 	# (lo + hi) / 2
    	# convert index to byte address
    	sll $s1, $s1, 5
	sll $s2, $s2, 5
	sll $s3, $s3, 5
	add $s1, $s1, $s0
	add $s2, $s2, $s0
    	add $s3, $s3, $s0 
    	add $s5, $s1, $zero	# lo
    	add $s6, $s2, $zero	# hi
    	
    	addi $s1, $s1, -MAX_WORD_LEN 	# i
    	addi $s2, $s2, MAX_WORD_LEN	# j
    
PARTITION_LOOP:

PARTITION_LOW_LOOP:
	addi $s1, $s1, MAX_WORD_LEN
	add $a0, $s1, $zero
	add $a1, $s3, $zero
	
	# save reg to stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
    	sw $s2, 8($sp)
    	sw $s3, 12($sp)
    	sw $s4, 16($sp)
    	sw $s6, 20($sp)
    	sw $s6, 24($sp)
	jal FUNCTION_STRCMP
	# load from stack
	lw $s0, 0($sp)
	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	lw $s6, 20($sp)
    	lw $s6, 24($sp)
    	
    	# check A[i] < pivot && i in range
    	addi $t1, $s1, MAX_WORD_LEN
    	bgt $t1, $s6, PARTITION_HIGH_LOOP
	beq $v0, -1, PARTITION_LOW_LOOP
	

PARTITION_HIGH_LOOP:
	addi $s2, $s2, -MAX_WORD_LEN
	add $a0, $s2, $zero
	add $a1, $s3, $zero
	
	# save reg to stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
    	sw $s2, 8($sp)
    	sw $s3, 12($sp)
    	sw $s4, 16($sp)
    	sw $s6, 20($sp)
    	sw $s6, 24($sp)
	jal FUNCTION_STRCMP
	# load from stack
	lw $s0, 0($sp)
	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	lw $s6, 20($sp)
    	lw $s6, 24($sp)
    	
    	# check A[j] > pivot && j in range
    	addi $t2, $s2, -MAX_WORD_LEN
    	blt $t2, $s5, PARTITION_CMP
	beq $v0, 1, PARTITION_HIGH_LOOP
	
PARTITION_CMP:	
	blt $s1, $s2, PARTITION_SWAP
	sub $s2, $s2, $s0
	srl $v0, $s2, 5
	addi $sp, $sp, 28
    	jr $s4

PARTITION_SWAP:
	add $a0, $s1, $zero
	add $a1, $s2, $zero
	addi $a2, $zero, MAX_WORD_LEN
	
	# save reg to stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
    	sw $s2, 8($sp)
    	sw $s3, 12($sp)
    	sw $s4, 16($sp)
    	sw $s6, 20($sp)
    	sw $s6, 24($sp)
	jal FUNCTION_SWAP
	# load from stack
	lw $s0, 0($sp)
	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	lw $s6, 20($sp)
    	lw $s6, 24($sp)
    	
	j PARTITION_LOOP
	
#
# $a0 contains the starting address of the array of strings,
#    where each string occupies up to MAX_WORD_LEN chars.
# $a1 contains the starting index for the quicksort
# $a2 contains the ending index for the quicksort
#
# THIS FUNCTION MUST BE WRITTEN IN A RECURSIVE STYLE.
#

FUNCTION_HOARE_QUICKSORT:
	addi $sp, $sp, -20
	add $s0, $a0, $zero
    	add $s1, $a1, $zero
    	add $s2, $a2, $zero
    	add $s4, $ra, $zero
    	bge $s1, $s2, QUICKSORT_RETURN
    	
    	# save reg to stack
    	sw $s0, 0($sp)
    	sw $s1, 4($sp)
    	sw $s2, 8($sp)
    	sw $s4, 16($sp)
    	jal FUNCTION_PARTITION
    	lw $s0, 0($sp)
    	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s4, 16($sp)
    	add $s3, $v0, $zero
    	
    	# set quicksort args (A, lo, p)
    	add $a0, $s0, $zero
	add $a1, $s1, $zero
	add $a2, $s3, $zero
	
	# save reg to stack
	sw $s0, 0($sp)
    	sw $s1, 4($sp)
    	sw $s2, 8($sp)
    	sw $s3, 12($sp)
    	sw $s4, 16($sp)
	jal FUNCTION_HOARE_QUICKSORT
	lw $s0, 0($sp)
    	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
	
	# set quicksort args (A, p+1, hi)
	add $a0, $s0, $zero
	addi $a1, $s3, 1
	add $a2, $s2, $zero
	
	# save reg to stack
	sw $s0, 0($sp)
    	sw $s1, 4($sp)
    	sw $s2, 8($sp)
    	sw $s3, 12($sp)
    	sw $s4, 16($sp)
	jal FUNCTION_HOARE_QUICKSORT
	lw $s0, 0($sp)
    	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	
QUICKSORT_RETURN: 
	addi $sp, $sp, 20
    	jr $s4

#
# Solution for FUNCTION_STRCMP must appear below.
#
# $a0 contains the address of the first string
# $a1 contains the address of the second string
# $v0 will contain the result of the function.
#

FUNCTION_STRCMP:
	add $t1, $zero, $a0
        add $t2, $zero, $a1
        
STRCMP_LOOP:
	lb $t3, ($t1)  
        lb $t4, ($t2)
        bne $t3, $t4, STRCMP_NE
        beqz $t3, STRCMP_EQ # Breaks on end of line
        
        addi $t1, $t1, 1
        addi $t2, $t2, 1
        j STRCMP_LOOP
     
STRCMP_NE:
	addi $v0, $zero, -1
	blt $t3, $t4, STRCMP_RET
	addi $v0, $zero, 1
STRCMP_RET:
   	jr $ra


STRCMP_EQ:
	li $v0, 0
	jr $ra

#
# $a0 contains the address of the first string array
# $a1 contains the address of the second string array
# $a2 contains the maximum length of the arrays
# 
	
FUNCTION_SWAP:
	add $t1,$zero,$a0
        add $t2,$zero,$a1
        
SWAP_LOOP:
	lb $t3,($t1)  
        lb $t4,($t2)
        
        sb $t4, ($t1)
        sb $t3, ($t2)
        
        add $t5, $t3, $t4
        beqz $t5, RETURN_SWAP

	addi $t1, $t1, 1
        addi $t2, $t2, 1
	j SWAP_LOOP
                
RETURN_SWAP:
   	jr $ra
