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

init_x1:     .word 3
init_y1:     .word 0
init_x2:     .word 4
init_y2:     .word 0

game_board_offset:     .word 1968
##############################################################################
# Mutable Data
##############################################################################
game_array:             .word 0:128

curr_x1:                .word 0             # current x of half 1
curr_y1:                .word 0             # current y of half 1
new_x1:                .word 0             # current x of half 1
new_y1:                .word 0             # current y of half 1
colour_1:               .word 0             # current colour of half 1

curr_x2:                .word 0             # current x of half 2
curr_y2:                .word 0             # current y of half 2
new_x2:                .word 0             # current x of half 2
new_y2:                .word 0             # current y of half 2
colour_2:               .word 0             # current colour of half 2

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    jal draw_bottle                 # draw the bottle
    
    addi $a0, $zero, 4              # number of viruses 
    jal generate_virus              # add viruses to game_array
    
    jal update_display
    jal generate_pill               # initialise pill in data (curr_x, curr_y, new_x, new_y)
    jal update_capsule_location     # initialise location of pill
    jal update_display              # draw the display

game_loop:
    # 1A. CHECK IF KEY HAS BEEN PRESSED & 1B. CHECK WHICH KEY HAS BEEN PRESSED
    jal check_key_press
    
    add $s0, $v0, $zero             # s0 = keypress (constant for the loop)
    add $a0, $s0, $zero             # output key from check_key_press is the input to calculate_next_xy
    jal calculate_new_xy            # after this call, new_x and new_y will contain new positions
    
    # 2A. CHECK FOR COLLISIONS
    # remove the current values from the game_array
    lw $t6, black               # load the colour black
    # remove value of game_array[curr_x1, curr_y1] 
    lw $t7, curr_x1              # t1 = curr_x1
    lw $t8, curr_y1              # t2 = curr_y1
    add $a0, $t7, $zero          # arg x for xy_to_array
    add $a1, $t8, $zero          # arg y for xy_to_array
    jal xy_to_array
    add $t0, $t5, $v0           # points to game_array[curr_x1, curr_y1]
    sw $t6, 0($t0)              # put the colour black into game_array[curr_x1, curr_y1]
    
    # remove value of game_array[curr_x2, curr_y2]
    lw $t7, curr_x2              # t1 = curr_x2
    lw $t8, curr_y2              # t2 = curr_y2
    add $a0, $t7, $zero          # arg x for xy_to_array
    add $a1, $t8, $zero          # arg y for xy_to_array
    jal xy_to_array
    add $t0, $t5, $v0           # points to game_array[curr_x2, curr_y2]
    sw $t6, 0($t0)              # put the colour black into game_array[curr_x2, curr_y2]
    
    beq $s0, 0x61, check_side_collision                         # the given key is a
    beq $a0, 0x64, check_side_collision                         # the given key is d
    beq $a0, 0x77, check_side_collision                         # the given key is w
    beq $a0, 0x73, check_down_collision                         # the given key is s
    
    check_side_collision:
        jal check_wall_collision            # checks if the pill hit the side or top walls
        beq $v0, 1, location                # returns 1 if collision
        
        # otherwise, the pill did not hit a wall
        jal check_object_collision          # checks if the pill hit an object
        beq $v0, 1, location                # returns 1 if collision
        
        # otherwise, we can move the pill to the new position
        # update curr_x, curr_y = new_x, new_y
        la $t1, curr_x1         # t1 = curr_x1 address
        lw $t2, new_x1          # t2 = new_x1
        sw $t2, 0($t1)          # store new_x1 at curr_x1 address
        
        la $t1, curr_y1         # t1 = curr_y1 address
        lw $t2, new_y1          # t2 = new_y1
        sw $t2, 0($t1)          # store new_y1 at curr_y1 address
        
        la $t1, curr_x2         # t1 = curr_x2 address
        lw $t2, new_x2          # t2 = new_x2
        sw $t2, 0($t1)          # store new_x2 at curr_x2 address
        
        la $t1, curr_y2         # t1 = curr_y2 address
        lw $t2, new_y2          # t2 = new_y2
        sw $t2, 0($t1)          # store new_y2 at curr_y2 address
    
    j location
    
    check_down_collision:
    jal check_bottom_collision          # checks if the pill hit the bottom of the walls
    beq $v0, 1, location                # returns 1 if collision
    
    # otherwise, the pill did not hit a wall
    jal check_object_collision          # checks if the pill hit an object
    beq $v0, 1, location                # returns 1 if collision
    
    # otherwise, we can move the pill to the new position
    # update curr_x, curr_y = new_x, new_y
    la $t1, curr_x1         # t1 = curr_x1 address
    lw $t2, new_x1          # t2 = new_x1
    sw $t2, 0($t1)          # store new_x1 at curr_x1 address
    
    la $t1, curr_y1         # t1 = curr_y1 address
    lw $t2, new_y1          # t2 = new_y1
    sw $t2, 0($t1)          # store new_y1 at curr_y1 address
    
    la $t1, curr_x2         # t1 = curr_x2 address
    lw $t2, new_x2          # t2 = new_x2
    sw $t2, 0($t1)          # store new_x2 at curr_x2 address
    
    la $t1, curr_y2         # t1 = curr_y2 address
    lw $t2, new_y2          # t2 = new_y2
    sw $t2, 0($t1)          # store new_y2 at curr_y2 address

    j location
        
	# 2B. UPDATE LOCATION (CAPSULES)
	location:
	jal update_capsule_location             # after this call, the game_array locations should be updated
	
	# 3. Draw the screen
	jal update_display
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop


##############################################################################
# FUNCTIONS
##############################################################################

# FUNCTION THAT DRAWS THE BOTTLE
# registers used: t0 (bitmap pointer), t1 (counter for x/y), t9 (the colour white)
draw_bottle:
    lw $t0, ADDR_DSPL                # load displayAddress into $t0 (= bitmap pointer)
    addi $t0, $t0, 1460              # shift the bitmap pointer ($t0) to the start of the bottle (top left unit) 
    
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
    
    # START OF BOTTLE SIDES #
    bottle_body_side:
    addi $t0, $t0, 92               # shift to next row of the bottle body
    sw $t9, 0($t0)                  # left side
    addi $t0, $t0, 36
    sw $t9, 0($t0)                  # right side
    addi, $t1, $t1, 1
    bne $t1, 16, bottle_body_side  # loop 16 times
    # END OF BOTTLE SIDES #
    
    add $t1, $zero, $zero       # reassign $t1 = counter for x
    addi $t0, $t0, 92           # shift to last row
    
    # START OF BOTTOM OF BOTTLE # 
    bottle_bottom:
    sw $t9, 0($t0)                  
    addi, $t0, $t0, 4
    addi, $t1, $t1, 1
    bne $t1, 10, bottle_bottom
    # END OF BOTTOM OF BOTTLE # 
    jr $ra 
# END DRAW_BOTTLE

# START GENERATE_VIRUS
# function that generates a random coloured virus at a random location in the bottom half of the bottle and stores the virus in the game_array
# inputs: a0 (number of viruses to generate)
# registers: t0 (game_array pointer), t1 (generated x value), t2 (generated y value), t3 (generated colour), t5 (game_array pointer), t6 (value at game_array pointer), t7 (loop bound), t8 (virus counter)
generate_virus: 
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    add $t7, $a0, $zero         # init loop bound to a0
    add $t8, $zero, $zero       # init loop counter to 0
    
    generate_virus_loop:
        la $t5, game_array          # load the base address of the game_array
        
        jal generate_colour         # generate the colour of the virus
        add $t3, $v0, $zero         # store generated colour in t3
        
        # Generate x value (random number between 0 and 8 (exc.)) 
        li $v0, 42                  # Syscall for random number (min = a0, max = a1)
        li $a0, 0
        li $a1, 8
        syscall
        add $t1, $a0, $zero         # t1 = generated x value
        
        # Generate y value (random number between 8 and 16 (exc.))
        li $v0, 42             # Syscall for random number (min = a0, max = a1)
        li $a0, 0
        li $a1, 8
        syscall
        addi $t2, $a0, 8        # t2 = generated y value (+8 because the value generated is from 0-7, not 8-15)
        
        # Get array offset
        add $a0, $t1, $zero         # a0 = x arg for xy_to_array
        add $a1, $t2, $zero         # a1 = y arg for xy_to_array
        jal xy_to_array
        
        # If the given address is empty, set the virus
        # If the given address already contains a virus, loop again without setting.
        add $t5, $t5, $v0                   # add offset to base game_array address
        lw $t6, 0($t5)                      # load the value at the offset game_array address at t6
        beq $t6, $zero, set_virus           # if the value is equal to 0 (is empty), set the virus
        j next_generate_virus_loop          # otherwise, start the loop again
        
        set_virus:
            sw $t3, 0($t5)              # store the colour of the virus at this offset
            addi $t8, $t8, 1            # increase the virus counter by 1
            j next_generate_virus_loop
        
        next_generate_virus_loop:
        blt $t8, $t7, generate_virus_loop       # exit when t8 (virus counter) = t7 = a0 = loop bound       
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)

    jr $ra
# END GENERATE_VIRUS

# FUNCTION THAT GENERATES A RANDOM BI-COLOURED PILL AND DRAWS IT AT THE TOP OF THE BOTTLE
# registers: t0 (game_array pointer), t1 (initial position of left half), t5 (game_array address), v0 (return val from generate_colour)
generate_pill: 
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
        
    la $t7, colour_1            # t7 = address of colour_1
    jal generate_colour         # generate the left half of the pill and init at top of bottle
    sw $v0, 0($t7)              # store generated colour in colour_1
    
    la $t9, curr_x1             # t9 = address of x1
    la $t8, curr_y1             # t8 = address of y1
    la $t6, new_x1              # t6 = address of new_x1
    la $t5, new_y1              # t5 = address of new_y1
    lw $t1, init_x1             # load initial x1 value into t1
    lw $t2, init_y1             # load initial y1 value into t2
    sw $t1, 0($t9)              # store intial x1 value in curr_x1
    sw $t2, 0($t8)              # store intial y1 value in curr_y1
    sw $t1, 0($t6)              # store intial x1 value in new_x1
    sw $t2, 0($t5)              # store intial y1 value in new_y1
    
    la $t7, colour_2            # t7 = address of colour_1
    jal generate_colour         # generate the right half of the pill and init at top of bottle
    sw $v0, 0($t7)              # store generated colour in colour_1
    
    la $t9, curr_x2             # t9 = address of x2
    la $t8, curr_y2             # t8 = address of y2
    la $t6, new_x2              # t6 = address of new_x2
    la $t5, new_y2              # t5 = address of new_y2
    lw $t1, init_x2             # load initial x2 value into t1
    lw $t2, init_y2             # load initial y2 value into t2
    sw $t1, 0($t9)              # store intial x2 value in curr_x2
    sw $t2, 0($t8)              # store intial y2 value in curr_y2
    sw $t1, 0($t6)              # store intial x2 value in new_x2
    sw $t2, 0($t5)              # store intial y2 value in new_y2
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
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

# START UPDATE_DISPLAY
# function that updates the display based on the game_array
# registers: t0 (bitmap pointer), t5 (array pointer), t7 (value at game_array[offset/4]), t8 (offset counter), t9 (loop counter)
update_display:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    la $t5, game_array              # load array address into t5
    add $t9, $zero, $zero           # init loop counter = 0
    add $t8, $zero, $zero           # init offset counter = 0
    
    # loops through each address in the array 
    update_display_loop:
        lw $t7, 0($t5)            # load val at game_array[offset/4] into t7 (a colour)
        
        # display_pixel:
        add $a0, $t8, $zero             # array offset arg for array_to_xy
        jal array_to_xy
    
        add $a0, $v0, $zero             # x arg for xy_to_bitmap
        add $a1, $v1, $zero             # y arg for xy_to_bitmap
        jal xy_to_bitmap
        
        lw $t0, ADDR_DSPL               # load the base bitmap address into t0
        add $t0, $t0, $v0
        sw $t7, 0($t0)                  # write value (t7, a colour) to bitmap with offset (v0)
        
        increment_display_loop_vars:
        addi $t9, $t9, 1                        # increase loop counter by 1
        addi $t8, $t8, 4                        # increase offset counter by 4
        addi $t5, $t5, 4                        # increase array pointer by 4
        blt $t9, 128, update_display_loop       # loop 128 times
        
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF UPDATE_DISPLAY
  
# START OF ARRAY_TO_XY
# translates address offset to row/column value
# inputs: a0 (offset)
# returns: v0 (x value - 0:127), v1 (y value - 0:127) 
# registers: t1 (temp divisors), t2 (temp remainder of a0/32)
array_to_xy:
    # y = quotient of a0/32
    addi $t1, $zero, 32     # init $t1 = 32
    div $a0, $t1            # divide a0 by 32 
    mflo $v1                # v1 = y = quotient of a0 / 32
    
    # x = (remainder of a0/32) / 4
    mfhi $t2                # init $t2 = remainder of a0 / 32
    addi $t1, $zero, 4      # reassign $t1 = 4
    div $t2, $t1            # divide the remainder by 4
    mflo $v0                # v0 = x = quotient of remainder / 4
jr $ra
# END OF ARRAY_TO_XY

# START OF XY_TO_BITMAP
# translates row/column value to bitmap offset
# inputs: a0 (x value - 0:127), a1 (y value - 0:127) 
# returns: v0 (bitmap offset)
# registers: 
xy_to_bitmap:
    lw $t4, game_board_offset 
    # 128 = 2^7 so 128y = shift left by 7 bits
    sll $t3, $a1, 7             # $t3 = 128y
    add $t4, $t4, $t3           # $t4 = game_board_offset + 128y
    
    # 4 = 2^2 so 4x = shift left by 2 bits
    sll $t3, $a0, 2             # $t3 = 4x
    add $t4, $t4, $t3           # $t4 = game_board_offset + 128y + 4x 
    
    add $v0, $t4, $zero         # v0 = bitmap offset
jr $ra
# END OF XY_TO_BITMAP

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

# START CALCULATE_NEXT_XY
# function that calculates the next_x and next_y position and stores the new positions in memory
#       if the given key is one of w, a, s, d, write in a new_x and new_y
#       otherwise, the given key is n new_x and new_y are assigned to curr_x and curr_y, respectively

# note: all x and y's are in relation to the GAME ARRAY setup; no return, this function mutates
# inputs: a0 (the given key; it will be one of w, a, s, d, n)
# registers: t1 (curr_x1), t2 (curr_x2), t3 (new_x1 address), t4 (new_x2 address), t5 (curr_y1), t6 (curr_y2), t7 (new_y1 address), t8 (new_y2 address) 
calculate_new_xy:
    lw $t1, curr_x1             # t1 = curr_x1
    lw $t2, curr_x2             # t2 = curr_x2
    la $t3, new_x1              # t3 = new_x1 address
    la $t4, new_x2              # t4 = new_x2 address
    lw $t5, curr_y1             # t5 = curr_y1
    lw $t6, curr_y2             # t6 = curr_y2
    la $t7, new_y1              # t7 = new_y1 address
    la $t8, new_y2              # t8 = new_y2 address

    beq $a0, 0x61, shift_left                         # the given key is a
    beq $a0, 0x64, shift_right                        # the given key is d
    beq $a0, 0x77, rotate_clockwise                   # the given key is w
    beq $a0, 0x73, shift_down                         # the given key is s
    beq $a0, 0x6e, exit_calculate_next_xy             # the given key is n

    # When a is pressed, shift one unit left (only need x variables since it's a horizontal shift)
    # registers: t1 (curr_x1), t2 (curr_x2), t3 (new_x1 address), t4 (new_x2 address)
    shift_left:
        addi $t1, $t1, -1           # subtract one from curr_x1, curr_x2 to shift left
        addi $t2, $t2, -1
        
        sw $t1, 0($t3)              # store curr_x1 - 1 at new_x1 address
        sw $t2, 0($t4)              # store curr_x2 - 1 at new_x2 address
    j exit_calculate_next_xy
    
    # When d is pressed, shift one unit right (only need x variables since it's a horizontal shift)
    # registers: t1 (curr_x1), t2 (curr_x2), t3 (new_x1 address), t4 (new_x2 address)
    shift_right:
        addi $t1, $t1, 1           # add one from curr_x1, curr_x2 to shift right
        addi $t2, $t2, 1
        
        sw $t1, 0($t3)              # store curr_x1 + 1 at new_x1 address
        sw $t2, 0($t4)              # store curr_x2 + 1 at new_x2 address
    j exit_calculate_next_xy
    
    # When w is pressed, rotate one unit clockwise 
    # registers: t1 (curr_x1), t2 (curr_x2), t3 (new_x1 address), t4 (new_x2 address), t5 (curr_y1), t6 (curr_y2), t8 (new_y2 address)
    rotate_clockwise:
        beq $t5, $t6, horizontal_to_vertical        # if y1 == y2, then it is horizontal
        beq $t1, $t2, vertical_to_horizontal
        
        horizontal_to_vertical:
            blt $t1, $t2, rotate_down               # if x1 < x2, rotate x2, y2 down
            blt $t2, $t1, rotate_up                 # if x2 < x1, rotate x2, y2 up
            
            rotate_down:
                addi, $t6, $t6, 1           # curr_y2 + 1
                j exit_horz_to_vert
                
            rotate_up:
                addi, $t6, $t6, -1           # curr_y2 - 1
                j exit_horz_to_vert
            
            exit_horz_to_vert:
                sw $t6, 0($t8)              # store curr_y2 + 1 at new_y2 address
                sw $t1, 0($t4)              # store curr_x1 at new_x2 address
        j exit_calculate_next_xy
        
        vertical_to_horizontal:
            blt $t5, $t6, rotate_180               # if y2 < y1, rotate x2, y2 180 degrees (from original position where pill 1 is on the left and pill 2 is on the right)
            blt $t6, $t5, rotate_360                 # if y1 < y2, rotate x2, y2 360 degrees (from original position where pill 1 is on the left and pill 2 is on the right)
            
            rotate_180:
                addi, $t2, $t2, -1          # curr_x2 - 1
                j exit_vert_to_horz
            
            rotate_360:
                addi, $t2, $t2, 1           # curr_x2 + 1
                j exit_vert_to_horz
            
            exit_vert_to_horz:
                sw $t2, 0($t4)              # store curr_x2 - 1 at new_x2 address
                sw $t5, 0($t8)              # store curr_y1 at new_y2 address
        j exit_calculate_next_xy
    
    # When s is pressed, shift one unit down (only need y variables since it's a vertical shift)
    # registers: t5 (curr_y1), t6 (curr_y2), t7 (new_y1 address), t8 (new_y2 address)
    shift_down:
        addi $t5, $t5, 1           # add one from curr_y1, curr_y2 to shift down
        addi $t6, $t6, 1
        
        sw $t5, 0($t7)              # store curr_y1 + 1 at new_y1 address
        sw $t6, 0($t8)              # store curr_y2 + 1 at new_y2 address
    j exit_calculate_next_xy
       
    exit_calculate_next_xy:
    jr $ra
# END CALCULATE_NEXT_XY

# START OF UPDATE_CAPSULE_LOCATION
# function that stores the new capsule location (new_x, new_y) into their respective positions in the game_array and removes them from their previous location (curr_x, curr_y)
# registers: t0 (game_array pointer), t1 (x), t2 (y), t5 (game array address), t9 (temp colour), a0 (arg x for xy_to_array), a1 (arg y for xy_to_array)
update_capsule_location: 
    la $t5, game_array
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    # # remove value at curr_x1 and curr_y1
        # add $t0, $t5, $zero     # t0 = game_array pointer
        
        # lw $t1 curr_x1          # t1 = curr_x1
        # lw $t2 curr_y1          # t2 = curr_y1
        
        # add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        # add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        # jal xy_to_array         
        # add $t0, $t0, $v0       # t0 = game_array pointer + offset
        
        # lw $t9, black           # load the colour black into t9
        # sw $t9, 0($t0)          # set value at game_array[offset/4] to black (0)
    
    # set value at new_x1 and new_y1
        add $t0, $t5, $zero     # t0 = game_array pointer
        
        lw $t1 new_x1          # t1 = new_x1
        lw $t2 new_y1          # t2 = new_y1
        
        add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        jal xy_to_array         
        add $t0, $t0, $v0       # t0 = game_array pointer + offset
        
        lw $t9, colour_1        # load the first colour into t9
        sw $t9, 0($t0)          # set value at game_array[offset/4] to colour_1
    
    # # remove value at curr_x2 and curr_y2
        # add $t0, $t5, $zero     # t0 = game_array pointer
        
        # lw $t1 curr_x2          # t1 = curr_x2
        # lw $t2 curr_y2          # t2 = curr_y2
        
        # add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        # add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        # jal xy_to_array         
        # add $t0, $t0, $v0       # t0 = game_array pointer + offset
        
        # lw $t9, black           # load the colour black into t9
        # sw $t9, 0($t0)          # set value at game_array[offset/4] to black (0)
    
    # set value at new_x2 and new_y2
        add $t0, $t5, $zero     # t0 = game_array pointer
        
        lw $t1 new_x2          # t1 = new_x2
        lw $t2 new_y2          # t2 = new_y2
        
        add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        jal xy_to_array         
        add $t0, $t0, $v0       # t0 = game_array pointer + offset
        
        lw $t9, colour_2        # load the first colour into t9
        sw $t9, 0($t0)          # set value at game_array[offset/4] to colour_2
        
        lw $ra, 0($sp)           # Load the saved value of $ra from the stack
        addi $sp, $sp, 4         # Increase the stack pointer (free up space)
        jr $ra
# END OF UPDATE_CAPSULE_LOCATION

# START OF XY_TO_ARRAY
# translates row/column value to game_array offset
# inputs: a0 (x value - 0:127), a1 (y value - 0:127) 
# returns: v0 (offset)
# registers: t9 (temp left shift)
xy_to_array:
    # offset = 32y + 4x
    add $v0, $zero, $zero       # init $v0 = offset = 0
    
    # 32 = 2^5 so 32y = shift 5 bits left
    sll $t9, $a1, 5             # $t9 = 32y
    add $v0, $v0, $t9           # $v0 = game_board_offset + 32y
    
    # 4 = 2^2 so 4x = shift 2 bits left
    sll $t9, $a0, 2             # $t9 = 4x
    add $v0, $v0, $t9           # $v0 = game_board_offset + 32y + 4x
jr $ra
# END OF ARRAY_TO_XY

# START CHECK_WALL_COLLISION
# returns: v0 (boolean; 0 if there is no collision, 1 if there is a collision) 
# registers: t1 (new_x1), t2 new_y1), t3 (new_x2), t4 (new_y2)
check_wall_collision:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    # assign t1-t4 to new_x, new_y data
    lw $t1, new_x1              # t1 = new_x1
    lw $t2, new_y1              # t2 = new_y1
    lw $t3, new_x2              # t3 = new_x2
    lw $t4, new_y2              # t4 = new_y2
    
    # check the collision with the walls 
    # new_x1 < 0 (left side of board)
    bltz $t1, wall_collision_true               # if x1 < 0, the pill hit the left side
    bltz $t3,  wall_collision_true               # if x2 >= 16, the pill hit the left side
        
    # new_x1 >= 8 (right side of board)
    bge $t1, 8, wall_collision_true             # if x1 >= 8, the pill hit the right side
    bge $t3, 8, wall_collision_true             # if x2 >= 8, the pill hit the right side
        
    # new_y1 < 0 (top of board)
    bltz $t2, wall_collision_true               # if y1 < 0, the pill hit the top
    bltz $t4, wall_collision_true               # if y2 < 0, the pill hit the top
        
    # Otherwise, we know there are no collisions so set return value = 0
    add $v0, $zero, $zero
    j exit_check_wall_collision                      # return = 0 (no collision)
        
    wall_collision_true:
    addi $v0, $zero, 1                          # return = 1 (collision)
            
    exit_check_wall_collision:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    jr $ra
# END WALL_CHECK_COLLISION


# START CHECK_OBJECT_COLLISION
# assumes that there is no wall collision (within walls)
# input: a0 (new_x), a1 (new_y)
# returns: v0 (boolean; 0 if there is no collision, 1 if there is a collision) 
# registers: t0 (game_array pointer), t1 (new_x1), t2 new_y1), t3 (new_x2), t4 (new_y2), t5 (game_array base address), t9 (value at game_array[x, y])
check_object_collision:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    la $t5, game_array          # load game_array base address
    
    # assign t1-t4 to new_x, new_y data
    lw $t1, new_x1              # t1 = new_x1
    lw $t2, new_y1              # t2 = new_y1
    lw $t3, new_x2              # t3 = new_x2
    lw $t4, new_y2              # t4 = new_y2
    
    # game_array[new_x1, new_y1] is not empty
    add $a0, $t1, $zero                         # arg new_x1 for xy_to_array
    add $a1, $t2, $zero                         # arg new_y1 for xy_to_array
    jal xy_to_array             
    add $t0, $t5, $v0                           # t0 = game_array base address + offset (pointer)
    lw $t9, 0($t0)                              # load value at game_array[new_x1, new_y1]
    bne $t9, $zero, object_collision_true       # if there is value that is not 0 (black), jump to return true
    
    # game_array[new_x2, new_y2] is not empty
    add $a0, $t3, $zero                         # arg new_x1 for xy_to_array
    add $a1, $t4, $zero                         # arg new_y1 for xy_to_array
    jal xy_to_array             
    add $t0, $t5, $v0                           # t0 = game_array base address + offset (pointer)
    lw $t9, 0($t0)                              # load value at game_array[new_x1, new_y1]
    bne $t9, $zero, object_collision_true       # if there is value that is not 0 (black), jump to return true
    
    # Otherwise, we know there are no collisions so set return value = 0
    add $v0, $zero, $zero                       # return = 0 (no collision)
    j exit_check_object_collision                      
    
    object_collision_true:
    addi $v0, $zero, 1                          # return = 1 (collision)
            
    exit_check_object_collision:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    jr $ra
# END CHECK_OBJECT_COLLISION

# START CHECK_BOTTOM_COLLISION
# returns: v0 (boolean; 0 if there is no collision, 1 if there is a collision) 
# registers: t1 (new_x1), t2 new_y1), t3 (new_x2), t4 (new_y2)
check_bottom_collision:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    # assign t1-t4 to new_x, new_y data
    lw $t1, new_x1              # t1 = new_x1
    lw $t2, new_y1              # t2 = new_y1
    lw $t3, new_x2              # t3 = new_x2
    lw $t4, new_y2              # t4 = new_y2
    
    # new_y1 >= 16 (height of game_array)
    bge $t2, 16, bottom_collision_true          # if y1 >= 16, the pill hit the bottom
    
    # new_y2 >= 16 (height of game_array)
    bge $t4, 16, bottom_collision_true          # if y2 >= 16, the pill hit the bottom
    
    # Otherwise, we know there are no collisions so set return value = 0
    add $v0, $zero, $zero
    j exit_check_bottom_collision                      # return = 0 (no collision)
        
    bottom_collision_true:
    addi $v0, $zero, 1                          # return = 1 (collision)
            
    exit_check_bottom_collision:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    jr $ra
# END CHECK_BOTTOM_COLLISION

exit: