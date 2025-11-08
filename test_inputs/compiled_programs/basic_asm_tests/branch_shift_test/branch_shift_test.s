    .section .text
    .globl _start

    .include "test_macros.s"

_start:
    # x18 = 15
    addi x18, x0, 15

    # x19 = 14
    addi x19, x0, 14

    # Branch: since x19 != x18, branch taken
    bne  x19, x18, branch1

    # Should not execute
    addi x20, x0, -1

branch1:
    # x20 = 15 << 14 = 229376
    sll  x20, x18, x19

    # x20 = 229376 >> 15 = 7
    srl  x20, x20, x18

    # x20 = 7 + 18 = 25
    addi x20, x20, 18

    # x22 = -1
    addi x22, x0, -1

    # Arithmetic shift right: x22 remains -1
    sra  x22, x22, x19

    # Branch: since -1 < 15 (signed), branch taken
    blt  x22, x18, store

    # Should not execute
    addi x20, x0, 2

store:
    # Final result expected: x20 = 25
    li    t0, 25
    beq   x20, t0, success
    j     fail

success:
    SIGNAL_TEST_PASS
    j     end_test

fail:
    SIGNAL_TEST_FAIL

end_test:
    nop
