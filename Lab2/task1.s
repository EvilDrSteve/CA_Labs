.text
.globl main
main:
	beq x0, x0, Listing2

Listing2:
	#Dummy values
	addi x19, x0, 1 #f
	addi x20, x0, 2 #g
	addi x21, x0, 3 #h
	addi x22, x0, 4 #i
	addi x23, x0, 5 #j

	bne x22, x23, Else
	add x19, x20, x21
	beq, x0, x0, Exit
	Else:
		sub x19, x20, x21
	Exit:
		beq x0, x0, end

Listing3:
    # Dummy values for while loop
    # k = 2, save[] = [2, 2, 4, 2] at address 0x200
    # Loop continues while save[i] == k, exits when save[i] != k
    
    addi x22, x0, 0         # i = 0 (loop counter)
    addi x24, x0, 2         # k = 2 (value to compare)
    li x25, 0x200           # x25 = base address of save array
    
    # Initialize save array in memory
    addi t0, x0, 2          # t0 = 2
    sw t0, 0(x25)           # save[0] = 2
    sw t0, 4(x25)           # save[1] = 2
    addi t0, x0, 4          # t0 = 4
    sw t0, 8(x25)           # save[2] = 4
    addi t0, x0, 2          # t0 = 2
    sw t0, 12(x25)          # save[3] = 2

	Loop: 
		slli x10, x22, 2
		add x10, x10, x25
		lw x9, 0(x10)
		bne x9, x24, Exit1
		addi x22, x22, 1
		beq x0, x0, Loop
	Exit1:
		beq x0, x0, end
end:
	j end


	
# 0000000 10111 10110 001 01100 1100011 #BNE
# #Branch 1100011
# #Offset address = 00000000001100 = 12 which is 3 lines, so it jumps to "else" label
# #funct3 = 1 which is ne1
# #rs1 = 10110 = 22 which is x22
# #rs2 = 10111 = 23 which is x23

# 0000000 00000 00000 000 01000 1100011 #BEQ
# #Branch 1100011
# #Offset address = 0000000001000 = 8 which is 2 lines, so it jumps to "exit" label
# #funct3 = 0 which is eq
# #rs1 = 00000 = 0 which is x0
# #rs1 = 00000 = 0 which is x0


# 0000000 11000 01001 001 01100 1100011 #BNE
# #Branch 1100011
# #Offset address = 0000000001100 = 12 which is 3 lines, so it jumps to "Exit" label
# # funct3 = 001 = 1 which is 
# #rs1 = 01001 = 9 which is x9
# #rs2 = 11000 = 24 which is x24

# 1111111 00000 00000 000 01101 1100011 #BEQ
# #Branch 1100011
# #Offset address = 1111111101100 = -20 which is -5 lines, so it jumps to "Loop" label
# #funct3 = 000 = 0 which is eq
# #rs1 = 00000 = 0 which is x0
# #rs2 = 00000 = 0 which ix x0


# # in both cases the BEQ and BNE have different funct3 codes, 000 for BEQ and 001 for BNE
# # The offset is calculated by concatenating bits 7:11 and 25:31, this gives us the jump value in bytes

