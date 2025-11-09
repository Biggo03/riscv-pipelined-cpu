#ifndef TEST_STATUS_H
#define TEST_STATUS_H

#include "csr_defs.h"

// ------------------------------------------------------------
// Test result codes
// ------------------------------------------------------------
#define TEST_PASS 0xABCD1234u
#define TEST_FAIL 0xDEADBEEFu

// ------------------------------------------------------------
// Inline helper for writing test status
// ------------------------------------------------------------
static inline void write_mtest_status(unsigned int val) {
    asm volatile ("csrw %0, %1" :: "i"(CSR_MTEST_STATUS), "r"(val));
}

static inline void signal_test_pass(void) {
    write_mtest_status(TEST_PASS);
}

static inline void signal_test_fail(void) {
    write_mtest_status(TEST_FAIL);
}

#endif // TEST_STATUS_H
