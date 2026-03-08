ENTRY(Reset_Handler)

MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 1024K
  RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 128K
}

_estack = ORIGIN(RAM) + LENGTH(RAM); /* Top of RAM */

SECTIONS
{
  /* 1. Vector table goes first */
  .isr_vector : 
  { 
    KEEP(*(.isr_vector)) 
  } > FLASH

  /* 2. Program code and read-only data */
  .text : 
  { 
    *(.text*) 
    *(.rodata*)
    _etext = .; /* End of code */
  } > FLASH

  /* 3. Used for copying initialized globals from Flash to RAM */
  _sidata = LOADADDR(.data);
  .data : 
  {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > RAM AT > FLASH

  /* 4. Zero-initialized data (BSS) */
  .bss : 
  {
    _sbss = .;
    *(.bss*)
    *(COMMON)
    _ebss = .;
  } > RAM
}

