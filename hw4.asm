#Joshua Canta
#jcanta
#111544561

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text
error:
	li $v0, 10
	syscall
# Part I
init_game:
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	la $a0, map_filename
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	beq $v0, -1, error
	

	move $a0, $v0
	la $a1, map
	li $a2, 9801
	li $v0, 14
	syscall
	
	move $s0, $v0 #counted chars
	la $t0, map #load map
	
	lb $t1, 0($t0) #get row 
	addi $t1, $t1, -48
	li $t2, 10
	mul $t1, $t1, $t2
	lb $t3, 1($t0)
	addi $t3, $t3,-48
	add $t1, $t1, $t3 
	la $s3, player
	move $s1, $t1 #store row 
	
	lb $t1, 3($t0) #get col
	addi $t1, $t1, -48 #convert to int
	mul $t1, $t1, $t2 #multiply by 10
	lb $t3, 4($t0)
	addi $t3, $t3, -48
	add $t1, $t1, $t3
	move $s2, $t1 #store col
	
	add $t0, $t0, $s0 #traverse to end of array to obtain the health
	addi $t0, $t0, -3
	lb $t1, ($t0)
	addi $t1, $t1, -48
	mul $t1, $t1, $t2
	lb $t3, 1($t0)
	addi $t3, $t3, -48
	add $t1, $t1, $t3
	sb $t1, 2($s3) #store it in bit 2 of player
	
	li $t1, 0 #initialize coins
	sb $t1, 3($s3) #store it in bit 3 of player
	
	sb $0, ($t0)
	addi $t0, $t0, 3
	sub $t0, $t0, $s0
	addi $t0, $t0, 6
	
	li $t3, 0 #row
	li $t4, 0 #col
	
	li $t2, 0x00000080
	li $t5, '@'
	li $t6, '\n'
init_game_loop:
	lb $t1, ($t0) #load byte
	beq $t1, $t6, init_game_terminatingchar
	beq $t1, $t5, init_game_foundhero
	
	xor $t1, $t1, $t2
	sb $t1, ($t0) #store it back in
	
	addi $t4, $t4, 1 #col++
	addi $t0, $t0, 1
	bne $t4, $s2, init_game_loop
	addi $t3, $t3, 1 #row++
	li $t4, 0
	beq $t3, $s1, init_game_end
	j init_game_loop
init_game_foundhero:
	sb $t3, ($s3) #store row index in bit 0 of player
	sb $t4, 1($s3) #store col index in bit 1 of player
	
	xor $t1, $t1, $t2
	sb $t1, ($t0) #store it back in
	
	addi $t4, $t4, 1 #col++
	addi $t0, $t0, 1
	bne $t4, $s2, init_game_loop
	li $t4, 0
	addi $t3, $t3, 1 #row++
	beq $t3, $s1, init_game_end
	j init_game_loop
init_game_terminatingchar:
	addi $t0, $t0, 1 #skip the null terminator 
	j init_game_loop
init_game_end:
	move $s4, $s2
	move $s3, $s1

	li $v0, 16
	syscall
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra


# Part II
is_valid_cell:
	

	move $t0, $a0
	move $t1, $a1
	move $t2, $a2
	
	bltz $t1, v0out # row less than 0
	bltz $t2, v0out #col less than 0

	lb $t3, 0($t0) #get row 
	addi $t3, $t3, -48
	li $t7, 10
	mul $t3, $t3, $t7
	lb $t4, 1($t0)
	addi $t4, $t4,-48
	add $t3, $t3, $t4 
	
	lb $t5, 3($t0) #get col
	addi $t5, $t5, -48 #convert to int
	mul $t5, $t5, $t7 #multiply by 10
	lb $t6, 4($t0)
	addi $t6, $t6, -48
	add $t5, $t5, $t6
	
	bge $t1, $t3, v0out #row greater than or equal to maprowsize
	bge $t2, $t5, v0out #col greater than or equal to mapcolsize
	
	li $v0, 0
	jr $ra
v0out:
	li $v0, -1
	jr $ra
# Part III
get_cell:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal is_valid_cell


	mul $t1, $a1, $t5 #i * num_cols
	add $t1, $t1, $a2 #+ j
	add $t1, $t1, $a0 # + map_addr
	addi $t1, $t1, 6
	
	lb $v0, ($t1)
	lw $ra ($sp)
	addi $sp, $sp, 4
	
	jr $ra

# Part IV
set_cell:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal is_valid_cell
	
	mul $t1, $a1, $t5 #i * num_cols
	add $t1, $t1, $a2 #+ j
	add $t1, $t1, $a0 # + map_addr
	addi $t1, $t1, 6
	
	sb $a3, ($t1) #store char in map[row][col]
	li $v0, 0
	
	lw $ra ($sp)
	addi $sp, $sp, 4
	jr $ra


# Part V
reveal_area:
	addi $sp, $sp, -4
	sw $ra, ($sp)
		
	move $t8, $a1 #move row
	move $t9, $a2 #move col

	jal get_cell
	beq $v0, -1, reveal_area1
	
	andi $a3, $v0, 0x0000007F #set it to not hidden
	jal set_cell
	
reveal_area1:
	addi $a1, $t8, 1 #[row+1][col]
	move $a2, $t9
	jal get_cell
	beq $v0, -1, reveal_area2

	andi $a3, $v0, 0x0000007F #set it to not hidden
	jal set_cell

reveal_area2:
	addi $a1, $t8, -1 #[row-1][col]
	move $a2, $t9
	jal get_cell
	beq $v0, -1, reveal_area3
	
	andi $a3, $v0, 0x0000007F #set it to not hidden
	jal set_cell
reveal_area3:
	move $a1, $t8
	addi $a2, $t9, 1 #[row][col+1]
	jal get_cell
	beq $v0, -1, reveal_area4

	andi $a3, $v0, 0x0000007F #set it to not hidden
	jal set_cell
reveal_area4:
	move $a1, $t8
	addi $a2, $t9, 1 #[row][col-1]
	jal get_cell
	beq $v0, -1, reveal_area5
	
	andi $a3, $v0, 0x0000007F #set it to not hidden
	jal set_cell
reveal_area5:
	addi $a1, $t8, -1 
	addi $a2, $t9, -1 #[row-1][col-1]
	jal get_cell
	beq $v0, -1, reveal_area6
	
	andi $a3, $v0, 0x0000007F #set it to not hidden
	jal set_cell
reveal_area6:
	addi $a1, $t8, 1 
	addi $a2, $t9, 1 #[row+1][col+1] 
	jal get_cell
	beq $v0, -1, reveal_area7

	andi $a3, $v0, 0x0000007F #set it to not hidden
	jal set_cell
reveal_area7:
	addi $a1, $t8, 1 
	addi $a2, $t9, -1 #[row+1][col-1] 
	jal get_cell
	beq $v0, -1, reveal_area8

	andi $a3, $v0, 0x0000007F #set it to not hidden
	jal set_cell
reveal_area8:
	addi $a1, $t8, -1 
	addi $a2, $t9, 1 #[row-1][col+1] 
	jal get_cell
	beq $v0, -1, reveal_area9
	
	andi $a3, $v0, 0x0000007F #set it to not hidden
	jal set_cell
reveal_area9:


	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

# Part VI
get_attack_target:
	addi $sp, $sp, -4
	sw $ra, ($sp)

	addi $sp, $sp, -4
	sw $s0, ($sp)

	move $s0, $a1 #get player_ptr

	li $t0, 'U' #find which direction user wishes to go
	beq $a2, $t0, get_attackU
	li $t0, 'D'
	beq $a2, $t0, get_attackD
	li $t0, 'L'
	beq $a2, $t0, get_attackL
	li $t0, 'R'
	beq $a2, $t0, get_attackR

	li $v0, -1 #only goes here if user chooses none of the available directions
	jr $ra
	
get_attackU:
	lb $t0, ($s0) #get row-1
	addi $a1, $t0, -1 
	lb $a2, 1($s0) #get col
	j get_attack_ismonster
get_attackD:
	lb $t0, ($s0) #get row+1
	addi $a1, $t0, 1 
	lb $a2, 1($s0) #get col
	j get_attack_ismonster
get_attackL:
	lb $t0, 1($s0) #get col-1
	addi $a2, $t0, -1 
	lb $a1, ($s0) #get row
	j get_attack_ismonster
get_attackR:
	lb $t0, 1($s0) #get col-1
	addi $a2, $t0, 1 
	lb $a1, ($s0) #get row
	j get_attack_ismonster
get_attack_ismonster:
	jal get_cell
	
	li $t0, 'm' #seeing if player is attacking an actual monster
	beq $v0, $t0, get_attack_ismonsterout
	li $t0, 'B'
	beq $v0, $t0, get_attack_ismonsterout
	li $t0, '/'
	beq $v0, $t0, get_attack_ismonsterout
	
	li $v0, -1 #targeted cell is not 'm' , 'B' , nor '/'
	
	lw $s0, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
get_attack_ismonsterout:
	lw $s0, ($sp) #output in $v0 the targeted cell
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

# Part VII
monster_attacks:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s1, ($sp)
	addi $sp, $sp, -4
	sw $s2, ($sp)
	
	li $s2, 0
	
	lb $s0, ($a1) #load row of player_str
	lb $s1, 1($a1) #load col of player_str
	
	addi $a1, $s0, -1 #[row-1][col]
	move $a2, $s1 
	jal miniorbig
	
	addi $a1, $s0, 1 #[row+1][col]
	move $a2, $s1 
	jal miniorbig
	
	move $a1, $s0 #[row][col-1]
	addi $a2, $s1, -1
	jal miniorbig
	
	move $a1, $s0 #[row][col-1]
	addi $a2, $s1, 1
	jal miniorbig
	
	move $v0, $s2
	
	lw $s2, ($sp)
	addi $sp, $sp, 4
	lw $s1, ($sp)
	addi $sp, $sp, 4
	lw $s0, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra #return
	
miniorbig:
	jal get_cell
	li $t0, 'm'
	beq $t0, $v0, mini #is a minion
	li $t0, 'B'
	beq $t0, $v0, big #is a boss
	
	jr $ra #no points 
mini:
	addi $s2, $s2, 1 #add 1 point
	jr $ra
big:
	addi $s2, $s2, 2 #add 2 points
	jr $ra

# Part VIII
player_move:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $sp, $sp, -4
	sw $s3, ($sp)
	addi $sp, $sp, -4
	sw $s4, ($sp)
	addi $sp, $sp, -4
	sw $s5, ($sp) 
	
	move $s3, $a1
	move $s4, $a2
	move $s5, $a3
	lb $a1, ($s3) #load row of player
	lb $a2, 1($s3) #load col of player
	
	jal monster_attacks
	
	lb $t0 2($s3) #load player health
	sub $t0, $t0, $v0 #subtract by monster dmg
	blez $t0, player_has_died #if <= 0, player died and will not move
	
	lb $a1, ($s3) #load row of player
	lb $a2, 1($s3) #load col of player
	li $a3, '.' #replace player pos with .
	jal set_cell
	
	move $a1, $s4 #targeted row
	move $a2, $s5 #targeted col
	jal get_cell #find the targeted cell
	
	li $t0, '.'
	beq $v0, $t0, player_nocoins
	li $t0, '$'
	beq $v0, $t0, player_onecoin
	li $t0, '*'
	beq $v0, $t0, player_fivecoins
	li $t0, '>'
	beq $v0, $t0, player_error

player_nocoins:
	move $a1, $s4 #targeted row
	move $a2, $s5 #targeted col
	li $a3, '@'
	jal set_cell
	li $v0, 0
	j player_turn_end
player_onecoin:
	move $a1, $s4 #targeted row
	move $a2, $s5 #targeted col
	li $a3, '@'
	jal set_cell
	lb $t0, 3($s3) #load coins of player
	addi $t0, $t0, 1 #add one
	sb $t0, 3($s3) #store it back in
	li $v0, 0
	j player_turn_end
player_fivecoins:
	move $a1, $s4 #targeted row
	move $a2, $s5 #targeted col
	li $a3, '@'
	jal set_cell
	lb $t0, 3($s3) #load coins of player
	addi $t0, $t0, 5 #add five
	sb $t0, 3($s3) #store it back in
	li $v0, 0
	j player_turn_end
player_error:
	move $a1, $s4 #targeted row
	move $a2, $s5 #targeted col
	li $a3, '@'
	jal set_cell
	li $v0, -1 #will return -1
	j player_turn_end

player_has_died:
	lb $a1, ($s3) #load row of player
	lb $a2, 1($s3) #load col of player
	li $a3, 'X' 
	jal set_cell #will replace @ with an X
	li $v0, 0
player_turn_end:
	
	lw $s5, ($sp)
	addi $sp, $sp, 4
	lw $s4, ($sp)
	addi $sp, $sp, 4
	lw $s3, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# Part IX
complete_attack:
	addi $sp, $sp, -4 #preserve $s registers and $ra
	sw $ra, ($sp)
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s1, ($sp)
	addi $sp, $sp, -4
	sw $s2, ($sp)
	
	move $s0, $a1 #player_ptr
	move $s1, $a2 #row of targeted cell
	move $s2, $a3 #col of targeted cell
	
	move $a1, $s1 #a1 now has row of targeted cell
	move $a2, $s2 #col 
	jal get_cell

	li $t0, 'm' #find what the targeted cell is
	beq $v0, $t0, complete_attackm
	li $t0, 'B'
	beq $v0, $t0, complete_attackB
	li $t0, '/'
	beq $v0, $t0, complete_attackslash

complete_attackm:
	li $a3, '$' #replace targeted cell with appropiate char
	jal set_cell
	lb $t0, 2($s2) #obtain health
	addi $t0, $t0, -1 #subtract 1 from player_health
	sb $t0, 2($s2) #store health in player_ptr
	blez $t0, playerdied #if player has died, branch
	j complete_attack_end
complete_attackB:
	li $a3, '*'
	jal set_cell
	lb $t0, 2($s2)
	addi $t0, $t0, -2 #subtract 1 from player_health
	sb $t0, 2($s2) #store health in player_ptr
	blez $t0, playerdied #if player has died, branch
	j complete_attack_end
complete_attackslash:
	li $a3, '.'
	jal set_cell
	j complete_attack_end
playerdied:
	lb $a1, ($s2) #load row of player
	lb $a2, 1($s2) #load col of player
	li $a3, 'X' #will replace player's character
	jal set_cell
complete_attack_end:
	lw $s2, ($sp)
	addi $sp, $sp, 4
	lw $s1, ($sp)
	addi $sp, $sp, 4
	lw $s0, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra #return
	
	
	
# Part X
player_turn:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s1, ($sp)
	
	move $s0, $a1 #has player_ptr
	move $s1, $a2 #has direction
	
	li $t0, 'U' #check if direction is valid
	beq $t0, $a2, playerturnU
	li $t0, 'D'
	beq $t0, $a2, playerturnD
	li $t0, 'L'
	beq $t0, $a2, playerturnL
	li $t0, 'R'
	beq $t0, $a2, playerturnR

	li $v0, -1 #else error
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
playerturnU:
	lb $t0, ($s0) #load row of player
	addi $a1, $t0, -1 #row-1
	lb $a2, 1($s0)#load col of player
	
	jal is_valid_cell #check if valid index
	beq $v0, -1, player_turnend #not a valid index
	
	jal get_cell #obtain char at index
	li $t0, '#'
	beq $t0, $v0, player_turnend #is a wall so will not move there and will return 0
	
	move $a1, $s0 # $a0 has player_ptr
	move $a2, $s1 # $a1 has direction
	jal get_attack_target
	
	lb $t0, ($s0) #load row of player
	addi $a1, $t0, -1 #row-1
	lb $a2, 1($s0)#load col of player
	beq $v0, -1, player_turnmove #targeted index is not attackable, so player will just move
	jal complete_attack #target cell is attackable
	j player_turnend
playerturnD:
	lb $t0, ($s0) #load row of player
	addi $a1, $t0, 1 #row+1
	lb $a2, 1($s0)#load col of player
	
	jal is_valid_cell #check if valid index
	beq $v0, -1, player_turnend #not a valid index
	
	jal get_cell #obtain char at index
	li $t0, '#'
	beq $t0, $v0, player_turnend #is a wall so will not move there and will return 0
	
	move $a1, $s0 # $a0 has player_ptr
	move $a2, $s1 # $a1 has direction
	jal get_attack_target
	
	lb $t0, ($s0) #load row of player
	addi $a1, $t0, 1 #row+1
	lb $a2, 1($s0)#load col of player
	beq $v0, -1, player_turnmove #targeted index is not attackable, so player will just move
	jal complete_attack
	j player_turnend
playerturnL:
	lb $a1, ($s0) #load row of player
	lb $t0, 1($s0)
	addi $a2, $t0, -1 #col-1
	
	jal is_valid_cell #check if valid index
	beq $v0, -1, player_turnend #not a valid index
	
	jal get_cell #obtain char at index
	li $t0, '#'
	beq $t0, $v0, player_turnend #is a wall so will not move there and will return 0
	
	move $a1, $s0 # $a0 has player_ptr
	move $a2, $s1 # $a1 has direction
	jal get_attack_target
	
	lb $a1, ($s0) #load row of player
	lb $t0, 1($s0)
	addi $a2, $t0, -1 #col-1
	beq $v0, -1, player_turnmove #targeted index is not attackable, so player will just move
	jal complete_attack
	j player_turnend
playerturnR:
	lb $a1, ($s0) #load row of player
	lb $t0, 1($s0)
	addi $a2, $t0, 1 #col+1
	
	jal is_valid_cell #check if valid index
	beq $v0, -1, player_turnend #not a valid index
	
	jal get_cell #obtain char at index
	li $t0, '#'
	beq $t0, $v0, player_turnend #is a wall so will not move there and will return 0
	
	move $a1, $s0 # $a0 has player_ptr
	move $a2, $s1 # $a1 has direction
	jal get_attack_target
	
	
	lb $a1, ($s0) #load row of player
	lb $t0, 1($s0)
	addi $a2, $t0, 1 #col+1
	beq $v0, -1, player_turnmove #targeted index is not attackable, so player will just move
	jal complete_attack
	j player_turnend
player_turnmove:
	move $a3, $a2 #move targeted col into $a3
	move $a2, $a1 #move targeted row into $a2
	move $a1, $s0 #move player_ptr to $a1
	jal player_move
	
	lw $s1, ($sp)
	addi $sp, $sp, 4
	lw $s0, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
player_turnend:
	li $v0, 0
	lw $s1, ($sp)
	addi $sp, $sp, 4
	lw $s0, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

# Part XI
flood_fill_reveal:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal is_valid_cell #check if row,col is valid index
	beq $v0, -1, flood_fill_error
	
	addi $sp, $sp, -4 #preserve $fp
	sw $fp, ($sp)
	addi $sp, $sp, -4
	sw $s0, ($sp)
	addi $sp, $sp, -4
	sw $s1, ($sp)
	addi $sp, $sp, -4
	sw $s2, ($sp)
	
	move $s0, $a1
	move $s1, $a2
	move $s2, $a3 #save visited
	move $fp, $sp # $fp = $sp
	addi $sp, $sp, -4
	sw $a1, ($sp) # $sp.push(row)
	addi $sp, $sp, -4
	sw $a2, ($sp) # $sp.push(col)
	
flood_fill_loop:
	beq $sp, $fp, flood_fill_end #branch if $fp = $sp
	
	lw $a2, ($sp)
	addi $sp, $sp, 4 # $sp.pop() = col
	lw $a1, ($sp)
	addi $sp, $sp, 4 # $sp.pop() = row
	
	jal get_cell # $v0 will have cell at index (row,col)
	andi $a3, $v0, 0x0000007F #will make cell at index (row,col) visible
	jal set_cell

flood_fill_loop1:
	addi $a1, $s0, -1 # (-1,0)
	move $a2, $s1 
	jal get_cell
	andi $t1, $v0, 0x0000007F
	li $t0, '.' #empty floor space
	bne $t1, $t0, flood_fill_loop2 #if it is not an empty floor space, branch to next
	######## code to set cell to 1 in the visited array #############
	move $t0, $a3 # $t0 has visited
	mul $t1, $a1, $t5 # $t5 has num_cols
	add $t1, $t1, $a2 #  + j
	
	li $t2, 8
	div $t1, $t2 #divide by 8
	mflo $t1 # $t1 has quotient
	mfhi $t3 # has remainder
	mul $t3, $t3, $t2 #multiply by 8
	sub $t3, $t2, $t3 # set to 8- remainder
	addi $t3, $t3, -1 # subtract one because (0-7)
	
	add $t4, $t0, $t1 # traverse visited with quotient
	lb $t5, ($t4)
	srlv $t5, $t5, $t3 # shift right by quotient 
	beq $t5, 1, flood_fill_loop2 #the cell has already been visited, so check the next one
	
	li $t0, 1 # 0x00000001
	sllv $t0, $t0, $t3 # shift left by quotient
	lb $t5, ($t4) #load byte again
	or $t5, $t5, $t0 # this will set cell to visited, in the byte, while keeping the rest of them the same
	sb $t5, ($t4) #store it back in
	
	#################################################################
	
	move $t0, $a1
	move $t1, $a2
	
	addi $sp, $sp, -4
	sb $t0, ($sp) # $sp.push(row-1)
	addi $sp, $sp, -4
	sb $t1, ($sp) # $sp.push(col)
flood_fill_loop2:
	addi $a1, $s0, 1 # (1,0)
	move $a2, $s1 
	jal get_cell
	andi $t1, $v0, 0x0000007F #discard the hidden flag for comparison
	li $t0, '.' #empty floor space
	bne $t1, $t0, flood_fill_loop3 #if it is not an empty floor space, branch to next
	
	######## code to set cell to 1 in the visited array #############
	move $t0, $a3 # $t0 has visited
	mul $t1, $a1, $t5 # $t5 has num_cols
	add $t1, $t1, $a2 #  + j
	
	li $t2, 8
	div $t1, $t2 #divide by 8
	mflo $t1 # $t1 has quotient
	mfhi $t3 # has remainder
	mul $t3, $t3, $t2 #multiply by 8
	sub $t3, $t2, $t3 # set to 8- remainder
	addi $t3, $t3, -1 # subtract one because (0-7)
	
	add $t4, $t0, $t1 # traverse visited with quotient
	lb $t5, ($t4)
	srlv $t5, $t5, $t3 # shift right by quotient 
	beq $t5, 1, flood_fill_loop3 #the cell has already been visited, so check the next one
	
	li $t0, 1 # 0x00000001
	sllv $t0, $t0, $t3 # shift left by quotient
	lb $t5, ($t4) #load byte again
	or $t5, $t5, $t0 # this will set cell to visited, in the byte, while keeping the rest of them the same
	sb $t5, ($t4) #store it back in
	
	#################################################################
	move $t0, $a1
	move $t1, $a2
	
	addi $sp, $sp, -4
	sb $t0, ($sp) # $sp.push(row+1)
	addi $sp, $sp, -4
	sb $t1, ($sp) # $sp.push(col)
flood_fill_loop3:
	move $a1, $s0
	addi $a2, $s1, -1 #(0,-1) 
	jal get_cell
	andi $t1, $v0, 0x0000007F #discard the hidden flag for comparison
	li $t0, '.' #empty floor space
	bne $t1, $t0, flood_fill_loop4 #if it is not an empty floor space, branch to next
	
	######## code to set cell to 1 in the visited array #############
	move $t0, $a3 # $t0 has visited
	mul $t1, $a1, $t5 # $t5 has num_cols
	add $t1, $t1, $a2 #  + j
	
	li $t2, 8
	div $t1, $t2 #divide by 8
	mflo $t1 # $t1 has quotient
	mfhi $t3 # has remainder
	mul $t3, $t3, $t2 #multiply by 8
	sub $t3, $t2, $t3 # set to 8- remainder
	addi $t3, $t3, -1 # subtract one because (0-7)
	
	add $t4, $t0, $t1 # traverse visited with quotient
	lb $t5, ($t4)
	srlv $t5, $t5, $t3 # shift right by quotient 
	beq $t5, 1, flood_fill_loop4 #the cell has already been visited, so check the next one
	
	li $t0, 1 # 0x00000001
	sllv $t0, $t0, $t3 # shift left by quotient
	lb $t5, ($t4) #load byte again
	or $t5, $t5, $t0 # this will set cell to visited, in the byte, while keeping the rest of them the same
	sb $t5, ($t4) #store it back in
	
	#################################################################
	move $t0, $a1
	move $t1, $a2
	
	addi $sp, $sp, -4
	sb $t0, ($sp) # $sp.push(row)
	addi $sp, $sp, -4
	sb $t1, ($sp) # $sp.push(col-1)
flood_fill_loop4:
	move $a1, $s0
	addi $a2, $s1, 1 #(0,1) 
	jal get_cell
	andi $t1, $v0, 0x0000007F #discard the hidden flag for comparison
	li $t0, '.' #empty floor space
	bne $t1, $t0, flood_fill_loop #if it is not an empty floor space, branch back to start of loop
	
	######## code to set cell to 1 in the visited array #############
	move $t0, $a3 # $t0 has visited
	mul $t1, $a1, $t5 # $t5 has num_cols
	add $t1, $t1, $a2 #  + j
	
	li $t2, 8
	div $t1, $t2 #divide by 8
	mflo $t1 # $t1 has quotient
	mfhi $t3 # has remainder
	mul $t3, $t3, $t2 #multiply by 8
	sub $t3, $t2, $t3 # set to 8- remainder
	addi $t3, $t3, -1 # subtract one because (0-7)
	
	add $t4, $t0, $t1 # traverse visited with quotient
	lb $t5, ($t4)
	srlv $t5, $t5, $t3 # shift right by quotient 
	beq $t5, 1, flood_fill_loop #the cell has already been visited, so branch back to start of loop
	
	li $t0, 1 # 0x00000001
	sllv $t0, $t0, $t3 # shift left by quotient
	lb $t5, ($t4) #load byte again
	or $t5, $t5, $t0 # this will set cell to visited, in the byte, while keeping the rest of them the same
	sb $t5, ($t4) #store it back in
	
	#################################################################
	move $t0, $a1
	move $t1, $a2
	
	addi $sp, $sp, -4
	sb $t0, ($sp) # $sp.push(row)
	addi $sp, $sp, -4
	sb $t1, ($sp) # $sp.push(col-1)
	
	
flood_fill_end:
	lw $s2, ($sp)
	addi $sp, $sp, 4
	lw $s1, ($sp)
	addi $sp, $sp, 4
	lw $s0, ($sp)
	addi $sp, $sp, 4
	lw $fp ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
flood_fill_error: 
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
