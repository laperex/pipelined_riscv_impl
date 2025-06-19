.align 2

.equ UART_REG_TXFIFO, 0
.equ UART_BASE, 0x10013000

.global _start


.section .text

_start:
	csrr t0, mhartid
	bnez t0, halt
	
	la sp, stack_top
	la a0, msg
	jal puts

puts:
	li t0, UART_BASE

.puts_loop:
	# lbu rd, offset(mem_address)
	lbu t1, (a0)	# load byte unsigned from a0 			
	beqz t1, .pust_leave	# branch if equal to zero

	lw t2, UART_REG_TXFIFO(t0)	# load word
	bltz t2, .puts_wait		# branch if less than zero
	
	sw t1, UART_REG_TXFIFO(t0)
	
	add a0, a0, 1	# a0 += 1
	j .puts_loop

.pust_leave:
	ret

halt: j halt


.section .rodata

msg:
	.string "Hello World!\n"
