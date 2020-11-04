# vi:set ft=asm:

# Disable compressed instructions (TODO: enable later)
.option norvc

.section .data
.section .text.init

.global _start
_start:

.option push
.option norelax
	la gp, _global_pointer
.option pop

	csrr t0, mhartid
	bnez t0, 4f

	csrw satp, zero
	
	# Zero out BSS section
	la a0, _bss_start
	la a1, _bss_stop
	bgeu a0, a1, 2f
1:
	sd zero, (a0)
	addi a0, a0, 8
	bltu a0, a1, 1b
2:
	la sp, _stack_stop

	li t0, (0b11 << 11) | (1 << 13)
	csrw mstatus, t0

	la t1, kmain
	csrw mepc, t1

	la t2, handle_exception
	csrw mtvec, t2

	li t3, (1 << 3) | (1 << 5) | (1 << 7)
	csrw mie, t3

	la ra, 4f
	mret

4:
	wfi
	j 4b

.global handle_exception
handle_exception:
	mret
