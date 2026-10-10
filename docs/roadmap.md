# Project Roadmap

This roadmap tracks the major planned additions to the processor.

## Next Focus

TBD.

## Future Work

### Benchmarking

- Add CoreMark support.
- Expand benchmark support beyond the current directed C programs.
- Use architectural counters and synthesis results to evaluate future changes.

### Deeper Pipeline and RV32M

- Increase pipeline depth to improve timing and support longer-latency execution.
- Implement the RV32M multiplication and division instructions.
- Update hazard detection, forwarding, and pipeline control for the new structure.
- Measure the effect on timing and performance using the existing performance infrastructure.

### Data Cache and Memory System

- Add an L1 data cache.
- Define a shared memory interface for instruction and data traffic.
- Extend the memory system toward external memory support.

### System Integration

- Integrate UART through a memory-mapped peripheral interface.
- Add the basic system-level infrastructure needed for software-visible peripherals.
- Support program output and interaction on FPGA.

### Further Architectural Improvements

- Move appropriate predictor and cache structures to BRAM where beneficial.
- Continue branch-prediction improvements.
- Explore deeper memory hierarchy and DDR integration.
