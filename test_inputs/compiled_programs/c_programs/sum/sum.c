#include "test_status.h"

int main() {
    int sum = 0;

    // // Do some work (e.g., sum 1..10)
    for (int i = 0; i < 25; i++) {
        sum += 1;
    }

    if (sum == 25) {
        signal_test_pass();
    } else {
        signal_test_fail();
    }

    // Prevent program from exiting
    while (1);
    return 0;
}
