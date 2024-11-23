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
    
    # skip_pill:
    # 1A. CHECK IF KEY HAS BEEN PRESSED & 1B. CHECK WHICH KEY HAS BEEN PRESSED
    jal check_key_press
    
    add $s0, $v0, $zero             # s0 = keypress (constant for the loop)
    add $a0, $s0, $zero             # output key from check_key_press is the input to calculate_next_xy
    jal calculate_new_xy            # after this call, new_x and new_y will contain new positions
    
    # 2A. CHECK FOR COLLISIONS
    # remove the current values from the game_array
    la $t5, game_array          # load the address of the game_array
    la $t4, capsuleID_array     # load the address of the capsuleID_array
    
    # remove value of game_array[curr_x1, curr_y1] 
    lw $t7, curr_x1              # t1 = curr_x1
    lw $t8, curr_y1              # t2 = curr_y1
    add $a0, $t7, $zero          # arg x for xy_to_array
    add $a1, $t8, $zero          # arg y for xy_to_array
    jal xy_to_array
    
    add $t0, $t5, $v0           # points to game_array[curr_x1, curr_y1]
    lw $t9, black               # load the colour black
    sw $t9, 0($t0)              # put the colour black into game_array[curr_x1, curr_y1]
    
    add $t1, $t4, $v0           # points to capsuleID_array[curr_x1, curr_y1]
    sw $zero, 0($t1)            # put zero into the capsuleID_array[curr_x1, curr_y1]
    
    # remove value of game_array[curr_x2, curr_y2]
    lw $t7, curr_x2              # t1 = curr_x2
    lw $t8, curr_y2              # t2 = curr_y2
    add $a0, $t7, $zero          # arg x for xy_to_array
    add $a1, $t8, $zero          # arg y for xy_to_array
    jal xy_to_array
    add $t0, $t5, $v0           # points to game_array[curr_x2, curr_y2]
    lw $t9, black               # load the colour black
    sw $t9, 0($t0)              # put the colour black into game_array[curr_x2, curr_y2]
    add $t1, $t4, $v0           # points to capsuleID_array[curr_x1, curr_y1]
    sw $zero, 0($t1)            # put zero into the capsuleID_array[curr_x1, curr_y1]
    
    beq $s0, 0x61, check_side_collision                         # the given key is a
    beq $s0, 0x64, check_side_collision                         # the given key is d
    beq $s0, 0x77, check_side_collision                         # the given key is w
    beq $s0, 0x73, check_down_collision                         # the given key is s
    j location
    
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
    beq $v0, 1, down_collision_true                # returns 1 if collision
    
    # otherwise, the pill did not hit a wall
    jal check_object_collision          # checks if the pill hit an object
    beq $v0, 1, down_collision_true                # returns 1 if collision
    
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
    
    down_collision_true:
    jal update_capsule_location
    jal merge_row
    jal merge_column
    jal generate_pill
    j location 
        
	# 2B. UPDATE LOCATION (CAPSULES)
	location:
	jal update_capsule_location             # after this call, the game_array locations should be updated
	# jal merge_row
	
	# 3. Draw the screen
	jal update_display

    # 5. Go back to Step 1
    j game_loop
    
    # # 4. Sleep
	# li $v0, 32
	# li $a0, 320
	# syscall

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
# registers: t0 (game_array pointer), t1 (generated x value), t2 (generated y value), t3 (generated colour), t4 (capsuleID_array), t5 (game_array pointer)
#            t6 (value at game_array pointer), t7 (loop bound), t8 (virus counter)
generate_virus: 
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    add $t7, $a0, $zero         # init loop bound to a0
    add $t8, $zero, $zero       # init loop counter to 0
    
    generate_virus_loop:
        la $t5, game_array          # load the base address of the game_array
        la $t4, capsuleID_array     # load the base address of the capsuleID_array
        
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
        add $t4, $t4, $v0                   # add offset to base address of the capsuleID_array
        lw $t6, 0($t5)                      # load the value at the offset game_array address at t6
        beq $t6, $zero, set_virus           # if the value is equal to 0 (is empty), set the virus
        j next_generate_virus_loop          # otherwise, start the loop again
        
        set_virus:
            sw $t3, 0($t5)              # store the colour of the virus at this offset
            add $t9, $zero, -1          # t9 = -1
            sw $t9, 0($t4)              # store -1 (virus id) at this offset
            addi $t8, $t8, 1            # increase the virus counter by 1
            j next_generate_virus_loop
        
        next_generate_virus_loop:
        blt $t8, $t7, generate_virus_loop       # exit when t8 (virus counter) = t7 = a0 = loop bound       
    
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)

    jr $ra
# END GENERATE_VIRUS

# FUNCTION THAT GENERATES A RANDOM BI-COLOURED PILL AND DRAWS IT AT THE TOP OF THE BOTTLE
# registers: t0 (game_array pointer), t1 (initial position of left half), v0 (return val from generate_colour)
generate_pill: 
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    # checks if there is something blocking the entrance already
    lw $t1, init_x1             # load initial x1 value into t1
    lw $t2, init_y1             # load initial y1 value into t2    
    la $t9, new_x1              # t9 = address of new_x1
    la $t8, new_y1              # t8 = address of new_y1
    sw $t1, 0($t9)              # store intial x1 value in new_x1
    sw $t2, 0($t8)              # store intial y1 value in new_y1
    
    lw $t1, init_x2             # load initial x2 value into t1
    lw $t2, init_y2             # load initial y2 value into t2
    la $t9, new_x2              # t9 = address of new_x2
    la $t8, new_y2              # t8 = address of new_y2
    sw $t1, 0($t9)              # store intial x2 value in new_x2
    sw $t2, 0($t8)              # store intial y2 value in new_y2
    
    jal check_object_collision
    beq $v0, 0, skip_game_over      # if there is no object at 
    li $v0, 10                      # quit gracefully
    syscall
    
    skip_game_over:
    la $t7, colour_1            # t7 = address of colour_1
    jal generate_colour         # generate the left half of the pill and init at top of bottle
    sw $v0, 0($t7)              # store generated colour in colour_1
    
    la $t9, curr_x1             # t9 = address of x1
    la $t8, curr_y1             # t8 = address of y1
    lw $t1, init_x1             # load initial x1 value into t1
    lw $t2, init_y1             # load initial y1 value into t2
    sw $t1, 0($t9)              # store intial x1 value in curr_x1
    sw $t2, 0($t8)              # store intial y1 value in curr_y1
    
    la $t7, colour_2            # t7 = address of colour_1
    jal generate_colour         # generate the right half of the pill and init at top of bottle
    sw $v0, 0($t7)              # store generated colour in colour_1
    
    la $t9, curr_x2             # t9 = address of x2
    la $t8, curr_y2             # t8 = address of y2
    lw $t1, init_x2             # load initial x2 value into t1
    lw $t2, init_y2             # load initial y2 value into t2
    sw $t1, 0($t9)              # store intial x2 value in curr_x2
    sw $t2, 0($t8)              # store intial y2 value in curr_y2
    
    la $t6, capsuleID_count     # address of capsuleID_count
    lw $t5, capsuleID_count     # value of capsuleID_count
    addi $t5, $t5, 1            # add one to the capsuleID_count
    sw $t5, 0($t6)              # store capsuleID_count + 1 
    
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
    ############
    store_registers()           # store registers
    
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
    
    load_registers()
    ###############
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
    store_registers()
    
    lw $t1, curr_x1             # t1 = curr_x1
    lw $t2, curr_x2             # t2 = curr_x2
    la $t3, new_x1              # t3 = new_x1 address
    la $t4, new_x2              # t4 = new_x2 address
    lw $t5, curr_y1             # t5 = curr_y1
    lw $t6, curr_y2             # t6 = curr_y2
    la $t7, new_y1              # t7 = new_y1 address
    la $t8, new_y2              # t8 = new_y2 address
    
    # to ensure proper calculations, set new_x, new_y as curr_x, curr_y 
    sw $t1, 0($t3)              # set new_x1 = curr_x1
    sw $t2, 0($t4)              # set new_x2 = curr_x2
    sw $t5, 0($t7)              # set new_y1 = curr_y1
    sw $t6, 0($t8)              # set new_y2 = curr_y2

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
    load_registers()
    jr $ra
# END CALCULATE_NEXT_XY

# START OF UPDATE_CAPSULE_LOCATION
# function that stores the capsule location into their respective positions in the game_array 
# registers: t0 (game_array pointer), t1 (x), t2 (y), t4 (capsuleID address), t5 (game array address), 
#            t8 (capsuleID_array pointer), t9 (temp colour), a0 (arg x for xy_to_array), a1 (arg y for xy_to_array)
update_capsule_location: 
    la $t5, game_array
    la $t4, capsuleID_array
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    # set value at curr_x1 and curr_y1
        add $t0, $t5, $zero     # t0 = game_array pointer
        
        lw $t1 curr_x1          # t1 = curr_x1
        lw $t2 curr_y1          # t2 = curr_y1
        
        add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        jal xy_to_array         
        
        add $t0, $t0, $v0       # t0 = game_array pointer + offset
        lw $t9, colour_1        # load the first colour into t9
        sw $t9, 0($t0)          # set value at game_array[offset/4] to colour_1
        
        add $t8, $t4, $zero     # t8 = capsuleID_array pointer
        add $t8, $t8, $v0       # t8 = capsuleID_array pointer + offset
        lw $t9, capsuleID_count # load the current capsule count into t9
        sw $t9, 0($t8)          # set value at capsuleID_array pointer to capsuleID count
        
    
    # set value at curr_x2 and curr_y2
        add $t0, $t5, $zero     # t0 = game_array pointer
        
        lw $t1 curr_x2          # t1 = new_x2
        lw $t2 curr_y2          # t2 = new_y2
        
        add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        jal xy_to_array         
        
        add $t0, $t0, $v0       # t0 = game_array pointer + offset
        lw $t9, colour_2        # load the first colour into t9
        sw $t9, 0($t0)          # set value at game_array[offset/4] to colour_2 
        
        add $t8, $t4, $zero     # t8 = capsuleID_array pointer
        add $t8, $t8, $v0       # t8 = capsuleID_array pointer + offset
        lw $t9, capsuleID_count # load the current capsule count into t9
        sw $t9, 0($t8)          # set value at capsuleID_array pointer to capsuleID count
        
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
    bltz $t3,  wall_collision_true               # if x2 < 0, the pill hit the left side
        
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
    store_registers()
    
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
    load_registers()
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    jr $ra
# END CHECK_OBJECT_COLLISION

# START CHECK_BOTTOM_COLLISION
# returns: v0 (boolean; 0 if there is no collision, 1 if there is a collision) 
# registers: t1 (curr_x1), t2 (curr_y1), t3 (curr_x2), t4 (curr_y2)
check_bottom_collision:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    store_registers()
    
    # assign t1-t4 to new_x, new_y data
    lw $t1, curr_x1              # t1 = curr_x1
    lw $t2, curr_y1              # t2 = curr_y1
    lw $t3, curr_x2              # t3 = curr_x2
    lw $t4, curr_y2              # t4 = curr_y2
    
    # new_y1 >= 15 (height of game_array)
    bge $t2, 15, bottom_collision_true          # if y1 >= 16, the pill hit the bottom
    
    # new_y2 >= 15 (height of game_array)
    bge $t4, 15, bottom_collision_true          # if y2 >= 16, the pill hit the bottom
    
    # Otherwise, we know there are no collisions so set return value = 0
    add $v0, $zero, $zero
    j exit_check_bottom_collision                      # return = 0 (no collision)
        
    bottom_collision_true:
    addi $v0, $zero, 1                          # return = 1 (collision)
            
    exit_check_bottom_collision:
    load_registers()
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    jr $ra
# END CHECK_BOTTOM_COLLISION

# START OF MERGE_ROW
# returns: v0 (game_array offset of the end of 4 same colours in a row or 0 if there are none)
# registers: t0 (game_array pointer), t3 (y/row count), t4 (loop unit count), t5 (game_array address), 
#            t6 (max units in a row count; from call the check_merge_row), t9 (the colour black)
merge_row:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    lw $t9, black
    
    # loop that checks each row to see if we there are at least 4 in a row, and merges if so. (starts from bottom)
    addi $t3, $zero, 15         # initialise the row count (starts from bottom, last row = 15)
    
    merge_row_loop:
        # call to check_merge_row of the current row to find out if a merge is needed. 
        add $a0, $t3, $zero                     # arg to check_merge_row; current y/row value
        jal check_merge_row
        
        la $t5, game_array
        add $t0, $t5, $v0                       # set the game_array pointer to the base address + returned offset of the last of the same colour units (-1 = no units to merge)
        add $t6, $zero, $v1                     # t6 = v1 = the number of units to merge (0 or a value >=4) 
        
        beq $t6, $zero, decrement_merge_row_loop        # if the number of units to merge is zero, go on to the next loop (check the next row)
        
        # otherwise, the number of units to merge >= 4
        # loop that changes all units in a row of the same colour to black
        add $t4, $zero, $zero                   # set the loop unit count to 0
        la $t8, capsuleID_array                 # load address of capsuleID_array into t8
        add $t8, $t8, $v0                       # set the capsuleID_array pointer to the base address + returned offset of the last of the same colour units
        merge_row_units_loop:
            addi $t4, $t4, 1                        # increment the loop counter by 1
            
            sw $t9, 0($t0)                          # sets the value at game_array pointer to black
            addi $t0, $t0, -4                       # decreases the game_array pointer by 4 because it was initialised at the last of the same colour units
            sw $zero, 0($t8)                        # sets the value at capsuleID_array to 0
            addi $t8, $t8, -4                       # decreases the capsuleID_array pointer by 4 because it was initialised at the last of the same colour units
            
            bne $t4, $t6, merge_row_units_loop          # loops until the loop counter = the number of units to merge
        jal drop_capsule
        j merge_row_loop                            # jump to start of merge_row_loop to check the current row again for any more same colours
        
        decrement_merge_row_loop:
            addi $t3, $t3, -1                       # decrease the row number by 1
            bge $t3, 0, merge_row_loop              # loops until it hits the top row of the game

exit_merge_row:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra

# START OF CHECK_MERGE_ROW
# inputs: a0 (y/row value)
# returns: v0 (game_array offset of the end of v1 same colours in a row or -1 if there are none), 
#          v1 (if there are >= 4 units of the same colour return that number; if there are < 4, return 0)
# registers: t0 (game_array pointer), t1 (colour count), t2 (x/column count), t5 (game_array address), t7 (current colour), t8 (next colour), t9 (the colour black)
check_merge_row:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack

    lw $t9, black               # load the colour black into t9
    la $t5, game_array          # load the game array base address into t5
    
    # need to add 32 y times
    sll $t0, $a0, 5             # multiply y by 32
    add $t0, $t0, $t5           # initialise the game_array pointer
    
    # loop that checks the row for 4 consecutive values of the same colour
    addi $t1, $zero, 1          # initialise the colour count
    lw $t7, black               # initialise the current colour
    add $t2, $zero, $zero       # reset the loop counter
    
    
    check_merge_row_loop:
        lw $t8, 0($t0)              # load the colour at the game array index into t8
        
        beq $t7, $t8, check_merge_row_loop_equals       # if the current colour and next colour are equal, jump to that condition
        
        # otherwise, we know that the next colour is different from the current colour (and is not black)
        bge $t1, 4, return_merge_row_positive       # if the colour count >= 4, jump to return
        
        add $t7, $t8, $zero                         # set current colour = next colour
        addi $t1, $zero, 1                           # reset the colour count
        j increment_check_merge_row_loop
        
        # we know that the current colour and next colour are equal. increment the colour count by 1 and check for 4 in a row.
        check_merge_row_loop_equals:
            beq $t9, $t8, check_merge_row_loop_black    # if the colour is black, jump to that condition
            addi $t1, $t1, 1                            # increment the current colour count by 1
            j increment_check_merge_row_loop
        
        # we know that the current colour is black
        check_merge_row_loop_black:
        addi $t1, $zero, 1                              # reset the colour count
        j increment_check_merge_row_loop                # next loop
        
        increment_check_merge_row_loop:
            addi $t2, $t2, 1                            # increase the loop counter by 1
            addi $t0, $t0, 4                            # add 4 to the game_array offset to check the next value
            blt $t2, 8, check_merge_row_loop            # jump to next loop if $t2 is less than 8
    
    bge $t1, 4, return_merge_row_positive
    
    # there are no four consecutive same colours
    return_merge_row_negative:
    addi $v0, $zero, -1                       # return -1 as game_array offset to indicate no merge
    add $v1, $zero, $zero                     # return zero as number of units to merge  
    j exit_check_merge_row
    
    # there are four consecutive same colours
    return_merge_row_positive:
    sub $t0, $t0, $t5                           # the game_array offset (last value)
    subi $t0, $t0, 4
    add $v0, $t0, $zero                         # returns the game_array offset
    add $v1, $t1, $zero                         # returns the number of units that are the same colour
    j exit_check_merge_row
    
    exit_check_merge_row:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stackw
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF CHECK_MERGE_ROW

# START OF MERGE_COLUMN
# returns: v0 (game_array offset of the end of 4 same colours in a column or 0 if there are none)
# registers: t0 (game_array pointer), t3 (x/column count), t4 (loop unit count), t6 (max units in a column count; from call to check_merge_column), 
#            t5 (game_array address), t9 (the colour black)
merge_column:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    lw $t9, black
    
    # loop that checks each row to see if we there are at least 4 in a row, and merges if so. (starts from bottom)
    add $t3, $zero, $zero         # initialise the column count (starts from left side, first column = 0)
    
    merge_column_loop:
        # call to check_merge_column of the current column to find out if a merge is needed. 
        add $a0, $t3, $zero                     # arg to check_merge_column; current x/column value
        jal check_merge_column
        
        add $t0, $t5, $v0                       # set the game_array pointer to the base address + returned offset of the last of the same colour units (-1 = no units to merge)
        add $t6, $zero, $v1                     # t6 = v1 = the number of units to merge (0 or a value >=4) 
        
        beq $t6, $zero, decrement_merge_column_loop        # if the number of units to merge is zero, go on to the next loop (check the next column)
        
        # otherwise, the number of units to merge >= 4
        # loop that changes all units in a row of the same colour to black
        add $t4, $zero, $zero                   # set the loop unit count to 0
        la $t8, capsuleID_array                 # load address of capsuleID_array into t8
        add $t8, $t8, $v0                       # set the capsuleID_array pointer to the base address + returned offset of the last of the same colour units
        merge_column_units_loop:
            addi $t4, $t4, 1                        # increment the loop counter by 1
            
            sw $t9, 0($t0)                          # sets the value at game_array pointer to black
            addi $t0, $t0, -32                       # decreases the game_array pointer by 32 (8 units per row * 4 bits per unit) because it was initialised at the last of the same colour units
            sw $zero, 0($t8)                        # sets the value at capsuleID_array to 0
            addi $t8, $t8, -32                      # decreases the capsuleID_array pointer by 32 because it was initialised at the last of the same colour units
            
            bne $t4, $t6, merge_column_units_loop          # loops until the loop counter = the number of units to merge
        
        add $t8, $zero, $zero                          # drop_capsule_loop loop counter 
        drop_capsule_loop:
            addi $t8, $t8, 1
            jal drop_capsule
        blt $t8, 16, drop_capsule_loop
        j merge_column_loop                            # jump to start of merge_row_loop to check the current row again for any more same colours
        
        decrement_merge_column_loop:
            addi $t3, $t3, 1                           # increase the row number by 1
            ble $t3, 7, merge_column_loop              # loops until it hits the last column in the bottle (7)

exit_merge_column:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra

# START OF CHECK_MERGE_ROW
# inputs: a0 (x/column value)
# returns: v0 (game_array offset of the end of v1 same colours in a row or -1 if there are none), 
#          v1 (if there are >= 4 units of the same colour return that number; if there are < 4, return 0)
# registers: t0 (game_array pointer), t1 (colour count), t2 (x/column count), t5 (game_array address), t7 (current colour), t8 (next colour), t9 (the colour black)
check_merge_column:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack

    lw $t9, black               # load the colour black into t9
    la $t5, game_array          # load the game array base address into t5
    
    # need to multiply x by 4
    sll $t0, $a0, 2             # multiply x by 4
    add $t0, $t0, $t5         # initialise the game_array pointer
   
    # loop that checks the column for consecutive values of the same colour
    addi $t1, $zero, 1          # initialise the colour count
    lw $t7, black               # initialise the current colour
    add $t2, $zero, $zero       # reset the loop counter
    
    check_merge_column_loop:
        lw $t8, 0($t0)              # load the colour at the game array index into t8
        
        beq $t7, $t8, check_merge_column_loop_equals       # if the current colour and next colour are equal, jump to that condition
        
        # otherwise, we know that the next colour is different from the current colour 
        bge $t1, 4, return_merge_column_positive       # if the colour count >= 4, jump to return
        
        add $t7, $t8, $zero                         # set current colour = next colour
        addi $t1, $zero, 1                           # reset the colour count
        j increment_check_merge_column_loop
        
        # we know that the current colour and next colour are equal. increment the colour count by 1.
        check_merge_column_loop_equals:
            beq $t9, $t8, check_merge_column_loop_black    # if the colour is black, jump to that condition
            addi $t1, $t1, 1                                # increment the current colour count by 1
            j increment_check_merge_column_loop
        
        # we know that the current colour is black
        check_merge_column_loop_black:
            addi $t1, $zero, 1                              # reset the colour count
        j increment_check_merge_column_loop                # next loop
        
        increment_check_merge_column_loop:
            addi $t2, $t2, 1                            # increase the loop counter by 1
            addi $t0, $t0, 32                            # add 32 to the game_array offset to check the next value in the column
            blt $t2, 16, check_merge_column_loop            # jump to next loop if $t2 is less than 16
    
    bge $t1, 4, return_merge_column_positive
    
    # there are no four consecutive same colours
    return_merge_column_negative:
    addi $v0, $zero, -1                       # return -1 as game_array offset to indicate no merge
    add $v1, $zero, $zero                     # return zero as number of units to merge  
    j exit_check_merge_column
    
    # there are four consecutive same colours
    return_merge_column_positive:
    sub $t0, $t0, $t5                           # the game_array offset (last value)
    subi $t0, $t0, 32
    add $v0, $t0, $zero                         # returns the game_array offset
    add $v1, $t1, $zero                         # returns the number of units that are the same colour
    j exit_check_merge_column
    
    exit_check_merge_column:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF CHECK_MERGE_COLUMN

# START OF DROP_CAPSULE
# function to drop each capsule
# registers: all of them... this function is too confusing to name all the registers I used and their function
# saved registers: s0 (x loop count), s1 (y loop count), s6 (capsuleID_array address), s7 (game_array address)
drop_capsule:
subi $sp, $sp, 4
sw $ra, 0($sp)
store_registers()

la $t9, capsuleID_max       # load capsuleID_max addresss
lw $t8, capsuleID_count     # load capsuleID_count number
sw $t8, 0($t9)              # store capsuleID_count to capsuleID_max 

la $s7, game_array
la $s6, capsuleID_array

addi $s1, $zero, 15         # initialise y count (starts from second last row, last row = 15)
add $s0, $zero, $zero       # initialise x count

drop_capsule_loop_y:
addi $s1, $s1, -1
add $s0, $zero, $zero       # reset x count (column) when we reach a new y count (row) 

drop_capsule_loop_x:
    # initialise capsule info to (-1, -1) and black
    # capsule half 1
    la $t1, curr_x1
    la $t2, curr_y1
    addi $t3, $zero, -1
    sw $t3, 0($t1)
    sw $t3, 0($t2)
    
    la $t1, colour_1
    lw $t2, black
    sw $t2, 0($t1)
    
    # capsule half 2
    la $t1, curr_x2
    la $t2, curr_y2
    addi $t3, $zero, -1
    sw $t3, 0($t1)
    sw $t3, 0($t2)
    
    la $t1, colour_2
    lw $t2, black
    sw $t2, 0($t1)

    # check if current xy contains a capsule
    add $a0, $zero, $s0     # x value arg for xy_to_array
    add $a1, $zero, $s1     # y value arg for xy_to_array
    jal xy_to_array
    add $t9, $s7, $v0       # game_array pointer = base address + offset
    add $t8, $s6, $v0       # capsuleID_array pointer = base address + offset
    
    lw $t7, 0($t9)                              # colour at game_array pointer
    lw $t6, 0($t8)                              # capsuleID at capsuleID_array pointer (current unit's capsuleID)
    beq $t7, 0, increment_capsule_loop_x        # if the colour at the game_array pointer is black, go to next loop
    beq $t6, -1, increment_capsule_loop_x       # if the value at the capsuleID is -1 (virus), go to next loop
    
    # otherwise, the current unit is not black, reconstruct the capsule
    la $t1, curr_x1         # store loop x, y at curr_x1, curr_y1
    la $t2, curr_y1
    sw $s0, 0($t1)
    sw $s1, 0($t2)
    
    la $t1, colour_1        # store the colour at the pixel at colour_1
    sw $t7, 0($t1)    
    
    la $t1, capsuleID_count     # to reconstruct, store the current capsuleID from the pointer in capsuleID_count
    sw $t6, 0($t1)
    
    # Find the other half of the capsule
    beq $s0, 0, skip_check_left         # if x loop value == 0, there is no left column
    addi $t0, $t8, -4                    # check left in capsuleID_array
    lw $t1, 0($t0)                      # load value from capsuleID_array
    beq $t1, $t6, capsule_to_left      # the capsule half to the left matches the capsule ID
    
    skip_check_left:
    beq $s0, 7, skip_check_right        # if x loop value == 7, there is no right column
    addi $t0, $t8, 4                   # check right in capsuleID_array
    lw $t1, 0($t0)                      # load value from capsuleID_array
    beq $t1, $t6, capsule_to_right       # the capsule half to the right matches the capsule ID
    
    skip_check_right:
    beq $s1, 0, drop_capsule_action     # if y loop value == 0, there is no row above
    addi $t0, $t8, -32                  # check top in capsuleID_array
    lw $t1, 0($t0)                      # load value from capsuleID_array
    beq $t1, $t6, capsule_to_top       # the capsule half to the top matches the capsule ID
    
    j drop_capsule_action
    
    capsule_to_top:
    la $t1, curr_x2         # store loop x, y-1 at curr_x2, curr_y2
    la $t2, curr_y2
    addi $t3, $s1, -1       # t3 = y-1
    sw $s0, 0($t1)
    sw $t3, 0($t2)
    
    la $t1, colour_2        # store the colour at the pixel at colour_1
    lw $t7, -32($t9)        # value at game_array pointer - 32 (one row up)
    sw $t7, 0($t1)    
    j drop_capsule_action
    
    capsule_to_right:
    la $t1, curr_x2         # store loop x + 1, y at curr_x2, curr_y2
    la $t2, curr_y2
    addi $t3, $s0, 1       # t3 = x + 1
    sw $s1, 0($t2)
    sw $t3, 0($t1)
    # sw $s0, 0($t1)
    # sw $t3, 0($t2)
    
    la $t1, colour_2        # store the colour at the pixel at colour_1
    lw $t7, 4($t9)          # value at game_array pointer + 4 (one unit right)
    sw $t7, 0($t1)    
    j drop_capsule_action
    
    capsule_to_left:
    la $t1, curr_x2         # store loop x - 1, y at curr_x2, curr_y2
    la $t2, curr_y2
    addi $t3, $s0, -1       # t3 = x - 1
    sw $s1, 0($t2)          # store y from loop in curr_y2
    sw $t3, 0($t1)          # store x -1 from loop in curr_x2
    # sw $s0, 0($t1)
    # sw $t3, 0($t2)
    
    la $t1, colour_2        # store the colour at the pixel at colour_1
    lw $t7, -4($t9)         # value at game_array pointer - 4 (one unit left)
    sw $t7, 0($t1)   
    j drop_capsule_action
    
    drop_capsule_action:
    lw $t1, colour_1
    lw $t2, colour_2
    
    beq $t1, 0,  increment_capsule_loop_x        # colour 1 is black
    beq $t2, 0, move_half_capsule        # colour 2 is black but colour 1 is not
    
    # otherwise, we know neither colour_1 or colour_2 are black
    move_full_capsule:
        # calculate new_x, new_y given that the keypress is down
        addi $a0, $zero, 0x73           # dropping, so keypress = s
        jal calculate_new_xy            # after this call, new_x and new_y will contain new positions
        
        # remove the current values from the game_array and capsuleID_array
        la $t5, game_array          # load the address of the game_array
        la $t4, capsuleID_array     # load the address of the capsuleID_array
        
        # remove value of game_array[curr_x1, curr_y1] 
        lw $t7, curr_x1              # t1 = curr_x1
        lw $t8, curr_y1              # t2 = curr_y1
        add $a0, $t7, $zero          # arg x for xy_to_array
        add $a1, $t8, $zero          # arg y for xy_to_array
        jal xy_to_array
        
        add $t0, $t5, $v0           # points to game_array[curr_x1, curr_y1]
        lw $t9, black               # load the colour black
        sw $t9, 0($t0)              # put the colour black into game_array[curr_x1, curr_y1]
        
        add $t1, $t4, $v0           # points to capsuleID_array[curr_x1, curr_y1]
        sw $zero, 0($t1)            # put zero into the capsuleID_array[curr_x1, curr_y1]
        
        # remove value of game_array[curr_x2, curr_y2]
        lw $t7, curr_x2              # t1 = curr_x2
        lw $t8, curr_y2              # t2 = curr_y2
        add $a0, $t7, $zero          # arg x for xy_to_array
        add $a1, $t8, $zero          # arg y for xy_to_array
        jal xy_to_array
        add $t0, $t5, $v0           # points to game_array[curr_x2, curr_y2]
        lw $t9, black               # load the colour black
        sw $t9, 0($t0)              # put the colour black into game_array[curr_x2, curr_y2]
        add $t1, $t4, $v0           # points to capsuleID_array[curr_x1, curr_y1]
        sw $zero, 0($t1)            # put zero into the capsuleID_array[curr_x1, curr_y1]
        
        check_down_collision_drop_full:
            jal check_bottom_collision          # checks if the pill hit the bottom of the walls
            beq $v0, 1,  restore_capsule               # returns 1 if collision
            # beq $v0, 1,  increment_capsule_loop_x               # returns 1 if collision
            
            # otherwise, the pill did not hit a wall
            jal check_object_collision                          # checks if the pill hit an object
            beq $v0, 1,  restore_capsule             # returns 1 if collision
            # beq $v0, 1,  increment_capsule_loop_x             # returns 1 if collision
            
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
        j restore_capsule
        # j  increment_capsule_loop_x
    
    move_half_capsule:
        jal calculate_new_xy_drop_half            # after this call, new_x and new_y will contain new positions
        
        # remove the current values from the game_array and capsuleID_array
        la $t5, game_array          # load the address of the game_array
        la $t4, capsuleID_array     # load the address of the capsuleID_array
        
        # remove value of game_array[curr_x1, curr_y1] 
        lw $t7, curr_x1              # t1 = curr_x1
        lw $t8, curr_y1              # t2 = curr_y1
        add $a0, $t7, $zero          # arg x for xy_to_array
        add $a1, $t8, $zero          # arg y for xy_to_array
        jal xy_to_array
        
        add $t0, $t5, $v0           # points to game_array[curr_x1, curr_y1]
        lw $t9, black               # load the colour black
        sw $t9, 0($t0)              # put the colour black into game_array[curr_x1, curr_y1]
        
        add $t1, $t4, $v0           # points to capsuleID_array[curr_x1, curr_y1]
        sw $zero, 0($t1)            # put zero into the capsuleID_array[curr_x1, curr_y1]
        
        check_down_collision_drop_half:
            jal check_bottom_collision_half          # checks if the pill hit the bottom of the walls
            beq $v0, 1, restore_capsule_half               # returns 1 if collision
            # beq $v0, 1, increment_capsule_loop_x               # returns 1 if collision
            
            # otherwise, the pill did not hit a wall
            jal check_object_collision_half                          # checks if the pill hit an object
            beq $v0, 1, restore_capsule_half                # returns 1 if collision
            # beq $v0, 1, increment_capsule_loop_x                # returns 1 if collision
            
            # otherwise, we can move the pill to the new position
            # update curr_x, curr_y = new_x, new_y
            la $t1, curr_x1         # t1 = curr_x1 address
            lw $t2, new_x1          # t2 = new_x1
            sw $t2, 0($t1)          # store new_x1 at curr_x1 address
            
            la $t1, curr_y1         # t1 = curr_y1 address
            lw $t2, new_y1          # t2 = new_y1
            sw $t2, 0($t1)          # store new_y1 at curr_y1 address
        
        j restore_capsule_half
        # jal update_capsule_location_half
        # j increment_capsule_loop_x
    
    restore_capsule:
    jal update_capsule_location
    j increment_capsule_loop_x
    
    restore_capsule_half:
    jal update_capsule_location_half
    j increment_capsule_loop_x
    
    increment_capsule_loop_x:
    addi $s0, $s0, 1
    # display for testing
    jal update_display
    ble $s0, 7, drop_capsule_loop_x

decrement_capsule_loop_y:
bge $s1, 1, drop_capsule_loop_y


exit_drop_capsule:
la $t9, capsuleID_count       # load capsuleID_count addresss
lw $t8, capsuleID_max        # load capsuleID_max number
sw $t8, 0($t9)              # store capsuleID_max to capsuleID_count

load_registers()
lw $ra, 0($sp)           # Load the saved value of $ra from the stack
addi $sp, $sp, 4         # Increase the stack pointer (free up space)  
# END OF DROP_CAPSULE

# START CHECK_OBJECT_COLLISION_HALF
# assumes that there is no wall collision (within walls)
# returns: v0 (boolean; 0 if there is no collision, 1 if there is a collision) 
# registers: t0 (game_array pointer), t1 (new_x1), t2 new_y1), t5 (game_array base address), t9 (value at game_array[x, y])
check_object_collision_half:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    store_registers()
    
    la $t5, game_array          # load game_array base address
    
    # assign t1-t4 to new_x, new_y data
    lw $t1, new_x1              # t1 = new_x1
    lw $t2, new_y1              # t2 = new_y1
    
    # game_array[new_x1, new_y1] is not empty
    add $a0, $t1, $zero                         # arg new_x1 for xy_to_array
    add $a1, $t2, $zero                         # arg new_y1 for xy_to_array
    jal xy_to_array             
    add $t0, $t5, $v0                           # t0 = game_array base address + offset (pointer)
    lw $t9, 0($t0)                              # load value at game_array[new_x1, new_y1]
    bne $t9, $zero, object_collision_half_true       # if there is value that is not 0 (black), jump to return true
    
    # Otherwise, we know there are no collisions so set return value = 0
    add $v0, $zero, $zero                       # return = 0 (no collision)
    j exit_check_object_half_collision                      
    
    object_collision_half_true:
    addi $v0, $zero, 1                          # return = 1 (collision)
            
    exit_check_object_half_collision:
    load_registers()
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    jr $ra
# END CHECK_OBJECT_COLLISION_HALF

# START CHECK_BOTTOM_COLLISION_HALF
# returns: v0 (boolean; 0 if there is no collision, 1 if there is a collision) 
# registers: t1 (curr_x1), t2 (curr_y1)
check_bottom_collision_half:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    store_registers()
    
    # assign t1-t4 to new_x, new_y data
    lw $t1, curr_x1              # t1 = curr_x1
    lw $t2, curr_y1              # t2 = curr_y1
    
    # new_y1 >= 15 (height of game_array)
    bge $t2, 15, bottom_collision_half_true          # if y1 >= 16, the pill hit the bottom
    
    # Otherwise, we know there are no collisions so set return value = 0
    add $v0, $zero, $zero
    j exit_check_bottom_collision_half                      # return = 0 (no collision)
        
    bottom_collision_half_true:
    addi $v0, $zero, 1                          # return = 1 (collision)
            
    exit_check_bottom_collision_half:
    load_registers()
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    jr $ra
# END CHECK_BOTTOM_COLLISION_HALF

# START CALCULATE_NEXT_XY_HALF
# function that calculates the next_x and next_y position and stores the new positions in memory
#       if the given key is one of w, a, s, d, write in a new_x and new_y
#       otherwise, the given key is n new_x and new_y are assigned to curr_x and curr_y, respectively

# note: all x and y's are in relation to the GAME ARRAY setup; no return, this function mutates
# inputs: a0 (the given key; it will be one of w, a, s, d, n)
# registers: t1 (curr_x1), t2 (curr_x2), t3 (new_x1 address), t4 (new_x2 address), t5 (curr_y1), t6 (curr_y2), t7 (new_y1 address), t8 (new_y2 address) 
calculate_new_xy_drop_half:
    store_registers()
    
    lw $t1, curr_x1             # t1 = curr_x1
    la $t3, new_x1              # t3 = new_x1 address
    lw $t5, curr_y1             # t5 = curr_y1
    la $t7, new_y1              # t7 = new_y1 address
    
    # to ensure proper calculations, set new_x, new_y as curr_x, curr_y 
    sw $t1, 0($t3)              # set new_x1 = curr_x1
    sw $t5, 0($t7)              # set new_y1 = curr_y1

    # shift the half, one unit down
    addi $t5, $t5, 1           # add one from curr_y1, curr_y2 to shift down
    sw $t5, 0($t7)              # store curr_y1 + 1 at new_y1 address
    
    load_registers()
    jr $ra
# END CALCULATE_NEXT_XY_HALF

# START OF UPDATE_CAPSULE_LOCATION_HALF
# function that stores the capsule location into their respective positions in the game_array 
# registers: t0 (game_array pointer), t1 (x), t2 (y), t4 (capsuleID address), t5 (game array address), 
#            t8 (capsuleID_array pointer), t9 (temp colour), a0 (arg x for xy_to_array), a1 (arg y for xy_to_array)
update_capsule_location_half: 
    la $t5, game_array
    la $t4, capsuleID_array
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    # set value at curr_x1 and curr_y1
        add $t0, $t5, $zero     # t0 = game_array pointer
        
        lw $t1 curr_x1          # t1 = curr_x1
        lw $t2 curr_y1          # t2 = curr_y1
        
        add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        jal xy_to_array         
        
        add $t0, $t0, $v0       # t0 = game_array pointer + offset
        lw $t9, colour_1        # load the first colour into t9
        sw $t9, 0($t0)          # set value at game_array[offset/4] to colour_1
        
        add $t8, $t4, $zero     # t8 = capsuleID_array pointer
        add $t8, $t8, $v0       # t8 = capsuleID_array pointer + offset
        lw $t9, capsuleID_count # load the current capsule count into t9
        sw $t9, 0($t8)          # set value at capsuleID_array pointer to capsuleID count
        
        lw $ra, 0($sp)           # Load the saved value of $ra from the stack
        addi $sp, $sp, 4         # Increase the stack pointer (free up space)
        jr $ra
# END OF UPDATE_CAPSULE_LOCATION_HALF

exit: