# ------------------------------------------------------------
# Constants (match test_status.h)
# ------------------------------------------------------------
.set TEST_PASS, 0xABCD1234
.set TEST_FAIL, 0xDEADBEEF

# ------------------------------------------------------------
# Helper macros
# ------------------------------------------------------------
    .macro WRITE_MTEST_STATUS val
        li t0, \val
        csrw 0x7C0, t0
    .endm

    .macro SIGNAL_TEST_PASS
        li t0, TEST_PASS
        csrw 0x7C0, t0
    .endm

    .macro SIGNAL_TEST_FAIL
        li t0, TEST_FAIL
        csrw 0x7C0, t0
    .endm

