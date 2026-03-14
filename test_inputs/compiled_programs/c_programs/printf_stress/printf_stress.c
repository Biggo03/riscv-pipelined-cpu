#include "csr_defs.h"
#include "stubs.h"
#include "test_status.h"

int main(void) {

    printf("----- PRINTF STRESS TEST START -----\n");

    printf("Simple strings:\n");
    printf("Hello world!\n");
    printf("RISC-V custom printf working.\n");

    printf("\nNumbers:\n");
    printf("Zero: %d\n", 0);
    printf("Positive small: %d\n", 7);
    printf("Positive medium: %d\n", 123);
    printf("Positive large: %d\n", 987654321);
    printf("Negative small: %d\n", -3);
    printf("Negative medium: %d\n", -456);
    printf("Negative large: %d\n", -2147483647);

    printf("\nMixed formatting:\n");
    printf("Coordinates: x=%d y=%d\n", 10, 20);
    printf("Score: %d/%d\n", 17, 20);
    printf("Temp: %d C, Status: %s\n", 25, "OK");
    printf("User: %s ID=%d\n", "Alice", 42);
    printf("%s %d %s %d %s\n", "Mix", 1, "more", 2, "values");

    printf("\nString tests:\n");
    printf("Empty string: '%s'\n", "");
    printf("Short string: '%s'\n", "abc");
    printf("Long string: '%s'\n", "ABCDEFGHIJKLMNOPQRSTUVWXYZ");

    printf("\nLiteral percent:\n");
    printf("This should show a percent sign: %%\n");

    printf("\nMultiline block:\n");
    printf("Line 1: %d\n", 111);
    printf("Line 2: %s\n", "hello");
    printf("Line 3: %d %s %d\n", 1, "two", 3);

    printf("\nAll tests done. If output looks correct, PASS.\n");

    signal_test_pass();

    while (1) { }
}
