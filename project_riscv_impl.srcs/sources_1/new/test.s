.global _start

.section .text

_start:
	li t2, 0x10  # load the immediate 0x140 (address) into register t6
	li t1, 0x40  # load the immediate 0x140 (address) into register t6
	add t1, t1, t2

	li t6, 0x02  # load the immediate 0x140 (address) into register t6
	# nop
	# nop

	# t1 = 20
	# t6 = 10

	li t1, 100

	# sw t2, 0(t1) # store the word in t0 to memory address in t6 with 0 byte offset
	sw t1, 0(t6) # store the word in t0 to memory address in t6 with 0 byte offset
	li t1, 100

	# lw t2, 0(t6)
	# # sw t1, 0(t6) # store the word in t0 to memory address in t6 with 0 byte offset

	# addi t1, t2, 0x55
	# li a0, 2
	# li a7, 93

	# ecall
