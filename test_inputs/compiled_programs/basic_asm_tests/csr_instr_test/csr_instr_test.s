    .section .text
    .globl _start

_start:
    # -----------------------------------------------------------------
    # Register setup
    # -----------------------------------------------------------------
    addi x2, x0, 5          # test value A
    addi x3, x0, 10         # test value B
    addi x4, x0, 100        # memory address (success/fail flag)
    addi x5, x0, 25         # success value
    addi x6, x0, 0          # fail value

    # -----------------------------------------------------------------
    # 1. Test CSRRW
    # -----------------------------------------------------------------
    csrrw x7, mstatus, x2    # write 5 -> mstatus, x7 = old value
    csrrw x8, mstatus, x3    # write 10 -> mstatus, x8 = 5 (old value)

    # Check that x8 == 5
    bne x8, x2, fail

    # -----------------------------------------------------------------
    # 2. Test CSRRS
    # -----------------------------------------------------------------
    csrrs x9, mstatus, x2    # set bits (mstatus = 10 | 5 = 15)
    csrrs x10, mstatus, x0   # read current mstatus (should be 15)
    addi x11, x0, 15
    bne x10, x11, fail

    # -----------------------------------------------------------------
    # 3. Test CSRRC
    # -----------------------------------------------------------------
    csrrc x12, mstatus, x2   # clear bits 5 (15 & ~5 = 10)
    csrrc x13, mstatus, x0   # read current mstatus (should be 10)
    bne x13, x3, fail

    # -----------------------------------------------------------------
    # 4. Test CSRRWI / CSRRSI / CSRRCI
    # -----------------------------------------------------------------
    # Set mstatus = 20
    csrrwi x0, mstatus, 20        # write 20, discard old value
    csrrs  x15, mstatus, x0       # readback -> x15, mstatus unchanged
    addi   x16, x0, 20
    bne    x15, x16, fail

    # Set bits 5 (|= 5): 20 | 5 = 21
    csrrsi x0, mstatus, 5         # write (mstatus |= 5)
    csrrs  x17, mstatus, x0       # readback -> x17, mstatus unchanged
    addi   x18, x0, 21
    bne    x17, x18, fail

    # Clear bits 1 (&= ~1): 21 & ~1 = 20
    csrrci x0, mstatus, 1         # write (mstatus &= ~1)
    csrrs  x19, mstatus, x0       # readback -> x19
    bne    x19, x16, fail         # compare to 20
    # -----------------------------------------------------------------
    # 5. Success condition
    # -----------------------------------------------------------------
success:
    sw x5, 100(x0)           # store 25 to memory[100]
    beq x0, x0, end

fail:
    sw x6, 100(x0)           # store 0 to memory[100]

end:
    nop
