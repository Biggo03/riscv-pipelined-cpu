#ifndef STUBS_H
#define STUBS_H

#include <stdint.h>
#include <stdarg.h>
#include "csr_defs.h"
#include "stub_helpers.h"

/* ---------------------------------------------------------
 * Stub printf — does nothing for now.
 * Replace later with CSR->TB printing.
 * --------------------------------------------------------- */
static inline int printf(const char *fmt, ...) {
    /* no-op */

    return 0;
}


#endif
