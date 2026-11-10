    .section .text
    .globl _start

    .include "test_macros.s"

    # Keep call placement and label addresses independent of linker relaxation.
    .option norelax
    .option norvc

_start:
    ################################################################
    # Fail flag and path selector
    ################################################################
    addi x31, x0, 0      # fail_flag = 0  (set to 1 only if wrong path commits)
    addi x28, x0, 0      # path_flag = 0  (armed just before the branch)

    ################################################################
    # Align to 64B boundary so we can place the branch as instr #16
    ################################################################
    .align 6             # 64-byte align => 16 instructions per block

# ---------------- Block N (16 instr total) ----------------
# [0]  target entry runs twice:
#      - linear pass:     x28==0 => stay on linear path
#      - redirect pass:   x28==1 => skip over branch & wrong-path
target:
    bne  x28, x0, from_branch    # [0] taken only on redirect after mispredict

    addi x5,  x0, 0              # [1] filler
    addi x6,  x0, 0              # [2]
    addi x7,  x0, 0              # [3]
    addi x8,  x0, 0              # [4]
    addi x9,  x0, 0              # [5]
    addi x10, x0, 0              # [6]
    addi x11, x0, 0              # [7]
    addi x12, x0, 0              # [8]
    addi x13, x0, 0              # [9]
    addi x14, x0, 0              # [10]
    addi x15, x0, 0              # [11]
    addi x16, x0, 0              # [12]

    addi x28, x0, 1              # [13] ARM path_flag just before branch

    beq  x0,  x0, target         # [14] BRANCH @ 16th instr:
                                  #  - predictor (WNT) predicts NOT-TAKEN
                                  #  - actual TAKEN (back to 'target') => MIS-PREDICT

# --------------- Block N+1 (fall-through = wrong path) ---------------
# The fall-through PC (wrong path) is the first instr of the *next* 64B block.
# With a cold I$, this fetch causes an I$ MISS while the branch resolves.
wrong_path:
    addi x31, x0, 1              # wrong-path marker (must be flushed)
    addi x20, x0, 99
    sw   x20, 100(x0)            # WRONG store if rollback is broken
    beq  x0,  x0, after_branch   # park wrong path

# Arrive here only via the taken branch after mispredict redirect.
# Skip over the branch and the entire wrong-path block.
from_branch:
    jal  x0,  after_branch

# ----------------------- JAL link-write overlap -----------------------
after_branch:
    # If any wrong-path op committed (x31 != 0), test fails
    bne  x31, x0, fail

    # Warm the callee before testing a call with a cold fall-through line.
    # x31 bits: 0=JAL link, 1=JALR link, 2/3=their wrong-path markers.
    li   ra, -1
    la   x20, jal_return
    li   x29, 0
    jal  x0, jal_callee

    .balign 64
jal_call_block:
    .rept 14
        nop
    .endr
jal_overlap_call:
    # Offset 0x38: fetch crosses into the cold next line while this resolves.
    jal  ra, jal_callee
jal_return:
    jal  x0, after_jal

    # First instruction of the cold fall-through line; must never commit.
jal_wrong_path:
    ori  x31, x31, 4
    jal  x0, after_jal

# ----------------------- JALR link-write overlap ----------------------
    .balign 64
after_jal:
    li   x5, -1
    la   x21, jalr_return
    la   x22, jalr_callee
    li   x29, 0
    jal  x0, jalr_callee

    .balign 64
jalr_call_block:
    .rept 14
        nop
    .endr
jalr_overlap_call:
    # Use x5 as the link register to check a non-ra destination as well.
    jalr x5, 0(x22)
jalr_return:
    jal  x0, after_jalr

jalr_wrong_path:
    ori  x31, x31, 8
    jal  x0, after_jalr

# ----------------------- Success epilogue -----------------------------
    .balign 64
after_jalr:
    bne  x31, x0, fail
    SIGNAL_TEST_PASS
    j    end_test

fail:
    csrw 0x7A0, x31              # mdbg: identify the failed link/path checks
    SIGNAL_TEST_FAIL

end_test:
    j    end_test

# Both callees fit in one line. The warm-up pass sets x29 and goes to the
# corresponding call block; the actual pass checks and returns via the link.
    .balign 64
jal_callee:
    beq  x29, x0, jal_warmed
    beq  ra, x20, jal_link_ok
    ori  x31, x31, 1
    # Continue at the known return label so JALR is tested even if JAL fails.
    jal  x0, jal_return
jal_link_ok:
    jalr x0, 0(ra)
jal_warmed:
    li   x29, 1
    jal  x0, jal_call_block

    .balign 64
jalr_callee:
    beq  x29, x0, jalr_warmed
    beq  x5, x21, jalr_link_ok
    ori  x31, x31, 2
    jal  x0, jalr_return
jalr_link_ok:
    jalr x0, 0(x5)
jalr_warmed:
    li   x29, 1
    jal  x0, jalr_call_block
