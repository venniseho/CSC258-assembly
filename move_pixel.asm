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
game_array:         .word 0:128

.text

# registers used: t0 (bitmap pointer), t7 (ASCII key value of key pressed), t8 (value at keyboard_address --> 0 or 1), t9(keyboard_address)
lw $t0, display_address
lw $t1, black
lw $t2, red
sw $t2, 0($t0)
lw $t9, keyboard_address        # $t0 = base keyboard address

top:
lw $t8, 0($t9)
beq $t8, 1, keyboard_input      # if $t9 == 1: key was pressed (ASCII key value found in next value in memory)
j top

# IF A KEY WAS PRESSED, GET ITS ASCII VALUE
keyboard_input:
lw $t7, 4($t9)                 # $t7 = ASCII key value 

beq $t7, 0x61, respond_to_a     # a was pressed
beq $t7, 0x64, respond_to_d     # d was pressed
beq $t7, 0x77, respond_to_w     # w was pressed
beq $t7, 0x73, respond_to_s     # s was pressed
j top
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
# sw $t2, 0($t1)
j top

jal generate_pill
j exit

# FUNCTION THAT GENERATES A RANDOM BI-COLOURED PILL AND DRAWS IT AT THE TOP OF THE BOTTLE
generate_pill: 
    lw $t0, display_address      # load displayAddress into $t0 (= bitmap pointer)
    addi $t0, $t0, 2108         # point bitmap pointer to top of bottle
    
    jal generate_colour         # generate the left half of the pill and init at top of bottle
    add $t1, $v0, $zero
    sw $t1, 0($t0)
    
    jal generate_colour         # generate the right half of the pill and init at top of bottle
    add $t1, $v0, $zero
    sw $t1, 4($t0)
    
    jr $ra
    # END GENERATE_PILL
    
    # FUNCTION THAT GENERATES A RANDOM COLOUR (red, yellow, blue)
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
