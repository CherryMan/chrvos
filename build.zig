const std = @import("std");
const builtin = @import("builtin");
const riscv = std.Target.riscv;
const CrossTarget = std.zig.CrossTarget;
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const exe = b.addExecutable("kernel", "main.zig");
    exe.addAssemblyFile("boot.S");
    exe.setLinkerScriptPath("./linker.ld");

    // Addresses >=0x80000000 are not directly addressable,
    // so enabling position-independent-code is necessary
    // if the any code is in that area. An alternative
    // is to set code model to medium.
    exe.force_pic = true;

    exe.setBuildMode(b.standardReleaseOptions());
    exe.setTarget(CrossTarget{
        .cpu_arch = builtin.Arch.riscv64,
        .os_tag = builtin.Os.Tag.freestanding,
        .abi = builtin.Abi.none,

        // As of now, this is essentially RV64GC.
        .cpu_model = CrossTarget.CpuModel{
            .explicit = &riscv.cpu.baseline_rv64,
        },
    });

    b.default_step.dependOn(&exe.step);
    exe.install();

    const qemu = b.step("qemu", "Run QEMU");
    const qemu_gdb = b.step("qemu-gdb", "Run QEMU paused with a gdb server");

    const qemu_params = &[_][]const u8{
        "qemu-system-riscv64",
        "-machine",
        "virt",
        "-m",
        "128M",
        "-cpu",
        "rv64",

        // No bios since the kernel performs initialisation.
        "-bios",
        "none",
        "-kernel",
    };

    const run_qemu = b.addSystemCommand(qemu_params);
    const run_qemu_gdb = b.addSystemCommand(qemu_params);

    // Append path to kernel after `-kernel` flag.
    run_qemu.addArtifactArg(exe);
    run_qemu_gdb.addArtifactArg(exe);

    // Additional arguments for debugging. QEMU paused starts with a gdb server.
    run_qemu_gdb.addArgs(&[_][]const u8{
        "-gdb", "tcp::1234",
        "-S",
    });

    run_qemu.step.dependOn(b.default_step);
    run_qemu_gdb.step.dependOn(b.default_step);
    qemu.dependOn(&run_qemu.step);
    qemu_gdb.dependOn(&run_qemu_gdb.step);

    const gdb = b.step("gdb", "Run riscv64-unknown-elf-gdb");
    const run_gdb = b.addSystemCommand(&[_][]const u8{
        "riscv64-unknown-elf-gdb",
    });

    // Append path to kernel to load symbols.
    run_gdb.addArtifactArg(exe);

    run_gdb.step.dependOn(b.default_step);
    gdb.dependOn(&run_gdb.step);
}
