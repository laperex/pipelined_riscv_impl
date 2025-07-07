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

# SAMPLE CODE FOR FIBONACCI

# Output visibile in t1 register


_start:
	nop
	li t4, 100
	li t5, 60
	
	la t0, var1
	sw t5, 0(t0)
	
	li t1, 0
	li t2, 1
	
	lw t6, 0(t0)
	
	mv t4, t6
	
_loop:
	li t4, 101

	mv t3, t1
	mv t1, t2
	add t2, t1, t3

	blt t2, t5, _loop

	li t4, 105
	li t6, 1

var1:   .word 10      # 32-bit integer (4 bytes)