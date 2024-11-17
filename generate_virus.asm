################################ Generate Virus #################################
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

.text
add $a0, $a0, 4
jal generate_virus
jal update_display
jal draw_bottle
jal update_display
j exit

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
        
        # bne $t7, 0, display_pixel     # if not zero, convert array_to_bitmap. otherwise, continue without doing anything
        # j increment_display_loop_vars
        
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
        bne $t9, 127, update_display_loop       # loop 128 times
        
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

exit: