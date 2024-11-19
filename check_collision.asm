############################## CHECK COLLISION ###############################
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
# END CHECK_WALL_COLLISION


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
# registers: t1 (curr_x1), t2 (curr_y1), t3 (curr_x2), t4 (curr_y2)
check_bottom_collision:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
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
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    jr $ra
# END CHECK_BOTTOM_COLLISION

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
