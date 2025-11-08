#ifndef CSR_DEFS_H
#define CSR_DEFS_H

// ------------------------------------------------------------
// Custom implementation-defined CSRs
// ------------------------------------------------------------
#define CSR_MTEST_STATUS  0x7C0u   // Test result register
#define CSR_MCYCLE        0xB00u   // Standard CSR example
#define CSR_MINSTRET      0xB02u

// ------------------------------------------------------------
//  inline access helpers (generic)
// ------------------------------------------------------------
#define read_csr(reg) ({ unsigned int __tmp; \
    asm volatile ("csrr %0, %1" : "=r"(__tmp) : "i"(reg)); \
    __tmp; })

#define write_csr(reg, val) \
    asm volatile ("csrw %0, %1" :: "i"(reg), "r"(val))

#endif // CSR_DEFS_H
