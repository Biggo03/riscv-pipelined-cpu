    .section .text._start
    .globl _start
_start:
    # set global pointer
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    # set up stack
    la sp, __stack_top
    addi sp, sp, -16     # make room + avoid top-of-memory edge
    andi sp, sp, -16     # force 16-byte alignment


    # zero out .bss
    la t0, __bss_start
    la t1, __bss_end
1:
    beq t0, t1, 2f
    sw x0, 0(t0)
    addi t0, t0, 4
    j 1b
2:
    # Zero out .sbss
    la   t0, __sbss_start
    la   t1, __sbss_end
3:
    beq  t0, t1, 4f
    sw   x0, 0(t0)
    addi t0, t0, 4
    j    3b
4:
    # call main
    call main

    # if main ever returns, hang
hang:
    j hang
