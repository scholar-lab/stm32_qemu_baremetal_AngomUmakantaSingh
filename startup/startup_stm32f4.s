/* Configure the assembler for ARM Cortex-M4 target:
 * - Use unified ARM/Thumb assembly syntax
 * - Generate instructions compatible with Cortex-M4
 * - Assemble code in Thumb mode (required for Cortex-M processors)
 */
.syntax unified
.cpu cortex-m4
.thumb

/* Import memory addresses defined in the Linker Script (linker.ld) */
.extern _estack
.extern _sidata
.extern _sdata
.extern _edata
.extern _sbss
.extern _ebss

/* Import the SysTick handler implemented in C */
.extern SysTick_Handler
.extern main

/* .global : makes the symbol visible to the linker so it can be referenced
 *           from other files or from the vector table.
 * .type   : informs the assembler that the symbol represents a function,
 *           allowing correct symbol metadata and function handling.
 */
.global g_pfnVectors
.global Reset_Handler
.type Reset_Handler, %function  
.global Default_Handler
.type Default_Handler, %function

/* Definition of the Vector Table 
 * Entry 0 : Initial stack pointer value
 * Entry 1 : Reset handler (program start)
 * Entry 2-6 : Core fault handlers (NMI, HardFault, MemManage, BusFault, UsageFault)
 * Entry 7-10 : Reserved entries
 * Entry 11-15 : System service and timer handlers (SVCall, Debug, PendSV, SysTick)
*/
.section .isr_vector,"a",%progbits
.align 2 	//ensure vector table is word aligned
g_pfnVectors:
    .word _estack      		  /* 0 Set initial Stack Pointer to the top of RAM */
    .word Reset_Handler  /* 1 Set the instruction pointer to start at Reset_Handler */
    .word Default_Handler                  /* 2  NMI */
    .word Default_Handler                  /* 3  HardFault */
    .word Default_Handler                  /* 4  MemManage */
    .word Default_Handler                  /* 5  BusFault */
    .word Default_Handler                  /* 6  UsageFault */
    .word 0                  /* 7  Reserved */
    .word 0                  /* 8  Reserved */
    .word 0                  /* 9  Reserved */
    .word 0                  /* 10 Reserved */
    .word Default_Handler                  /* 11 SVCall */
    .word Default_Handler                  /* 12 Debug Monitor */
    .word 0                 /* 13 Reserved */
    .word Default_Handler                 /* 14 PendSV */
    .word SysTick_Handler    		 /* 15 SysTick */

/* Reset_Handler Definition  */
.section .text.Reset_Handler,"ax",%progbits
Reset_Handler:

    /* Prepare to copy initialized variables from Flash (ROM) to RAM */
    ldr r0, =_sidata     /* R0 = Source address in Flash */
    ldr r1, =_sdata      /* R1 = Destination start address in RAM */
    ldr r2, =_edata      /* R2 = Destination end address in RAM */

    /* Loop: Check if we have finished copying the .data section */
1:  cmp r1, r2           /* Compare current RAM position with the end address */
    bcc 2f               /* If current < end, branch forward to label 2 (copy) */
    b 3f                 /* If current >= end, branch forward to label 3 (done) */

    /* Copy 4 bytes at a time and increment the pointers */
2:  ldr r3, [r0], #4     /* Load value from Flash into R3, then move R0 forward */
    str r3, [r1], #4     /* Store value into RAM from R3, then move R1 forward */
    b 1b                 /* Jump back to label 1 to check the loop condition again */

    /* Prepare to wipe the .bss section (uninitialized globals) to zero */
3:  ldr r1, =_sbss       /* R1 = Start of BSS in RAM */
    ldr r2, =_ebss       /* R2 = End of BSS in RAM */
    movs r3, #0          /* R3 = The value zero */

    /* Loop: Fill the BSS memory range with zeros */
4:  cmp r1, r2           /* Compare current RAM position with the end address */
    bcc 5f               /* If current < end, branch forward to label 5 (zeroing) */
    b 6f                 /* If current >= end, branch forward to label 6 (done) */

    /* Write zero to memory and move to the next 4-byte slot */
5:  str r3, [r1], #4     /* Store zero at address in R1, then increment R1 by 4 */
    b 4b                 /* Jump back to label 4 to check the loop condition again */

    /* Hand over control to your C application */
6:  bl main              /* Call the C 'main' function */

    /* Safety trap: If main() ever returns, loop here forever */
7:  b 7b                 /* Infinite loop to prevent CPU from running into empty space */

Default_Handler:
    b Default_Handler
