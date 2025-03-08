.global _start

.section .text

_start:
	# j _e
	li t2, 1  # load the immediate 0x140 (address) into register t6

	addi t1, t1, 1

_stop:
	j _stop

	# t1 = x50
	
	# j _m
	# li t6, 0xf20  # load the immediate 0x140 (address) into register t6
	# # nop
	# # nop

	# # t1 = 20
	# # t6 = 10

	# # li t1, 150

	# sw t1, 0(t1) # store the word in t0 to memory address in t6 with 0 byte offset
	# sw t6, 0(t6) # store the word in t0 to memory address in t6 with 0 byte offset
	# li t1, 100

	# lw t2, 0(t6)
	# # t2 = 0x2
	# lw t3, 0(t1)

# _e:
# 	# nop
# 	li t3, 255
# # 	li t4, 101
	
# 	jal t2, _h

# _m:
# 	li t5, 100
	# la t4, _e

	# j _e

	# # sw t1, 0(t6) # store the word in t0 to memory address in t6 with 0 byte offset

	# addi t1, t2, 0x55
	# li a0, 2
	# li a7, 93

	# ecall
