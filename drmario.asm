################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
#+
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
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

red:            .word 0xff0000
yellow:         .word 0xffff00
blue:           .word 0x00ffff
white:          .word 0xffffff
##############################################################################
# Mutable Data
##############################################################################
game_array:     .word 0:128
##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    jal draw_bottle
    jal generate_pill

game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop


##############################################################################
# FUNCTIONS
##############################################################################

# FUNCTION THAT DRAWS THE BOTTLE
# registers used: t0 (bitmap pointer), t1 (counter for x/y), t2 (bound for counter - t1), t9 (the colour white)
draw_bottle:
    lw $t0, ADDR_DSPL           # load displayAddress into $t0 (= bitmap pointer)
    addi $t0, $t0, 1716              # shift the bitmap pointer ($t0) to the start of the bottle (top left unit) (13, 13) --> 13*4*32 + 13*4
    
    lw $t9, white               # $t9 = the colour white
    
    # START OF BOTTLE TOP AND NECK
    sw $t9, 0($t0)              # row 1
    addi $t0, $t0, 20
    sw $t9, 0($t0) 
    
    addi $t0, $t0, 108          # shift to row 2
    
    sw $t9, 0($t0)              # row 2
    addi $t0, $t0, 4
    sw $t9, 0($t0) 
    addi $t0, $t0, 12
    sw $t9, 0($t0)
    addi $t0, $t0, 4
    sw $t9, 0($t0)
    
    addi $t0, $t0, 112          # shift to row 3 (bottleneck)
    
    sw$t9, 0($t0)               # row 3
    addi $t0, $t0, 12
    sw $t9, 0($t0)
    # END OF BOTTLE TOP AND NECK
    
    addi $t0, $t0, 104          # shift to row 4 (top of bottle body)
    
    # TOP OF BOTTLE BODY #
    sw $t9, 0($t0)      
    addi $t0, $t0, 4
    sw $t9, 0($t0)      
    addi $t0, $t0, 4
    sw $t9, 0($t0)      
    addi $t0, $t0, 4
    sw $t9, 0($t0)      
    
    addi $t0, $t0, 12
    
    sw $t9, 0($t0)      
    addi $t0, $t0, 4
    sw $t9, 0($t0)      
    addi $t0, $t0, 4
    sw $t9, 0($t0)      
    addi $t0, $t0, 4
    sw $t9, 0($t0) 
    # END OF BOTTLE BODY #
    
    add $t1, $zero, $zero       # initialize $t1 = counter for y
    addi $t2, $zero, 14         # $t2 = height of the sides (excluding top and bottom)    
    
    # START OF BOTTLE SIDES #
    bottle_body_side:
    addi $t0, $t0, 92               # shift to next row of the bottle body
    sw $t9, 0($t0)                  # left side
    addi $t0, $t0, 36
    sw $t9, 0($t0)                  # right side
    addi, $t1, $t1, 1
    bne $t1, $t2, bottle_body_side  # loop 14 times
    
    add $t1, $zero, $zero       # reassign $t1 = counter for x
    addi $t2, $zero, 10         # $t2 = width of bottom
    addi $t0, $t0, 92           # shift to last row
    # END OF BOTTLE SIDES #
    
    # START OF BOTTOM OF BOTTLE # 
    bottle_bottom:
    sw $t9, 0($t0)                  
    addi, $t0, $t0, 4
    addi, $t1, $t1, 1
    bne $t1, $t2, bottle_bottom
    # END OF BOTTOM OF BOTTLE # 
    # jr $ra 
# END DRAW_BOTTLE

# FUNCTION THAT GENERATES A RANDOM BI-COLOURED PILL AND DRAWS IT AT THE TOP OF THE BOTTLE
# registers: t0 (bitmap pointer), t5 (game_array address), v0 (return val from generate_colour)
generate_pill: 
    lw $t0, ADDR_DSPL      # load displayAddress into $t0 (= bitmap pointer)
    addi $t0, $t0, 2236         # point bitmap pointer to top of bottle
    
    la $t5, game_array          # t5 = address of game_array
    
    jal generate_colour         # generate the left half of the pill and init at top of bottle
    sw $v0, 0($t0)              
    sw $v0, 12($t5)             # add colour of left half of pill to game_array[3] 
    
    jal generate_colour         # generate the right half of the pill and init at top of bottle
    sw $v0, 4($t0)
    sw $v0, 16($t5)             # add colour of right half of pill to game_array[4]
    
jr $ra
# END GENERATE_PILL

# FUNCTION THAT GENERATES A RANDOM COLOUR (red, yellow, blue)
# registers: v0 (syscall + func return val), a0 (syscall arg + syscall return), a1 (syscall arg), t9 (temp_colour)
generate_colour:
    # Generate random number between 0 and 2 
    li $v0, 42             # Syscall for random number (min = a0, max = a1)
    li $a0, 0
    li $a1, 3
    syscall                
    
    beq $a0, 0, choose_red         # If random number is 0, use red
    beq $a0, 1, choose_yellow      # If random number is 1, use yellow
    beq $a0, 2, choose_blue        # If random number is 2, use blue
    
    choose_red:
    lw $t9, red            # load $t0 = red_address
    j exit_generate_colour
    
    choose_yellow:
    lw $t9, yellow         # load $t0 = yellow_address
    j exit_generate_colour
    
    choose_blue:
    lw $t9, blue           # load $t0 = blue_address
    j exit_generate_colour
    
    exit_generate_colour:
    add $v0, $t9, $zero
    jr $ra
# END GENERATE_COLOUR

exit: