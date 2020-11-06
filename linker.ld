OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  ram (wxa) : ORIGIN = 0x80000000, LENGTH = 128M
}

PHDRS
{
  text PT_LOAD;
  data PT_LOAD;
  bss PT_LOAD;
}

SECTIONS
{
  . = ORIGIN(ram);

  .text : {
    *(.text.init)
    *(.text .text.*)
  }

  .rodata : {
    *(.rodata .rodata.*)
  }

  _global_pointer = .;

  .data : {
    . = ALIGN(4K);
    *(.sdata .sdata.*)
    *(.data .data.*)
  }

  .bss : {
    _bss_start = .;
    *(.sbbs .sbss.*)
    *(.bss .bss.*)
    _bss_stop = .;
  }

  _stack_start = .;
  _stack_stop = _stack_start + 512K;

  _heap_start = _stack_stop;
  _heap_size = ORIGIN(ram) + LENGTH(ram) - _heap_start;
}
