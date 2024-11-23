############################### Mode Screen ##################################
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

red:        .word 0xff0000
yellow:     .word 0xffff00
blue:       .word 0x00ffff
white:      .word 0xffffff
black:      .word 0x000000

a:          .word 0x61
d:          .word 0x64
w:          .word 0x77
s:          .word 0x73
q:          .word 0x71
n:          .word 0x6e
enter:      .word 0xa

init_x1:     .word 3
init_y1:     .word 0
init_x2:     .word 4
init_y2:     .word 0

game_board_offset:     .word 1968
##############################################################################
# Mutable Data
##############################################################################
game_array:             .word 0:128         # array containing the game
capsuleID_array:        .word 0:128         # array containing the capsuleIDs

curr_x1:                .word 0             # current x of half 1
curr_y1:                .word 0             # current y of half 1
curr_x2:                .word 0             # current x of half 2
curr_y2:                .word 0             # current y of half 2

new_x1:                 .word 0             # current x of half 1
new_y1:                 .word 0             # current y of half 1
new_x2:                 .word 0             # current x of half 2
new_y2:                 .word 0             # current y of half 2

colour_1:               .word 0             # current colour of half 1
colour_2:               .word 0             # current colour of half 2

capsuleID_count:        .word 0             # increases each time a capsule is added to the board
capsuleID_max:          .word 0             # only used in drop to save the current capsuleID_count

current_mode:           .word 0             # used to set the mode to easy, medium, or hard
current_screen:         .word 0             # 0 = mode_screen, 1 = game_screen, 2 = game_over_screen

virus_number:           .word 0
game_speed:             .word 0 

##############################################################################
# Code
##############################################################################
.macro store_registers() 
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t9, 0($sp)              # Store the value of $t9 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t8, 0($sp)              # Store the value of $t8 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t7, 0($sp)              # Store the value of $t7 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t6, 0($sp)              # Store the value of $t6 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t5, 0($sp)              # Store the value of $t5 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t4, 0($sp)              # Store the value of $t4 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t3, 0($sp)              # Store the value of $t3 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t2, 0($sp)              # Store the value of $t2 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t1, 0($sp)              # Store the value of $t1 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t0, 0($sp)              # Store the value of $t0 at the top of the stack
.end_macro

.macro load_registers() 
    lw $t0, 0($sp)           # Load the saved value of $t0 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t1, 0($sp)           # Load the saved value of $t1 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t2, 0($sp)           # Load the saved value of $t2 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t3, 0($sp)           # Load the saved value of $t3 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t4, 0($sp)           # Load the saved value of $t4 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t5, 0($sp)           # Load the saved value of $t5 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t6, 0($sp)           # Load the saved value of $t6 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t7, 0($sp)           # Load the saved value of $t7 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t8, 0($sp)           # Load the saved value of $t8 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t9, 0($sp)           # Load the saved value of $t9 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
.end_macro	
	
	.text

jal mode_screen
j exit

# MODE_SCREEN AND FUNCTIONALITY
# registers used: t0 (bitmap pointer), t3 (temp number), t4 (virus_number/game_speed), t5 (current_mode address), t6 (current_mode number), t8 (enter key ascii), t9 (keypress)
mode_screen:
subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
# initialise game mode to easy

# init easy
# set number of viruses to 4
    la $t4, virus_number
    addi $t3, $zero, 4
    sw $t3, 0($t4)

#################### SET GAME SPEED ######################
# set game speed to
    la $t4, game_speed
    # addi $t3, $zero, 4
    # sw $t3, 0($t4)
    
# change colour to blue
    lw $t0, ADDR_DSPL
	addi $a0, $t0, 896
	lw $a1, blue
	jal draw_easy

# init med
    lw $t0, ADDR_DSPL          # initialise medium as white
    addi $a0, $t0, 1792
    lw $a1, white
    jal draw_med

# init hard
    lw $t0, ADDR_DSPL          # initialise hard as white
    addi $a0, $t0, 2688
    lw $a1, white
    jal draw_hard

    # by the end of this loop, virus_number and game_speed will be updated according to the game mode	
	mode_screen_loop:
	    la $t5, current_mode           # load the current_mode address into t5
	    lw $t6, current_mode           # load the current_mode number into t6
        
        jal check_key_press
        add $t9, $v0, $zero
        
        beq $t9, 0x73, mode_down                 # s was pressed
        lw $t8, enter
        beq $t9, $t8, exit_mode_screen_loop     # enter was pressed
        j exit_mode_screen_loop
        
        mode_down:
        addi $t6, $t6, 1                    # increase current_mode number by 1
        j change_current_mode
        
        change_current_mode:
        # initialise all the words as white
        lw $t0, ADDR_DSPL           # initialise easy as white
    	addi $a0, $t0, 896
    	lw $a1, white
    	jal draw_easy
    	
    	lw $t0, ADDR_DSPL          # initialise medium as white
    	addi $a0, $t0, 1792
    	lw $a1, white
    	jal draw_med
    	
    	lw $t0, ADDR_DSPL          # initialise hard as white
    	addi $a0, $t0, 2688
    	lw $a1, white
    	jal draw_hard
        
        # change the game mode according to the key_press
        addi $t1, $zero, 3                  # divisor is 3
        div $t6, $t1                        # Divide current_mode number by 3 to get the mod
        mfhi $t6                            # $t6 now holds the current mode number (mod 3)
        sw $t6, 0($t5)                      # store the current mode number into current_mode
        
        beq $t6, 0, game_mode_easy          # set the current game mode to easy
        beq $t6, 1, game_mode_med           # set the current game mode to medium  
        beq $t6, 2, game_mode_hard          # set the current game mode to hard 
        
        game_mode_easy:
        # set number of viruses to 4
            la $t4, virus_number
            addi $t3, $zero, 4
            sw $t3, 0($t4)
        
        #################### SET GAME SPEED ######################
        # set game speed to
            la $t4, game_speed
            # addi $t3, $zero, 4
            # sw $t3, 0($t4)
            
        # change colour to blue
            lw $t0, ADDR_DSPL
        	addi $a0, $t0, 896
        	lw $a1, blue
        	jal draw_easy
    	j exit_mode_screen_loop
        
        game_mode_med:
        # set number of viruses to 8
            la $t4, virus_number
            addi $t3, $zero, 8
            sw $t3, 0($t4)
        
        #################### SET GAME SPEED ######################
        # set game speed to
            la $t4, game_speed
            # addi $t3, $zero, 4
            # sw $t3, 0($t4)
            
        # change colour to blue
            lw $t0, ADDR_DSPL
        	addi $a0, $t0, 1792
        	lw $a1, blue
        	jal draw_med
    	j exit_mode_screen_loop
        
        game_mode_hard:
        # set number of viruses to 12
            la $t4, virus_number
            addi $t3, $zero, 12
            sw $t3, 0($t4)
        
        #################### SET GAME SPEED ######################
        # set game speed to
            la $t4, game_speed
            # addi $t3, $zero, 4
            # sw $t3, 0($t4)
            
        # change colour to blue
            lw $t0, ADDR_DSPL
        	addi $a0, $t0, 2688
        	lw $a1, blue
        	jal draw_hard
    	j exit_mode_screen_loop
    	
    	exit_mode_screen_loop:
    	lw $t8, enter
        bne $t9, $t8, mode_screen_loop
        
	lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF MODE_SCREEN




# START OF DRAW_EASY
# draws the word easy in the centre of the top row of the bitmap
# inputs: a0 (bitmap address of top row/y value), a1 (colour)
draw_easy:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
    
    add $s0, $a0, 32            # s0 = add 32 to row/y value for centring
	add $s1, $a1, $zero         # s1 = colour
	
	add $a0, $s0, $zero
	add $a1, $s1, $zero
    jal draw_E
    
    add $a0, $s0, 16
	add $a1, $s1, $zero
    jal draw_A
    
    add $a0, $s0, 32
	add $a1, $s1, $zero
    jal draw_S
    
    add $a0, $s0, 48
	add $a1, $s1, $zero
    jal draw_Y
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END DRAW_EASY

# START OF DRAW_MED
# draws the word MED in the centre of the top row of the bitmap
# inputs: a0 (bitmap address of top row/y value), a1 (colour)
draw_med:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
    
    add $s0, $a0, 36            # s0 = add 32 to row/y value for centring
	add $s1, $a1, $zero         # s1 = colour
	
	add $a0, $s0, $zero           # draw M
	add $a1, $s1, $zero
    jal draw_M
	
	addi $a0, $s0, 24           # draw E
	add $a1, $s1, $zero
    jal draw_E
    
    add $a0, $s0, 40            # draw d
	add $a1, $s1, $zero
    jal draw_D
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END DRAW_MED

# START OF DRAW_HARD
# draws the word HARD in the centre of the top row of the bitmap
# inputs: a0 (bitmap address of top row/y value), a1 (colour)
draw_hard:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
    
    add $s0, $a0, 32            # s0 = add 32 to row/y value for centring
	add $s1, $a1, $zero         # s1 = colour
	
	add $a0, $s0, $zero
	add $a1, $s1, $zero
    jal draw_H
    
    add $a0, $s0, 16
	add $a1, $s1, $zero
    jal draw_A
    
    add $a0, $s0, 32
	add $a1, $s1, $zero
    jal draw_R
    
    add $a0, $s0, 52
	add $a1, $s1, $zero
    jal draw_D
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END DRAW_HARD

# START OF DRAW_A
# draws an A directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_A:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 3 units across ---
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 120           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_A

# START OF DRAW_D
# draws an D directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_D:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 3 units across ---
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 2 units with two spaces inbetween - -
	addi $t0, $t0, 120           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 12             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with two spaces inbetween - -
	addi $t0, $t0, 116           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 12             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with two spaces inbetween -  -
	addi $t0, $t0, 116           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 12             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 116           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer

    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_D

# START OF DRAW_E
# draws an E directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_E:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 3 units across ---
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 1 unit and two spaces -  
	addi $t0, $t0, 120         # increment t0 by 120 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 128         # increment t0 by 120 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer

	# 1 unit and two spaces -  
	addi $t0, $t0, 120         # increment t0 by 120 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 128         # increment t0 by 120 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer

    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF DRAW_E

# START OF DRAW_H
# draws an H directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_H:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 2 units with a space inbetween - -
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 120           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_H

# START OF DRAW_M
# draws an M directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_M:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 5 units across -----
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 3 units with a space inbetween - - -
	addi $t0, $t0, 112           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units with a space inbetween - - -
	addi $t0, $t0, 112           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units with a space inbetween - - -
	addi $t0, $t0, 112           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 112           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 16             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_M

# START OF DRAW_R
# draws an R directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_R:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 3 units across ---
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 116           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 12             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 116           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 116           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 12             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_R

# START OF DRAW_S
# draws an S directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_S:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 3 units across ---
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 1 unit and two spaces -  
	addi $t0, $t0, 120         # increment t0 by 120 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 128         # increment t0 by 120 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer

	# two spaces and 1 unit   -  
	addi $t0, $t0, 128         # increment t0 by 120 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 120         # increment t0 by 120 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer

    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF DRAW_S

# START OF DRAW_Y
# draws a Y directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_Y:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 2 units with a space inbetween - -
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 120           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 spaces and a unit  -
	addi $t0, $t0, 128           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units across ---
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_Y

# START CHECK_KEY_PRESS
# function that checks if a key was pressed
#       if a key was pressed and it is valid (w, a, s, d, q), return it's corresponding letter.
#       if a key was not pressed or if it is not a valid letter, return n (for null)
# returns: v0 (the ASCII code for a letter - w, a, s, d, q, n)
# registers: t7 (ASCII key value of key pressed), t8 (value at keyboard_address --> 0 or 1), t9 (keyboard_address)
check_key_press:
    lw $t9, ADDR_KBRD               # $t9 = base keyboard address
    lw $t8, 0($t9)                  # $t8 = value at keyboard address
    beq $t8, 1, keyboard_input      # if $t8 == 1: key was pressed (ASCII key value found in next value in memory)
    
    lw $v0, n                       # otherwise, no key was pressed so set return value (v0) = n 
    j exit_check_key_press          # --> jump to exit
    
    # if a key was pressed get its ASCII value
    keyboard_input:
    lw $t7, 4($t9)                  # $t7 = ASCII key value 
    
    beq $t7, 0x61, valid_key        # a was pressed
    beq $t7, 0x64, valid_key        # d was pressed
    beq $t7, 0x77, valid_key        # w was pressed
    beq $t7, 0x73, valid_key        # s was pressed
    beq $t7, 0x0a, valid_key        # enter was pressed
    beq $t7, 0x71, respond_to_q     # q was pressed
    
    lw $v0, n                       # otherwise, the key pressed was invalid so set return value (v0) = n   
    j exit_check_key_press          # --> jump to exit

        valid_key:
        add $v0, $t7, $zero             # return the ASCII key value of the valid key
        j exit_check_key_press          # --> jump to exit
        
        respond_to_q:
    	li $v0, 10                      # quit gracefully
    	syscall
	
	exit_check_key_press:
	jr $ra                           # exit the function
# END OF CHECK_KEY_PRESS

exit:
	
	