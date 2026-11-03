`timescale 1ns/1ps
module top_single;
    parameter NUM_INSTR = 12;      // number of instructions in the program

    logic clk = 0;
    logic reset = 1;
    logic [31:0] instruction_address, instruction_data;
    logic [31:0] read_data, write_data, data_address;
    logic [3:0]  write_data_strobe;
    logic        write_enable;
    integer i;

    always #5 clk = ~clk;          // clock toggles every 5 ns

    InstructionMemory imem (
        .instruction_data_o    (instruction_data),
        .instruction_address_i (instruction_address));

    ProcessorCore PrCore (
        .clk_i                 (clk),
        .reset_i               (reset),
        .instruction_address_o (instruction_address),
        .instruction_data_i    (instruction_data),
        .read_data_i           (read_data),
        .write_enable_o        (write_enable),
        .write_data_o          (write_data),
        .write_data_strobe_o   (write_data_strobe),
        .address_o             (data_address));

    DataMemory dmem (
        .read_data_o    (read_data),
        .clk_i          (clk),
        .write_enable_i (write_enable),
        .write_data_i   (write_data),
        .address_i      (data_address));

    initial begin
        $dumpfile("wave.vcd");     // waveform file for GTKWave
        $dumpvars(0, top_single);
        @(negedge clk);            // first falling edge: instruction 0 gets written
        #1 reset = 0;              // release reset; the PC starts advancing
        repeat (NUM_INSTR - 1) @(negedge clk);   // wait for the last write
        #1;
        for (i = 1; i < 16; i = i + 1)
            $display("x%0d = %h", i, PrCore.regfile.register[i]);
        $finish;
    end
endmodule