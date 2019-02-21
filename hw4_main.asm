.data
map_filename: .asciiz "A:/Users/Artesod/Desktop/important/cse220hw4/map3.txt"
# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"
map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
.asciiz "don't touch this"

# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "please don't mess with this"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 1 1 1 1 1 1 
.asciiz "Really, please don't mess with this string"

welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"

.text
print_map:
	

	la $s0, map #load map
	
	lb $s1, 0($s0) #get row 
	addi $s1, $s1, -48
	li $s5, 10
	mul $s1, $s1, $s5
	lb $s2, 1($s0)
	addi $s2, $s2,-48
	add $s1, $s1, $s2 
	
	lb $s3, 3($s0) #get col
	addi $s3, $s3, -48 #convert to int
	mul $s3, $s3, $s5 #multiply by 10
	lb $s4, 4($s0)
	addi $s4, $s4, -48
	add $s3, $s3, $s4


	mul $t0, $s1, $s3
	addi $t0, $t0, 6
	la $t1, map
	addi $t1, $t1, 6
	li $t2, 0
	li $t3, 0x00000080
	li $t5, '\n'



print_map_loop:
	lb $a0, ($t1) #load char
	beq $a0, $t5, print_map_null #if null char print it out regularly
	and $t4, $a0, $t3 # see if char is hidden
	srl $t4, $t4, 7
	beq $t4, 1, print_map_hidden #if it is hidden branch
	li $v0, 11 #else print normally
	syscall
	addi $t1, $t1, 1
	addi $t2, $t2, 1
	bne $t2, $t0, print_map_loop #loop if not equal to row*col
	jr $ra #return

print_map_hidden:
li $a0, ' ' #load it with blank char
li $v0, 11
syscall
addi $t1, $t1, 1
addi $t2, $t2, 1
bne $t2, $t0, print_map_loop #loop if not equal to row*col
jr $ra #return

print_map_null:
li $v0, 11 #print out null char
syscall
addi $t1, $t1, 1
addi $t2, $t2, 1
bne $t2, $t0, print_map_loop
jr $ra

print_player_info:
# the idea: print something like "Pos=[3,14] Health=[4] Coins=[1]"
la $a0, pos_str
li $v0, 4
syscall

la $t0, player
lb $a0, ($t0)
li $v0, 1
syscall

li $a0, ' '
li $v0, 11
syscall

lb $a0, 1($t0)
li $v0, 1
syscall

la $a0, health_str
li $v0, 4
syscall

lb $a0, 2($t0)
li $v0, 1
syscall

la $a0, coins_str
li $v0, 4
syscall

lb $a0, 3($t0)
li $v0, 1
syscall

li $a0, ']'
li $v0, 11
syscall

jr $ra


.globl main
main:
la $a0, welcome_msg
li $v0, 4
syscall

# fill in arguments
jal init_game

la $a0, map
li $a1, 3
li $a2, 2
jal get_cell

move $a0, $v0
li $v0, 11
syscall

# fill in arguments
la $a0, map
li $a1, 2
li $a2, 2
jal reveal_area

li $s0, 0  # move = 0

game_loop:  # while player is not dead and move == 0:
jal print_map # takes no args

jal print_player_info # takes no args

# print prompt
la $a0, your_move_str
li $v0, 4
syscall

li $v0, 12  # read character from keyboard
syscall
move $s1, $v0  # $s1 has character entered
li $s0, 0  # move = 0

li $a0, '\n'
li $v0 11
syscall

# handle input: w, a, s or d
# map w, a, s, d  to  U, L, D, R and call player_turn()

# if move == 0, call reveal_area()  Otherwise, exit the loop.

j game_loop

game_over:
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall

# choose between (1) player dead, (2) player escaped but lost, (3) player escaped and won

won:
la $a0, you_won_str
li $v0, 4
syscall
j exit

failed:
la $a0, you_failed_str
li $v0, 4
syscall
j exit

player_dead:
la $a0, you_died_str
li $v0, 4
syscall

exit:
li $v0, 10
syscall

.include "hw4.asm"
