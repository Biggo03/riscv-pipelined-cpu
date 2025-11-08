    .section .text
    .globl _start

    .include "test_macros.s"

_start:
    # --- Program 5: LUI/ADDI/branch/jalr block ---
    lui   x18, 709518
    addi  x18, x18, 2000
    sw    x18, 40(x0)
    lh    x19, 40(x0)
    lhu   x20, 42(x0)
    sltu  x21, x20, x19
    bne   x0, x21, branch5
    add   x19, x0, x0

branch5:
    xor   x19, x19, x20
    auipc x20, 4
    addi  x19, x19, -1516
    slti  x21, x19, 20
    sltiu x22, x19, 20
    add   x21, x21, x22
    add   x20, x19, x20
    add   x20, x20, x21
    jalr  x21, x0, 72
    addi  x20, x0, 0               # should not run
    srli  x20, x20, 22
    sub   x20, x20, x21
    addi  x20, x20, -930
    sw    x20, 144(x0)             # mem[144] = 25
    add   x18, x0, x0

    # --- Program 4: store/load/logic immediate block ---
    addi  x1, x0, 500
    sb    x1, 40(x0)
    addi  x1, x0, 1950
    sh    x1, 42(x0)
    addi  x2, x0, -1
    sb    x2, 41(x0)
    bgeu  x2, x11, branch4
    sh    x1, 40(x0)               # should not run

branch4:
    lb    x1, 40(x0)
    lbu   x2, 42(x0)
    andi  x2, x2, 125
    ori   x2, x2, 25
    xori  x2, x2, 4
    add   x2, x2, x1
    addi  x2, x2, 12
    sw    x2, 148(x0)              # mem[148] = 25
    add   x18, x0, x0

    # --- Program 3: shift-immediate + branch ---
    addi  x3, x0, 15
    addi  x4, x0, 14
    bge   x3, x4, branch3
    addi  x3, x0, -1               # should not run

branch3:
    slli  x5, x3, 14
    srli  x5, x5, 15
    addi  x5, x5, 18
    addi  x6, x0, -1
    srai  x6, x6, 10
    bltu  x3, x6, store3
    addi  x5, x0, 2                # should not run
    sw    x5, 100(x0)              # should not run

store3:
    sw    x5, 152(x0)              # mem[152] = 25
    add   x18, x0, x0

    # --- Program 2: shift + branch ---
    addi  x7, x0, 15
    addi  x8, x0, 14
    bne   x8, x7, branch2
    addi  x9, x0, -1               # should not run

branch2:
    sll   x9, x7, x8
    srl   x9, x9, x7
    addi  x9, x9, 18
    addi  x10, x0, -1
    sra   x10, x10, x8
    blt   x10, x7, store2
    addi  x9, x0, 2                # should not run
    sw    x9, 100(x0)              # should not run

store2:
    sw    x9, 156(x0)              # mem[156] = 25
    add   x18, x0, x0

    # --- Program 1: OR/AND/SLT + JAL ---
    addi  x11, x0, 5
    addi  x12, x0, 12
    addi  x14, x12, -9
    or    x13, x14, x11
    and   x15, x12, x13
    add   x15, x15, x13
    beq   x15, x14, end1           # not taken
    slt   x13, x12, x13
    beq   x13, x0, around1         # taken
    addi  x15, x0, 0               # should not run

around1:
    slt   x13, x14, x11
    add   x14, x13, x15
    sub   x14, x14, x11
    sw    x14, 84(x12)             # mem[96] = 7
    lw    x11, 96(x0)              # x11 = 7
    add   x16, x11, x15            # x16 = 18
    jal   x12, end1
    addi  x12, x12, -272           # should not run
    addi  x11, x0, 1               # should not run

end1:
    add   x11, x11, x16            # x11 = 25
    sw    x11, -180(x12)           # mem[160] = 25
    add   x18, x0, x0

    # --- New: register walk + loop ---
    addi  x17, x0, 1
    addi  x22, x17, 1
    addi  x23, x22, 1
    addi  x24, x23, 1
    addi  x25, x24, 1
    addi  x26, x25, 1
    addi  x27, x26, 1
    addi  x28, x27, 1
    addi  x29, x28, 1
    addi  x30, x29, 1
    addi  x31, x30, 1

    lw    x1, 144(x0)              # x1 = 25
    lw    x2, 148(x0)              # x2 = 25
    lw    x3, 152(x0)              # x3 = 25
    lw    x4, 156(x0)              # x4 = 25
    lw    x5, 160(x0)              # x5 = 25

    add   x6, x0, x0
    add   x6, x6, x1               # 0  + 25 = 25
    sub   x6, x6, x2               # 25 - 25 = 0
    add   x6, x6, x3               # 0  + 25 = 25
    sub   x6, x6, x4               # 25 - 25 = 0
    add   x6, x6, x5               # 0  + 25 = 25
    sub   x6, x6, x4               # 25 - 25 = 0

Loop:
    addi  x1, x1, -1               # run 25 iters → x1→0
    addi  x6, x6, 1                # 0→25
    bnez  x1, Loop                 # exit when x1==0

    # -------- Final: branch to PASS/FAIL via CSR test register --------
    li    t0, 25
    beq   x6, t0, success
    j     fail

success:
    SIGNAL_TEST_PASS
    j     end_test

fail:
    SIGNAL_TEST_FAIL

end_test:
    nop
