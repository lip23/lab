/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);	/* tf_trapno */				\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;		/* tf_err */			\
	pushl $(num);	/* tf_trapno */				\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

/* handle divide error 
   除零错误cpu不会自动压人错误码*/
TRAPHANDLER_NOEC(handler1, T_DIVIDE)
TRAPHANDLER_NOEC(handler3, T_BRKPT)
TRAPHANDLER(handler13, T_GPFLT)
TRAPHANDLER(handler14, T_PGFLT)
/* handle system call */
TRAPHANDLER_NOEC(handler48, T_SYSCALL)




/*
 * Lab 3: Your code here for _alltraps
 * Your _alltraps should:

 * 1.push values to make the stack look like a struct Trapframe
 * 2.load GD_KD into %ds and %es
 * 3.pushl %esp to pass a pointer to the Trapframe as an argument to trap()
 * 4.call trap (can trap ever return?)
 */

_alltraps:
  pushl %ds # tf_ds
  pushl %es # tf_es
  pushal # tf_regs
  movw $GD_KD, %ax
  movw %ax, %ds
  movw %ax, %es
  pushl %esp # 入参
  call trap
