############################## merge 4 column ###############################
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
        
        beq $t6, $zero, decrement_merge_row_loop        # if the number of units to merge is zero, go on to the next loop (check the next column)
        
        # otherwise, the number of units to merge >= 4
        # loop that changes all units in a row of the same colour to black
        add $t4, $zero, $zero                   # set the loop unit count to 0
        
        merge_units_loop:
            addi $t4, $t4, 1                        # increment the loop counter by 1
            sw $t9, 0($t0)                          # sets the value at game_array pointer to black
            addi $t0, $t0, -32                       # decreases the game_array pointer by 32 (8 units per row * 4 bits per unit) because it was initialised at the last of the same colour units
            bne $t4, $t6, merge_units_loop          # loops until the loop counter = the number of units to merge
        ############## CALL MERGE ALL CAPSULES DOWN #############################################################################################
        j merge_column_loop                            # jump to start of merge_row_loop to check the current row again for any more same colours
        
        decrement_merge_row_loop:
            addi $t3, $t3, 1                           # increase the row number by 1
            ble $t3, 7, merge_column_loop              # loops until it hits the last column in the bottle (7)

exit_merge_row:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra

# START OF CHECK_MERGE_ROW
# inputs: a0 (y/row value)
# returns: v0 (game_array offset of the end of v1 same colours in a row or -1 if there are none), 
#          v1 (if there are >= 4 units of the same colour return that number; if there are < 4, return 0)
# registers: t0 (game_array pointer), t1 (colour count), t2 (x/column count), t5 (game_array address), t7 (current colour), t8 (next colour), t9 (the colour black)
check_merge_column:
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack

    lw $t9, black               # load the colour black into t9
    la $t5, game_array          # load the game array base address into t5
    
    # need to add 4 x times
    add $t0, $t5, $zero         # initialise the game_array pointer
    add $t2, $zero, $zero       # initialise the loop counter
    beq $t2, $a0, skip_loop_to_x
    
    # loop that adds 4 (4 bits per unit) x times to set game_array offset
    loop_to_x:
    addi $t0, $t0, 4            # add 32 each loop (bits per row)
    addi $t2, $t2, 1            # increment the loop counter
    bne $t2, $a0, loop_to_x     # loop until loop counter = x rows
    
    skip_loop_to_x:
    # loop that checks the row for consecutive values of the same colour
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
            addi $t0, $t0, 4                            # add 32 to the game_array offset to check the next value in the column
            blt $t2, 16, check_merge_column_loop            # jump to next loop if $t2 is less than 8
    
    bge $t1, 4, return_merge_column_positive
    
    # there are no four consecutive same colours
    return_merge_column_negative:
    addi $v0, $zero, -1                       # return -1 as game_array offset to indicate no merge
    add $v1, $zero, $zero                     # return zero as number of units to merge  
    j exit_check_merge_column
    
    # there are four consecutive same colours
    return_merge_column_positive:
    sub $t0, $t0, $t5                           # the game_array offset (last value)
    subi $t0, $t0, 4
    add $v0, $t0, $zero                         # returns the game_array offset
    add $v1, $t1, $zero                         # returns the number of units that are the same colour
    j exit_check_merge_column
    
    exit_check_merge_column:
    lw $ra, 0($sp)           # Load the saved value of $ra from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    jr $ra
# END OF CHECK_MERGE_COLUMN