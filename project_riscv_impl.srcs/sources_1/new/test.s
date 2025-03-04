.global _start

.section .text

_start:
	li t1, 0x20  # load the immediate 0x140 (address) into register t6
	li t6, 0x00  # load the immediate 0x140 (address) into register t6

	# nop
	# nop
	
	# t1 = 20
	# t6 = 10

	sw t1, 0(t6)  # store the word in t0 to memory address in t6 with 0 byte offset
	# lw t1, 0(t6)
	# # sw t1, 0(t6)  # store the word in t0 to memory address in t6 with 0 byte offset

	# addi t1, t2, 0x55
	# li a0, 2
	# li a7, 93

	ecall
