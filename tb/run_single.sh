#!/bin/bash
cd "$(dirname "$0")"
iverilog -g2012 -s top_single -o sim.vvp \
  ../src/single_cycle_processor/risc_v_32_i_pkg.sv \
  ../src/single_cycle_processor/{ArithmeticLogicUnit,ComparatorUnit,CoreControlUnit,ImmediateSignExtend,LoadStoreUnit,RegisterFile,InstructionMemory,DataMemory,ProcessorCore}.sv \
  top_single.sv 2>&1 | grep -i " error" ; vvp sim.vvp | grep -v WARNING