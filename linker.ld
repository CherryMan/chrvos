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
  .text : {
    *(.text.init)
    *(.text .text.*)
  } >ram AT>ram :text

  .rodata : {
    *(.rodata .rodata.*)
  } >ram AT>ram :text

  PROVIDE(_global_pointer = .);

  .data : {
    . = ALIGN(4K);
    *(.sdata .sdata.*)
    *(.data .data.*)
  } >ram AT>ram :data

  .bss : {
    PROVIDE(_bss_start = .);
    *(.sbbs .sbss.*) *(.bss .bss.*)
    PROVIDE(_bss_stop = .);
  } >ram AT>ram :bss

  PROVIDE(_stack_start = _bss_stop);
  PROVIDE(_stack_stop = _stack_start + 512K);

  PROVIDE(_heap_start = _stack_stop);
  PROVIDE(_heap_size = ORIGIN(ram) + LENGTH(ram) - _heap_start);
}
