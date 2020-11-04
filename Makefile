OUT		= zig-cache/bin/os

ZIG		= zig
ZIG_ARGS	= build-exe main.zig --c-source boot.S
ZIG_ARGS	+= --linker-script linker.ld
ZIG_ARGS	+= -target riscv64-freestanding-none
ZIG_ARGS	+= --name os
ZIG_ARGS	+= --output-dir zig-cache/bin
ZIG_ARGS	+= -code-model medium
ZIG_ARGS	+= -fPIC

GDB		= riscv64-unknown-elf-gdb
QEMU		= qemu-system-riscv64 $(QEMU_ARGS)
QEMU_DBG	= $(QEMU) $(QEMU_DBG_ARGS)
QEMU_ARGS	= -machine virt -m 128M -cpu rv64
QEMU_ARGS	+= -bios none
QEMU_DBG_ARGS	= -S -gdb tcp::1234
# QEMU_ARGS	+= -nographic -serial mon:stdio

.PHONY: run
run: build
	$(QEMU) -kernel $(OUT)

.PHONY: rundbg
rundbg: build
	$(QEMU_DBG) -kernel $(OUT)

.PHONY: build
build:
	$(ZIG) $(ZIG_ARGS)

.PHONY: gdb
gdb:
	$(GDB) --tui $(OUT)
