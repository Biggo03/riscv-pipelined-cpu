#include "csr_defs.h"
#include "stubs.h"
#include "test_status.h"

int main(void) {
    printf("Hello from bare-metal printf!\n");
    printf("String test: %s\n", "OK");
    printf("Value: %d\n", 12345);
    printf("Value: %d\n", 12345);
    printf("Value: %d\n", 12345);
    printf("Value: %d\n", 12345);

    signal_test_pass();
    while (1) {}
}
