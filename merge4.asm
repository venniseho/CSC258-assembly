############################## merge 4 ###############################
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

# START OF MERGE_ROW
# returns: v0 (game_array offset of the start of 4 same colours in a row or 0 if there are none)
# registers: t0 (game_array pointer), t1 (y/row count), t2 (loop unit count), t3 (max units in a row count; from call the check_merge_row), 
#            t5 (game_array address), t9 (the colour black)
merge_row:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    
    lw $t9, black
    
    # loop that checks each row to see if we there are at least 4 in a row, and merges if so. (starts from bottom)
    addi $t1, $zero, 15         # initialise the row count (starts from bottom, last row = 15)
    
    merge_row_loop:
        # call to check_merge_row of the current row to find out if a merge is needed. 
        add $a0, $t1, $zero                     # arg to check_merge_row; current y/row value
        jal check_merge_row
        
        add $t0, $t5, $v0                       # set the game_array pointer to the base address + returned offset of the last of the same colour units (-1 = no units to merge)
        add $t3, $zero, $v1                     # t3 = v1 = the number of units to merge (0 or a value >=4) 
        
        beq $t3, $zero, decrement_merge_row_loop        # if the number of units to merge is zero, go on to the next loop (check the next row)
        
        # otherwise, the number of units to merge >= 4
        # loop that changes all units in a row of the same colour to black
        add $t2, $zero, $zero                   # set the loop unit count to 0
        
        merge_units_loop:
            sw $t9, 0($t0)                          # sets the value at game_array pointer to black
            addi $t0, $t0, -4                       # decreases the game_array pointer by 4 because it was initialised at the last of the same colour units
            addi $t2, $t2, 1                        # increment the loop counter by 1
            bne $t2, $t3, merge_units_loop          # loops until the loop counter = the number of units to merge
        ############## CALL MERGE ALL CAPSULES DOWN #############################################################################################
        j merge_row_loop                            # jump to start of merge_row_loop to check the current row again for any more same colours
        
        decrement_merge_row_loop:
            addi $t1, $t1, -1                       # decrease the row number by 1
            blt $t1, 0, merge_row_loop              # loops until it hits the top row of the game

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
    lw $t5, game_array          # load the game array base address into t5
    
    # need to add 32 y times
    add $t0, $t5, $zero         # initialise the game pointer
    add $t2, $zero, $zero       # initialise the loop counter
    
    # loop that adds 32 (8 units per row x 4 bits per unit) y times to set game_array offset
    loop_to_y:
    addi $t0, $t0, 32           # add 32 each loop (bits per row)
    addi $t2, $t2, 1            # increment the loop counter
    bne $t2, $a0, loop_to_y     # loop until loop counter = y rows
    
    # loop that checks the row for 4 consecutive values of the same colour
    add $t1, $zero, $zero       # initialise the colour count
    lw $t7, black               # initialise the current colour
    add $t2, $zero, $zero       # reset the loop counter
    
    check_merge_row_loop:
        lw $t8, 0($t0)              # load the colour at the game array index into t8
        
        beq $t8, $t9, increment_check_merge_row_loop      # if t8 is black, go to next loop
        beq $t7, $t8, check_merge_row_loop_equals   # if the current colour and next colour are equal, jump to that condition
        
        # otherwise, we know that the next colour is different from the current colour (and is not black)
        bge $t1, 4, return_merge_row_positive       # if the colour count >= 4, jump to return
        
        add $t7, $t8, $zero                         # set current colour = next colour
        add $t1, $zero, $zero                       # reset the colour count
        j increment_check_merge_row_loop
        
        # we know that the current colour and next colour are equal. increment the colour count by 1 and check for 4 in a row.
        check_merge_row_loop_equals:
            addi $t1, $t1, 1                            # increment the current colour count by 1
            j increment_check_merge_row_loop
        
        increment_check_merge_row_loop:
            addi $t2, $t2, 1                            # increase the loop counter by 1
            addi $t0, $t0, 4                            # add 4 to the game_array offset to check the next value
            blt $t2, 8, check_merge_row_loop            # jump to next loop if $t2 is less than 8
    
    bge $t1, 4, return_merge_row_positive
    
    # there are no four consecutive same colours
    return_merge_row_loop_negative:
    addi $v0, $zero, -1                       # return -1 as game_array offset to indicate no merge
    add $v1, $zero, $zero                     # return zero as number of units to merge  
    j exit_check_merge_row
    
    # there are four consecutive same colours
    return_merge_row_positive:
    add $t0, $t0, $t5                           # the game_array offset (last value)
    add $v0, $t0, $zero                         # returns the game_array offset
    add $v0, $t1, $zero                         # returns the number of units that are the same colour
    j exit_check_merge_row
    
    exit_check_merge_row:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF CHECK_MERGE_ROW





