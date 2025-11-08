# Current tasks:
- update roadmap with completion of csr instrucions
    - Remove CSR implementation and add in performance monitoring
- Update smoke tests
    - Ensure that the cache stress test really does stress the cache system (every possible combination MUST be hit in simulation)
    - Double check CSR tests
    - Update full_tests to include csr instructions
        - Maybe update them fully?
    - Update test success flag to make more sense so that both C programs and assembly programs share same write condition
        - Ensure makes sense with memory map
- Begin work on documentation
- Begin work on performance monitoring

## High level:
- Stabilize and unify testing infrastructure
- Document architectural state and rationale
- Instrument performance measurement
- Use metrics to guide future optimizations
