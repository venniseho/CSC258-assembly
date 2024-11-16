################################ Move Pill #################################
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

left_init_position:     .word 2236

game_array:         .word 0:128

.text

lw $t0, display_address
lw $t1, black

# lw $t2, red
# sw $t2, 0($t0)

jal generate_pill
lw $t2, left_init_position
addi $t3, $t2, 4

add $a0, $t2, $zero
add $a1, $t3, $zero
top:
    jal check_key_press
j top

# FUNCTION THAT CHECKS THE KEY_PRESS (IF PRESSED, INITIATES CORRESPONDING ACTION AND UPDATES ARRAY. OTHERWISE, JUMPS BACK OUTSIDE)
# inputs: $a0 (left half of pill location), $a1 (right half of pill location)
# returns: $v0 (new left half of pill location), $v1 (new right half of pill location)
# registers: t0 (bitmap pointer for left half), t1 (bitmap pointer for right half), t3 (left colour), t4 (right colour)
#            t7 (ASCII key value of key pressed), t8 (value at keyboard_address --> 0 or 1), t9(keyboard_address
check_key_press:
    lw $t9, keyboard_address        # $t9 = base keyboard address
    lw $t8, 0($t9)                  # $t8 = value at keyboard address
    beq $t8, 1, keyboard_input      # if $t9 == 1: key was pressed (ASCII key value found in next value in memory)
    jr $ra
    
# IF A KEY WAS PRESSED, GET ITS ASCII VALUE
keyboard_input:
    lw $t7, 4($t9)                  # $t7 = ASCII key value 
    
    add $t0, $a0, $zero             # init $t0 = bitmap pointer for left half
    add $t1, $a1, $zero             # init $t1 = bitmap pointer for right half
    add $t3, 
    
    beq $t7, 0x61, respond_to_a     # a was pressed
    beq $t7, 0x64, respond_to_d     # d was pressed
    beq $t7, 0x77, respond_to_w     # w was pressed
    beq $t7, 0x73, respond_to_s     # s was pressed
    j check_key_press               # invalid key pressed

    # a: moves the pixel one unit to the left
    respond_to_a:
        sw $t1, 0($t0)
        addi $t0, $t0, -4
        sw $t2, 0($t0)
        j store
    
    # d: moves the pixel one unit to the right
    respond_to_d:
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
    j store
    
    # w: rotates 90 degrees clockwise
    respond_to_w:
    
    j store
    
    # s: moves the pixel one unit down
    respond_to_s:
        sw $t1, 0($t0)
        addi $t0, $t0, 128
        sw $t2, 0($t0)
    j store

store:

j check_key_press




# FUNCTION THAT GENERATES A RANDOM BI-COLOURED PILL AND DRAWS IT AT THE TOP OF THE BOTTLE
# registers: t0 (bitmap pointer), t5 (game_array address), v0 (return val from generate_colour)
generate_pill: 
    lw $t0, display_address     # load displayAddress into $t0 (= bitmap pointer)
    addi $t0, $t0, 2236         # point bitmap pointer to top of bottle
    
    la $t5, game_array          # t5 = address of game_array
    
    jal generate_colour         # generate the left half of the pill and init at top of bottle
    sw $v0, 0($t0)              
    sw $v0, 12($t5)             # add colour of left half of pill to game_array[3] 
    
    jal generate_colour         # generate the right half of the pill and init at top of bottle
    sw $v0, 4($t0)
    sw $v0, 16($t5)             # add colour of right half of pill to game_array[4]
    
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
