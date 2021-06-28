# Problem:
# Given A STRING which consists of LOWER ALPHABETIC CHARACTERS (a-z), any other character will be given an error
# Count the number of different characters in it
# For example: s = "cabca", the output should be "There are 3 different characters a, b, c
# 
# How to solve this problem:
# 1. Analyze the input string and put each different character into a array
# 2. Sort that array in alphabetic order
# 3. Show the result
# 
# Who made this program" : Ha Quoc Thang - 201768070
#
# Source: i made it myself with helps from teammate Bao Duc and sorting idea from stackoverflow


.data
	# Input and result string
	occurred_character_array: .space 104 		# This array stores characters occurred in input string
	str: .space 512 				# Input string can hold 512 bytes
	
	# Somne messages
	ERROR_msg: .asciiz "Only character from a-z allowed!"
	input_msg: .asciiz "Please enter a string here: "
	result_msg: .asciiz "This string has those characters: "
	begin_count_msg: .asciiz "There are "
	end_count_msg: .asciiz " different character(s): "

.text
main:
	li 	$s3, ','			# $s3 = ',' dau phay, comma
	li 	$s4, 32				# $t3 = 'space', phim cach
	li 	$s5, '\n'			# $s5 = '\n', ki hieu ket thuc xau
	li 	$s6, 97				# $s6 = 'a'
	li 	$s7, 123			# $s7 = 'z'
	la 	$s0, occurred_character_array	# $s0 = occurred_character_array
	
# Get input from user:

	li	$v0,11				# In dau xuong dong moi lan nhap
	li	$a0,'\n'
	syscall
	# Show input message
	li	$v0, 4				# Load 4 into $v0 for printing a string
	la	$a0, input_msg			# Load address of input message into $a0
	syscall					# Print the message
	
	# Get the input
	li	$v0, 8				# Load 8 into $v0 for getting a input string from keyboard
	la	$a0, str			# $a0=address of str
	li	$a1, 512			# $a1=max length of str
	syscall					# Get the input
	
	
	# Start analyzing the input string
	li 	$t0, 0				# i=0 (counter of analyze)
	jal 	analyze				# Analyze the input
	jal	outterLoop			# Sort the array of characters found
	jal	result				# Display the result

# Return to main
backToMain:
	jr $ra

# Analyze the input
analyze:
	add 	$t1, $a0, $t0 		# $t1 = address of str[i] (each character of the string)
	lb 	$t2, 0($t1)		# Load the current character str[i] into $t2
	beq 	$t2, $s5, backToMain	# If the current character is the end of string, it's the sign that we've got every occurred characters, let's head back to the main!
	beq 	$t2, $s4, next_char	# If the current character is "space" symbol, leave it and check the next char
	j 	loop_check_is_a_to_z	# Check if the current character is in a-z or not

# Check next char
next_char:				
	addi	$t0, $t0, 1		# i = i + 1
	j 	analyze

# Check a-z or not
loop_check_is_a_to_z:
	li 	$t4, 0 			# Default flag: $t4 = 0, this char is not in a to z
	sle 	$t4, $t2, $s7 		# Set $t4 = 1 if this char is (~z)
	beqz 	$t4, ERROR		# If $t4 = 0, meaning this char is after the "z" character, show input ERROR, else it's (...~z)
	sge 	$t4, $t2, $s6 		# Set $t4 = 1 (again) if char is (a~z)
	beqz 	$t4, ERROR		# If $t4 = 0, meaning it's before the the "a" character, show input ERROR
	li 	$t5, 0			# j=0 (counter of loop_check_existed)
	j 	loop_check_existed	

# Check if the current character is found yet or not
loop_check_existed:
	add 	$t6, $s0, $t5		# $t6 = address of occurred_character_array[j]
	lb 	$t7, 0($t6)		# Load the current character occurred_character_array[j] into $t7
	beq 	$t7, $zero, add_array	# If we reach the end of occurred_character_array then the current character in the input is not in occurred_character_array. Store it into occurred_character_array as new found character
	beq	$t2, $t7, next_char	# If this current char is already in occurred_character_array then step to next char
	
	#if this current char != this current char from occurred_character_array, step to next
	addi 	$t5, $t5, 1		# j = j + 1
	j 	loop_check_existed	# continue checking

# Add the current char from input into curred_character_array	
add_array:
	sb 	$t2, 0($t6)		# Store current char into occurred_character_array
	j 	next_char		# check next char from input
	
	
	
				############################################################################	
				############### The analysis was done, reuse some registers ################
				############################################################################	


# Sorting loop
# Outter loop
outterLoop:
	add 	$t1, $zero, $zero	# $t1 = Flag: flag = 1 means curred_character_array is not sorted yet, 0 means sort progress was done
	add 	$a0, $zero, $s0		# $a0 is a pointer pointing to each character from occurred_character_array

# Inner loop	
innerLoop:
	lb 	$t2, 0($a0)		# Load curred_character_array[z] into $t2
	lb 	$t3, 1($a0)		# Load curred_character_array[z+1] into $t3
	beqz	$t3, continue		# Check if there's only 1 character in input string
	slt 	$t4, $t2, $t3		# Compare occurred_character_array[z] with occurred_character_array[z+1]
	bne 	$t4, $zero, continue	# If $t2 < $t3, $t4 = 1, no change needed! Check next
	addi 	$t1, $zero, 1		# Else change Flag to 1 (means not sorted yet)
	sb 	$t2, 1($a0)		# Swap these 2 positions
	sb 	$t3, 0($a0)		# 

# Continue the loop or End the loop
continue:
	addi 	$a0, $a0, 1		# Point to the next position in occurred_character_array
	lb 	$t5, 1($a0)		# Get the next position's data
	bne 	$t5, $zero, innerLoop	# If it's not the end of occurred_character_array, inner loop again
	bne 	$t1, $zero, outterLoop	# If $t1 != 0, means the sort progress is not done yet, outter loop again
	j	backToMain		
	


				############################################################################	
				############# The sort process was done, reuse some registers ##############
				############################################################################	



# Print number of characters and print them all out	
result:	
	li	$t5, 0			# Set counter to 0 again to count /// NOT NECESSERY beacause last data of inner loop should be 0
	jal 	count			# Call out "Count" function to print out how many characters has found in the input string
	li	$t5, 0			# Set counter to 0 again to print the result
	j 	display_characters

# Count the number of characters
count:
	add 	$t6, $s0, $t5		# $t6 = address of occurred_character_array[j]
	lb 	$a0, 0($t6)		# Load the current character occurred_character_array[j] into $a0
	beq 	$a0, $zero, count_result# If the current character is the end of occurred_character_array, print the count result
	addi	$t5, $t5, 1		# counter += 1 //counter is number of characters
	j 	count

# Print count result
count_result:
	li	$v0, 4			# Load 4 into $v0 for printing a string
	la	$a0, begin_count_msg	# Load address of first count message into $a0
	syscall				# Print the message
	
	li	$v0,1			# Load 1 into $v0 for printing a integer
	add	$a0,$zero,$t5		# Load data of $t5 into $a0 to print out
	syscall				# Print the integer (number of character)
	
	li	$v0, 4			# Load 4 into $v0 for printing a string
	la	$a0, end_count_msg	# Load address of second count message into $a0
	syscall				# Print the message
	j	backToMain		# Jump back to main
	
# Progress to print each character separately with a comma between them
display_characters:
	# Print a character
	add 	$t6, $s0, $t5		# $t6 = address of occurred_character_array[j]
	lb 	$a0, 0($t6)		# Load the current character occurred_character_array[j] into $a0
	beq 	$a0, $zero, END		# If the current character is the end of occurred_character_array, it means there no character left to print
	li 	$v0, 11			# Syscall to print a character
	syscall
	sb	$zero, 0($t6)		# Clean the array			
	
	# Print a comma
	lb	$a0, 1($t6)		# Load next character of occurred_character_array into $a0
	beq	$a0, $zero, main	# If the next character is the end of occurred_character_array, then no comma will be print out
	li	$v0, 11			# Syscall to print a character
	li 	$a0, ','		# Load a comma into $a0
	syscall				# Print the comma
	
	addi 	$t5, $t5, 1		# j = j + 1
	j 	display_characters	# loop again till the end

# Invalid input error message	
ERROR:
	li	$v0, 4			# Load 4 into $v0 for printing a string
	la	$a0, ERROR_msg		# Load address of ERROR message into $a0
	syscall				# Print the message
	j 	main			# End the program
# End the program
END:	
	li	$v0, 10 		#terminated
	syscall
