################################ Generate Colour #################################
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

.text
jal generate_colour
add $t1, $v0, $zero
lw $t0, displayAddress      # Load base display address into $t0
sw $t1, 0($t0)         # Store the selected color at the display address
j exit

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

exit: