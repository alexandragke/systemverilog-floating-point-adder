# SystemVerilog Floating-point Adder

A 32-bit single-precision floating-point adder implemented in SystemVerilog.

Course: Hardware II
Academic Year: 2025-2026

## Project Overview

The project implements a pipelined floating-point adder based on the IEEE 754 single-precision format with some project-specific simplifications:

- Denormalized numbers are treated as signed zero
- NaN values are treated as signed infinity
- Overflow and underflow conditions are handled according to the implemented rounding mode

The design includes the main stages required for floating-point addition:

- Exponent comparison
- Mantissa alignment
- Addition/Subtraction
- Normalization
- Rounding
- Exception handling

The design accepts new inputs every clock cycle and produces the corresponding result with a two-cycle latency.

## Rounding Modes

The following rounding modes are supported:

- Round to nearest
- Round toward zero
- Round toward negative infinity
- Round toward positive infinity
- Round to nearest, maximum magnitude

## Verification

The design was verified using simulation, randomized testing and SystemVerilog Assertions (SVA).

Verification included:

- 50,000 randomized tests
- 500 corner-case tests
- Comparison with a reference model
- Assertions for timing and output correctness

**Final verification result: 0 errors**
