################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Vennise Ho 1009972923
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
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
	lw $a0, ADDR_DSPL
	addi $a0, $a0, 128
	lw $a1, white
	jal draw_paused
	j exit
	
# GAME_OVER_SCREEN AND FUNCTIONALITY
# inputs: a0 (win (1) or lose (0))
# registers used: t0 (bitmap pointer), t3 (temp number), t4 (virus_number/game_speed), t5 (current_mode address), t6 (current_mode number), t8 (enter key ascii), t9 (keypress)
addi $a0, $zero, 1
game_over_screen:
beq $a0, 0, draw_game_over
beq $a0, 1, draw_you_win

draw_you_win:               # draw you win on the screen
    lw $t0, ADDR_DSPL
	addi $a0, $t0, 768
	lw $a1, white
	jal draw_you
	
	lw $t0, ADDR_DSPL         
    addi $a0, $t0, 1664
    lw $a1, white
    jal draw_win
	
	j check_retry

draw_game_over:             # draw game over on the screen
    lw $t0, ADDR_DSPL
	addi $a0, $t0, 768
	lw $a1, white
	jal draw_game

    lw $t0, ADDR_DSPL          
    addi $a0, $t0, 1664
    lw $a1, white
    jal draw_over
    
    j check_retry

check_retry:
    lw $t0, ADDR_DSPL          # draw retry on the screen
    addi $a0, $t0, 2816
    lw $a1, blue
    jal draw_retry
    
    check_retry_loop: 
    jal check_key_press
    add $t9, $v0, $zero
    lw $t8, enter
    bne $t9, $t8, check_retry_loop
    
    # we know that outside this loop, the user pressed r because q quits.
    
j exit

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

# START OF DRAW_G
# draws an G directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_G:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 4 units across ---
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 1 unit
	addi $t0, $t0, 116           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units with a space inbetween - --
	addi $t0, $t0, 128           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 116           # increment t0 by 116 (next row)
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
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_G

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

# START OF DRAW_I
# draws an I directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_I:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 1 unit in the middle - x5
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 128         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 128         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 128         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 128         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF DRAW_I

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

# START OF DRAW_N
# draws an N directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_N:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 3 units across ---
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer

	# 2 units with a space inbetween - -
	addi $t0, $t0, 120           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
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
	
	# 3 units across ---
	addi $t0, $t0, 120           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_N

# START OF DRAW_O
# draws an O directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_O:
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
# END DRAW_O


# START OF DRAW_P
# draws an A directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_P:
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
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 128           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_P

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

# START OF DRAW_T
# draws an T directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_T:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
    # 3 units across
    sw $t9, 0($t0)             # store the colour at the bitmap pointer
    addi $t0, $t0, 4         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	# 1 unit in the middle - x4
	addi $t0, $t0, 124         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 128         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 128         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 128         # increment t0 by 124 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
	lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF DRAW_I

# START OF DRAW_U
# draws an U directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_U:
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
# END DRAW_U

# START OF DRAW_V
# draws an W directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_V:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 2 units with a space inbetween - -
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 16             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 4 units with a space inbetween -- --
	addi $t0, $t0, 112             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 8 (space in between)
	
	# 2 units with a space inbetween - -
	addi $t0, $t0, 116             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 3 units ---
	addi $t0, $t0, 120             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 1 unit in the middle
	addi $t0, $t0, 124             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_V

# START OF DRAW_W
# draws an W directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_W:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 2 units with a space inbetween - -
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 16             # increment t0 by 8 (space in between)
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
	
	# 3 units with a space inbetween - - -
	addi $t0, $t0, 112           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 8             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 5 units across -----
	addi $t0, $t0, 112           # increment t0 by 120 (next row)
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	addi $t0, $t0, 4           # increment t0 by 4
	sw $t9, 0($t0)             # store the colour at the bitmap pointer
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_W

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

# START OF DRAW_QUESTION_MARK
# draws a Y directly on the bitmap
# inputs: a0 (bitmap address of top left point), a1 (colour)
draw_question_mark:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
	add $t9, $a1, $zero        # t9 = colour
	add $t0, $a0, $zero        # t0 = bitmap pointer
	
	# 3 units ---
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 8 (space in between)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# two spaces, 1 unit -
	addi $t0, $t0, 128           # increment t0 by start of next row (128 - 8)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# 2 units across ---
	addi $t0, $t0, 124           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	addi $t0, $t0, 4             # increment t0 by 4
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# unit in the middle
	addi $t0, $t0, 124           # increment t0 by 124 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
	# unit in the middle (dot of question mark)
	addi $t0, $t0, 256           # increment t0 by 120 (next row)
	sw $t9, 0($t0)               # store the colour at the bitmap pointer
	
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
    jr $ra
# END DRAW_QUESTION_MARK

# START OF DRAW_GAME
# draws the word game in the centre of the top row of the bitmap
# inputs: a0 (bitmap address of top row/y value), a1 (colour)
draw_game:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
    
    add $s0, $a0, 28            # s0 = add 32 to row/y value for centring
	add $s1, $a1, $zero         # s1 = colour
	
	add $a0, $s0, $zero
	add $a1, $s1, $zero
    jal draw_G
    
    add $a0, $s0, 20
	add $a1, $s1, $zero
    jal draw_A
    
    add $a0, $s0, 36
	add $a1, $s1, $zero
    jal draw_M
    
    add $a0, $s0, 60
	add $a1, $s1, $zero
    jal draw_E
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END DRAW_GAME

# START OF DRAW_OVER
# draws the word game in the centre of the top row of the bitmap
# inputs: a0 (bitmap address of top row/y value), a1 (colour)
draw_over:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
    
    add $s0, $a0, 28            # s0 = add 32 to row/y value for centring
	add $s1, $a1, $zero         # s1 = colour
	
	add $a0, $s0, $zero
	add $a1, $s1, $zero
    jal draw_O
    
    add $a0, $s0, 16
	add $a1, $s1, $zero
    jal draw_V
    
    add $a0, $s0, 40    
	add $a1, $s1, $zero
    jal draw_E
    
    add $a0, $s0, 56
	add $a1, $s1, $zero
    jal draw_R
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END DRAW_OVER

# START OF DRAW_RETRY
# draws the word retry in the centre of the top row of the bitmap
# inputs: a0 (bitmap address of top row/y value), a1 (colour)
draw_retry:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
    
    add $s0, $a0, 16            # s0 = add 32 to row/y value for centring
	add $s1, $a1, $zero         # s1 = colour
	
	add $a0, $s0, $zero
	add $a1, $s1, $zero
    jal draw_R
	
	add $a0, $s0, 20
	add $a1, $s1, $zero
    jal draw_E
    
    add $a0, $s0, 36
	add $a1, $s1, $zero
    jal draw_T
    
    add $a0, $s0, 52
	add $a1, $s1, $zero
    jal draw_R
    
    add $a0, $s0, 72
	add $a1, $s1, $zero
    jal draw_Y
    
    add $a0, $s0, 88
	add $a1, $s1, $zero
    jal draw_question_mark
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END DRAW_RETRY

# START OF DRAW_YOU
# draws the word you in the centre of the top row of the bitmap
# inputs: a0 (bitmap address of top row/y value), a1 (colour)
draw_you:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
    
    addi $s0, $a0, 44            # s0 = add 32 to row/y value for centring
	add $s1, $a1, $zero         # s1 = colour
    
    add $a0, $s0, $zero
	add $a1, $s1, $zero
    jal draw_Y
    
    addi $a0, $s0, 16
	add $a1, $s1, $zero
    jal draw_O
    
    addi $a0, $s0, 32
	add $a1, $s1, $zero
    jal draw_U
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END DRAW_YOU

# START OF DRAW_WIN
# draws the word win in the centre of the top row of the bitmap
# inputs: a0 (bitmap address of top row/y value), a1 (colour)
draw_win:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
    
    addi $s0, $a0, 44            # s0 = add 32 to row/y value for centring
	add $s1, $a1, $zero         # s1 = colour
    
    add $a0, $s0, $zero
	add $a1, $s1, $zero
    jal draw_W
    
    addi $a0, $s0, 24
	add $a1, $s1, $zero
    jal draw_I
    
    addi $a0, $s0, 32
	add $a1, $s1, $zero
    jal draw_N
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END DRAW_WIN

# START OF DRAW_PAUSED
# draws the word paused in the centre of the top row of the bitmap
# inputs: a0 (bitmap address of top row/y value), a1 (colour)
draw_paused:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack 
    
    add $s0, $a0, 16            # s0 = add 32 to row/y value for centring
	add $s1, $a1, $zero         # s1 = colour
	
	add $a0, $s0, $zero
	add $a1, $s1, $zero
    jal draw_P
	
	add $a0, $s0, 16
	add $a1, $s1, $zero
    jal draw_A
    
    add $a0, $s0, 32
	add $a1, $s1, $zero
    jal draw_U
    
    add $a0, $s0, 48
	add $a1, $s1, $zero
    jal draw_S
    
    add $a0, $s0, 64
	add $a1, $s1, $zero
    jal draw_E
    
    add $a0, $s0, 80
	add $a1, $s1, $zero
    jal draw_D
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END DRAW_PAUSED

# START OF RESET_GAME
# reset game function
reset_game:
subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
# reset capsuleID_count to zero
    la $t0, capsuleID_count     
    sw $zero, 0($t0)

# reset game_array to all black
    la $t0, game_array           # set the bitmap pointer (t0) to the top left corner
    lw $t9, black               # set the colour (t9) to black
    add $t1, $zero, $zero       # initialise the loop counter
        
    clear_game_array_loop:
        addi $t1, $t1, 1
        sw $t9, 0($t0)
        addi $t0, $t0, 4
    blt $t1, 128, clear_game_array_loop

# reset capsuleID_array to all 0s
la $t0, capsuleID_array           # set the bitmap pointer (t0) to the top left corner
add $t9, $zero, $zero             # set the colour (t9) to black
add $t1, $zero, $zero             # initialise the loop counter

clear_capsuleID_array_loop:
    addi $t1, $t1, 1
    sw $t9, 0($t0)
    addi $t0, $t0, 4
blt $t1, 128, clear_capsuleID_array_loop

lw $ra, 0($sp)           # Load the saved value of $ra from the stack
addi $sp, $sp, 4         # Increase the stack pointer (free up space)	
jr $ra
# END OF RESET_GAME

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
    beq $t7, 0x71, respond_to_q     # q was pressed
    lw $t6, enter
    beq $t7, $t6, valid_key        # enter was pressed
    
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