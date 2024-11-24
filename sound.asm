################# Sound ###################
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
enter:      .word 0xa

init_x1:     .word 3
init_y1:     .word 0
init_x2:     .word 4
init_y2:     .word 0

game_board_offset:     .word 1968
##############################################################################
# Mutable Data
##############################################################################
game_array:             .word 0:128         # array containing the game
capsuleID_array:        .word 0:128         # array containing the capsuleIDs

curr_x1:                .word 0             # current x of half 1
curr_y1:                .word 0             # current y of half 1
curr_x2:                .word 0             # current x of half 2
curr_y2:                .word 0             # current y of half 2

new_x1:                 .word 0             # current x of half 1
new_y1:                 .word 0             # current y of half 1
new_x2:                 .word 0             # current x of half 2
new_y2:                 .word 0             # current y of half 2

colour_1:               .word 0             # current colour of half 1
colour_2:               .word 0             # current colour of half 2

capsuleID_count:        .word 0             # increases each time a capsule is added to the board
capsuleID_max:          .word 0             # only used in drop to save the current capsuleID_count

current_mode:           .word 0             # used to set the mode to easy, medium, or hard
current_screen:         .word 0             # 0 = mode_screen, 1 = game_screen, 2 = game_over_screen

virus_number:           .word 0
game_speed:             .word 0 

##############################################################################
# Code
##############################################################################
.macro store_registers() 
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t9, 0($sp)              # Store the value of $t9 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t8, 0($sp)              # Store the value of $t8 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t7, 0($sp)              # Store the value of $t7 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t6, 0($sp)              # Store the value of $t6 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t5, 0($sp)              # Store the value of $t5 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t4, 0($sp)              # Store the value of $t4 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t3, 0($sp)              # Store the value of $t3 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t2, 0($sp)              # Store the value of $t2 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t1, 0($sp)              # Store the value of $t1 at the top of the stack
    
    subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $t0, 0($sp)              # Store the value of $t0 at the top of the stack
.end_macro

.macro load_registers() 
    lw $t0, 0($sp)           # Load the saved value of $t0 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t1, 0($sp)           # Load the saved value of $t1 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t2, 0($sp)           # Load the saved value of $t2 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t3, 0($sp)           # Load the saved value of $t3 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t4, 0($sp)           # Load the saved value of $t4 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t5, 0($sp)           # Load the saved value of $t5 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t6, 0($sp)           # Load the saved value of $t6 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t7, 0($sp)           # Load the saved value of $t7 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t8, 0($sp)           # Load the saved value of $t8 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
    
    lw $t9, 0($sp)           # Load the saved value of $t9 from the stack
    addi $sp, $sp, 4         # Increase the stack pointer (free up space)
.end_macro	
	
	.text
	# jal shift_sound
	# jal rotate_sound
	# jal collide_sound
	# jal merge_sound
	# jal lose_sound
	# jal win_sound
    j exit
	
	

# START SHIFT_SOUND
shift_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
	
	li $v0, 31
    li $a0, 75 # pitch
    li $a1, 250 # duration
    li $a2, 115 # instrument
    li $a3, 100 # volume
    syscall
	
	exit_click_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    jr $ra
# END SHIFT_SOUND

# START ROTATE_SOUND
rotate_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
	
	li $v0, 31
    li $a0, 80 # pitch
    li $a1, 250 # duration
    li $a2, 118 # instrument
    li $a3, 100 # volume
    syscall
	
	exit_rotate_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    jr $ra
# END rotate_SOUND

# START COLLIDE_SOUND
collide_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
	
	li $v0, 31
    li $a0, 25 # pitch
    li $a1, 250 # duration
    li $a2, 115 # instrument
    li $a3, 100 # volume
    syscall
	
	exit_collide_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    jr $ra
# END COLLIDE_SOUND

# START MERGE_SOUND
merge_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
	
	li $v0, 31
    li $a0, 82 # pitch
    li $a1, 300 # duration
    li $a2, 10 # instrument
    li $a3, 100 # volume
    syscall
	
	exit_merge_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    jr $ra
# END CLICK_SOUND

# START LOSE_SOUND
lose_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
	
	li $t1, 74

    li $v0, 31
    add $a0, $t1, $zero # pitch
    li $a1, 500 # duration
    li $a2, 57 # instrument
    li $a3, 100 # volume
    syscall
    
    li $v0, 32
	li $a0, 1200
	syscall
	
	addi $t1, $t1, -1
	
	li $v0, 31
    add $a0, $t1, $zero # pitch
    li $a1, 400 # duration
    li $a2, 57 # instrument
    li $a3, 100 # volume
    syscall
    
    li $v0, 32
	li $a0, 500
	syscall
	
	addi $t1, $t1, -1
	
	li $v0, 31
    add $a0, $t1, $zero # pitch
    li $a1, 400 # duration
    li $a2, 57 # instrument
    li $a3, 100 # volume
    syscall
    
    li $v0, 32
	li $a0, 500
	syscall
	
	addi $t1, $t1, -1
	
	li $v0, 31
    add $a0, $t1, $zero # pitch
    li $a1, 400 # duration
    li $a2, 57 # instrument
    li $a3, 100 # volume
    syscall
	
	exit_lose_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    jr $ra
# END LOSE_SOUND

# START LOSE_SOUND
win_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
	
	li $t1, 80
	
	li $v0, 31
    add $a0, $t1, $zero # pitch
    li $a1, 500 # duration
    li $a2, 10 # instrument
    li $a3, 100 # volume
    syscall
    
    li $v0, 32
	li $a0, 1200
	syscall
	
	addi $t1, $t1, 4
	
	li $v0, 31
    add $a0, $t1, $zero # pitch
    li $a1, 400 # duration
    li $a2, 10 # instrument
    li $a3, 100 # volume
    syscall
    
    li $v0, 32
	li $a0, 500
	syscall
	
	addi $t1, $t1, 3
	
	li $v0, 31
    add $a0, $t1, $zero # pitch
    li $a1, 400 # duration
    li $a2, 10 # instrument
    li $a3, 100 # volume
    syscall
    
    li $v0, 32
	li $a0, 500
	syscall
	
	addi $t1, $t1, 5
	
	li $v0, 31
    add $a0, $t1, $zero # pitch
    li $a1, 400 # duration
    li $a2, 10 # instrument
    li $a3, 100 # volume
    syscall
	
	exit_win_sound:
	subi $sp, $sp, 4            # Decrease stack pointer (make space for a word)
    sw $ra, 0($sp)              # Store the value of $ra at the top of the stack
    jr $ra
# END LOSE_SOUND
	
exit: