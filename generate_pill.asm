################################ Generate Pill #################################
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
.data
displayAddress: .word 0x10008000

red:            .word 0xff0000
yellow:         .word 0xffff00
blue:           .word 0x00ffff
white:          .word 0xffffff

init_x1:     .word 3
init_y1:     .word 0
init_x2:     .word 4
init_y2:     .word 0

game_array:     .word 0:128

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
jal generate_pill
j exit

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

exit: