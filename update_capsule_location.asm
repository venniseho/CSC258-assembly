############################## Update Capsule Location ###############################
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
.data
display_address:     .word 0x10008000
keyboard_address:    .word 0xffff0000

red:                .word 0xff0000
yellow:             .word 0xffff00
blue:               .word 0x00ffff
white:              .word 0xffffff
black:              .word 0x000000

n:                  .word 0x6e

left_init_position:     .word 2236

game_array:         .word 0:128

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

.text

# START OF UPDATE_LOCATION
# function that stores new_x and new_y into their respective positions in the game_array and removes them from their previous location (curr_x, curr_y)
# registers: t0 (game_array pointer), t1 (x), t2 (y), t5 (game array address), t9 (temp colour), a0 (arg x for xy_to_array), a1 (arg y for xy_to_array)
update_capsule_location: 
    la $t5, game_array
    
    # remove value at curr_x1 and curr_y1
        add $t0, $t5, $zero     # t0 = game_array pointer
        
        lw $t1 curr_x1          # t1 = curr_x1
        lw $t2 curr_y1          # t2 = curr_y1
        
        add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        jal xy_to_array         
        add $t0, $t0, $v0       # t0 = game_array pointer + offset
        
        lw $t9, black           # load the colour black into t9
        sw $t9, 0($t0)          # set value at game_array[offset/4] to black (0)
    
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
    
    # remove value at curr_x2 and curr_y2
        add $t0, $t5, $zero     # t0 = game_array pointer
        
        lw $t1 curr_x2          # t1 = curr_x2
        lw $t2 curr_y2          # t2 = curr_y2
        
        add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        jal xy_to_array         
        add $t0, $t0, $v0       # t0 = game_array pointer + offset
        
        lw $t9, black           # load the colour black into t9
        sw $t9, 0($t0)          # set value at game_array[offset/4] to black (0)
    
    # set value at new_x1 and new_y1
        add $t0, $t5, $zero     # t0 = game_array pointer
        
        lw $t1 new_x2          # t1 = new_x2
        lw $t2 new_y2          # t2 = new_y2
        
        add $a0, $t1, $zero     # a0 = x arg for xy_to_array
        add $a1, $t2, $zero     # a1 = y arg for xy_to_array
        jal xy_to_array         
        add $t0, $t0, $v0       # t0 = game_array pointer + offset
        
        lw $t9, colour_2        # load the first colour into t9
        sw $t9, 0($t0)          # set value at game_array[offset/4] to colour_2
# END OF UPDATE_LOCATION

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
    

