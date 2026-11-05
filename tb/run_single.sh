#!/bin/bash
# Compile and run the single-cycle processor with one test program.
#
# Usage (from anywhere):   bash tb/run_single.sh [test_name]
#   test_name = name of a .txt program in tb/, without the extension.
#   Default: R_type
#
# Example:                 bash tb/run_single.sh custom_test

cd "$(dirname "$0")" || exit 1
TEST="${1:-R_type}"
SRC=../src/single_cycle_processor

if [ ! -f "$TEST.txt" ]; then
    echo "ERROR: tb/$TEST.txt not found"
    exit 1
fi

# Number of instructions = number of non-empty lines in the program file.
NUM_INSTR=$(grep -c '[0-9a-fA-F]' "$TEST.txt")

mkdir -p build

# Make a copy of InstructionMemory that loads the chosen program,
# so you never have to edit the file in src/.
sed -E "s/\"[A-Za-z0-9_]+\.txt\"/\"$TEST.txt\"/" "$SRC/InstructionMemory.sv" > build/InstructionMemory.sv

# The package must come first. MacUnit.sv is included once it exists.
FILES="$SRC/risc_v_32_i_pkg.sv"
for m in ArithmeticLogicUnit ComparatorUnit CoreControlUnit ImmediateSignExtend \
         LoadStoreUnit RegisterFile MacUnit DataMemory ProcessorCore; do
    if [ -f "$SRC/$m.sv" ]; then
        FILES="$FILES $SRC/$m.sv"
    fi
done

iverilog -g2012 -s top_single -P top_single.NUM_INSTR="$NUM_INSTR" \
    -o build/sim.vvp $FILES build/InstructionMemory.sv top_single.sv > build/compile.log 2>&1
if [ $? -ne 0 ]; then
    grep -i "error" build/compile.log
    echo "Compilation FAILED (full log: tb/build/compile.log)"
    exit 1
fi

echo "== Program: $TEST ($NUM_INSTR instructions) =="
vvp build/sim.vvp | grep -v -i "warning\|Time:\|VCD info"
echo "(waveform: tb/wave.vcd  ->  gtkwave tb/wave.vcd)"