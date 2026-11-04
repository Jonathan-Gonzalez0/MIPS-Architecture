`timescale 1ns/1ps

// The Writeback Data MUX is BEFORE this register in the Phase II diagram.
// Only its selected PW value, destination RW and RF_LE are stored: 38 bits.
module MEMWB (
    input wire Clk,
    input wire Reset,
    input wire [31:0] PW_in,         // Selected Data Memory output or ALU/PC+8
    input wire [4:0] RW_in,          // EX/MEM.RD, not the 1-bit memory RW control
    input wire RF_LE_in,             // Stored control, not a MEMWB load enable

    output reg [31:0] PW_out,
    output reg [4:0] RW_out,
    output reg RF_LE_out
);

    // Synchronous reset; all three outputs update only on a rising edge.
    always @(posedge Clk) begin
        if (Reset) begin
            PW_out <= 32'b0;
            RW_out <= 5'b0;
            RF_LE_out <= 1'b0;
        end
        else begin
            PW_out <= PW_in;
            RW_out <= RW_in;
            RF_LE_out <= RF_LE_in;
        end
    end
endmodule
