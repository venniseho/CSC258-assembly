################################ Draw Bottle #################################
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
# FUNCTION THAT DRAWS THE BOTTLE
# registers used: t0 (bitmap pointer), t1 (counter for x/y), t2 (bound for counter - t1), t9 (the colour white)
draw_bottle:
    lw $t0, displayAddress           # load displayAddress into $t0 (= bitmap pointer)
    addi $t0, $t0, 1716              # shift the bitmap pointer ($t0) to the start of the bottle (top left unit) (13, 13) --> 13*4*32 + 13*4
    
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
    addi $t2, $zero, 14         # $t2 = height of the sides (excluding top and bottom)    
    
    # START OF BOTTLE SIDES #
    bottle_body_side:
    addi $t0, $t0, 92               # shift to next row of the bottle body
    sw $t9, 0($t0)                  # left side
    addi $t0, $t0, 36
    sw $t9, 0($t0)                  # right side
    addi, $t1, $t1, 1
    bne $t1, $t2, bottle_body_side  # loop 14 times
    
    add $t1, $zero, $zero       # reassign $t1 = counter for x
    addi $t2, $zero, 10         # $t2 = width of bottom
    addi $t0, $t0, 92           # shift to last row
    # END OF BOTTLE SIDES #
    
    # START OF BOTTOM OF BOTTLE # 
    bottle_bottom:
    sw $t9, 0($t0)                  
    addi, $t0, $t0, 4
    addi, $t1, $t1, 1
    bne $t1, $t2, bottle_bottom
    # END OF BOTTOM OF BOTTLE # 
    # jr $ra 
# END DRAW_BOTTLE

# lw $t0, displayAddress      # load displayAddress into $t0 (= bitmap pointer)
# addi $t0, $t0, 3968  
# addi $t1, $zero, 8
# add $t2, $zero, $zero
# lw $t9, red
# lw $t8, yellow
# lw $t7, blue
# lw $t6, white 

# line:
# sw $t9, 0($t0)      
# addi $t0, $t0, 4
# sw $t8, 0($t0)      
# addi $t0, $t0, 4
# sw $t7, 0($t0)      
# addi $t0, $t0, 4
# sw $t6, 0($t0)      
# addi $t0, $t0, 4
# addi $t2, $t2, 1
# bne $t1, $t2, line