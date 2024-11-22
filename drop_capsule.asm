############################### drop capsule #################################
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
new_x1:                 .word 0             # current x of half 1
new_y1:                 .word 0             # current y of half 1
colour_1:               .word 0             # current colour of half 1
id_1:                   .word 0             # id number of the half 1

curr_x2:                .word 0             # current x of half 2
curr_y2:                .word 0             # current y of half 2
new_x2:                 .word 0             # current x of half 2
new_y2:                 .word 0             # current y of half 2
colour_2:               .word 0             # current colour of half 2
id_2:                   .word 0             # id number of the half 2

capsuleID_count:        .word 0             # increases each time a capsule is added to the board

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
	
# START OF DROP_CAPSULE
# function to drop each capsule
# registers: all of them... this function is too confusing to name all the registers I used and their function
# saved registers: s0 (x loop count), s1 (y loop count), s6 (capsuleID_array address), s7 (game_array address)
drop_capsule:
subi $sp, $sp, 4
sw $ra, 0($sp)
store_registers()

la $s7, game_array
la $s6, capsuleID_array

addi $s1, $zero, 15         # initialise y count (starts from second last row, last row = 15)
add $s0, $zero, $zero       # initialise x count

drop_capsule_loop_y:
addi $s1, $s1, -1
add $s0, $zero, $zero       # reset x count (column) when we reach a new y count (row) 

drop_capsule_loop_x:
addi $s0, $s0, 1
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
    
    la $t1, colour_1
    lw $t2, black
    sw $t2, 0($t1)

    # check if current xy contains a capsule
    add $a0, $zero, $s0     # x value arg for xy_to_array
    add $a1, $zero, $s1     # y value arg for xy_to_array
    jal xy_to_array
    add $t9, $s7, $v0       # game_array pointer = base address + offset
    add $t8, $s6, $v0       # capsuleID_array pointer = base address + offset
    
    lw $t7, 0($t9)                              # value at game_array pointer
    lw $t6, 0($t8)                              # value at capsuleID_array pointer (current unit's capsuleID)
    beq $t7, 0, decrement_capsule_loop_y        # if the value at the game_array pointer is black, go to next loop
    
    # otherwise, the current unit is not black, reconstruct the capsule
    la $t1, curr_x1         # store loop x, y at curr_x1, curr_y1
    la $t2, curr_y1
    sw $s0, 0($t1)
    sw $s1, 0($t2)
    
    la $t1, colour_1        # store the colour at the pixel at colour_1
    sw $t7, 0($t1)    
    
    # Find the other half of the capsule
    beq $s0, 0, skip_check_left         # if x loop value == 0, there is no left column
    addi $t0, $s6, 4                    # check right in capsuleID_array
    lw $t1, 0($t0)                      # load value from capsuleID_array
    beq $t1, $t6, capsule_to_right      # the capsule half to the right matches the capsule ID
    
    skip_check_left:
    beq $s0, 8, skip_check_right        # if x loop value == 0, there is no right column
    addi $t0, $s6, -4                   # check right in capsuleID_array
    lw $t1, 0($t0)                      # load value from capsuleID_array
    beq $t1, $t6, capsule_to_left       # the capsule half to the left matches the capsule ID
    
    skip_check_right:
    beq $s1, 0, drop_capsule_action     # if y loop value == 0, there is no row above
    addi $t0, $s6, -32                  # check top in capsuleID_array
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
    sw $s0, 0($t1)
    sw $t3, 0($t2)
    
    la $t1, colour_2        # store the colour at the pixel at colour_1
    lw $t7, 4($t9)          # value at game_array pointer + 4 (one unit right)
    sw $t7, 0($t1)    
    j drop_capsule_action
    
    capsule_to_left:
    la $t1, curr_x2         # store loop x + 1, y at curr_x2, curr_y2
    la $t2, curr_y2
    addi $t3, $s0, -1       # t3 = x - 1
    sw $s0, 0($t1)
    sw $t3, 0($t2)
    
    la $t1, colour_2        # store the colour at the pixel at colour_1
    lw $t7, -4($t9)         # value at game_array pointer - 4 (one unit left)
    sw $t7, 0($t1)   
    j drop_capsule_action
    
    drop_capsule_action:
    lw $t1, colour_1
    lw $t2, colour_2
    
    beq $t1, 0, decrement_capsule_loop_y        # colour 1 is black
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
            beq $v0, 1, decrement_capsule_loop_y                # returns 1 if collision
            
            # otherwise, the pill did not hit a wall
            jal check_object_collision                          # checks if the pill hit an object
            beq $v0, 1, decrement_capsule_loop_y                # returns 1 if collision
            
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
        
        j decrement_capsule_loop_y
    
    move_half_capsule:
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
        
        check_down_collision_drop_half:
            jal check_bottom_collision_half          # checks if the pill hit the bottom of the walls
            beq $v0, 1, decrement_capsule_loop_y                # returns 1 if collision
            
            # otherwise, the pill did not hit a wall
            jal check_object_collision_half                          # checks if the pill hit an object
            beq $v0, 1, decrement_capsule_loop_y                # returns 1 if collision
            
            # otherwise, we can move the pill to the new position
            # update curr_x, curr_y = new_x, new_y
            la $t1, curr_x1         # t1 = curr_x1 address
            lw $t2, new_x1          # t2 = new_x1
            sw $t2, 0($t1)          # store new_x1 at curr_x1 address
            
            la $t1, curr_y1         # t1 = curr_y1 address
            lw $t2, new_y1          # t2 = new_y1
            sw $t2, 0($t1)          # store new_y1 at curr_y1 address
        
        j decrement_capsule_loop_y
    
    increment_capsule_loop_x:
    ble $s0, 8, drop_capsule_loop_x

decrement_capsule_loop_y:
ble $s1, 0, drop_capsule_loop_y

exit_drop_capsule:
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

