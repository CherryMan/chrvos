const builtin = @import("builtin");

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

const buf = @intToPtr([*]volatile u16, 0xB8000);

fn puts(c: u8, x: usize, y: usize) void {
    const clr: u16 = 0b00001111 << 8;
    buf[y * VGA_WIDTH + x] = @as(u16, c) | clr;
}

fn init() void {
    var y: usize = 0;
    while (y < VGA_HEIGHT) : (y += 1) {
        var x: usize = 0;
        while (x < VGA_WIDTH) : (x += 1) {
            puts(' ', x, y);
        }
    }
}

export fn kmain() void {
    var row: usize = 0;
    var col: usize = 0;

    for ("Hello World!") |c| {
        puts(c, col, row);

        col += 1;
        if (col == VGA_WIDTH) {
            col = 0;
            row += 1;
            if (row == VGA_HEIGHT)
                row = 0;
        }
    }
}
