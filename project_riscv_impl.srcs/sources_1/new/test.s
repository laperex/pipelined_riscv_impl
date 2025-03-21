.global _start

.equ PORT_OUT_A, 0xffffff00
.equ PORT_OUT_B, 0xffffff10
.equ PORT_OUT_C, 0xffffff20
.equ PORT_OUT_D, 0xffffff30

.section .data
	# var2:   .half 5       # 16-bit integer (2 bytes)
	# var3:   .byte 3       # 8-bit integer (1 byte)
	# str1:   .asciz "Hello, RISC-V"  # Null-terminated string

.section .text

_start:
	# li t1, 0
	li t2, 1

# 	# li t2, 1

# _loop:
# 	mv t3, t1
# 	mv t1, t2
# 	add t2, t2, t3
	
	la t1, PORT_OUT_A
	sw t2, 0(t1)

	# lw a1, 0x40000000
	# lw t1, 0(a1)

var1:   .word 10      # 32-bit integer (4 bytes)

_loop:
	j _loop

