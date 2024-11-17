############################## Calculate New XY ###############################
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

# START CALCULATE_NEW_XY
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
        beq $t5, $t6, horizontal_to_vertical
        beq $t1, $t2, vertical_to_horizontal
        
        horizontal_to_vertical:
            addi, $t6, $t6, 1           # curr_y2 + 1
            sw $t8, 0($t6)              # store curr_y2 + 1 at new_y2 address
            sw $t1, 0($t4)              # store curr_x1 at new_x2 address
        j exit_calculate_next_xy
        
        vertical_to_horizontal:
            addi, $t2, $t2, -1          # curr_x2 - 1
            sw $t4, 0($t2)              # store curr_x2 - 1 at new_x2 address
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
# END CALCULATE_NEW_XY