`timescale 1ns/1ps

// EX/MEM stores 69 data bits and 7 control bits from the Phase II diagram.
// ALU_in is the Output MUX result: ALU result or PC+8, already selected in EX.
// RF_LE_in is the register-write condition already resolved by the AND in EX.
module EXMEM (
    input wire Clk,
    input wire Reset,

    input wire [31:0] ALU_in,
    input wire [31:0] SD_in,
    input wire [4:0] RD_in,
    input wire RF_LE_in,
    input wire RW_in,
    input wire E_in,
    input wire [1:0] Size_in,
    input wire SE_in,
    input wire MemToReg_in,

    // ALU: memory address / Writeback Data input; SD: data to be stored.
    // RD and RF_LE continue toward MEM/WB; memory controls are used in MEM.
    output reg [31:0] ALU_out,
    output reg [31:0] SD_out,
    output reg [4:0] RD_out,
    output reg RF_LE_out,
    output reg RW_out,
    output reg E_out,
    output reg [1:0] Size_out,
    output reg SE_out,
    output reg MemToReg_out
);

    // No Load Enable or separate Clear. Reset acts only on a rising edge.
    always @(posedge Clk) begin
        if (Reset) begin
            ALU_out <= 32'b0;
            SD_out <= 32'b0;
            RD_out <= 5'b0;
            RF_LE_out <= 1'b0;
            RW_out <= 1'b0;
            E_out <= 1'b0;
            Size_out <= 2'b00;
            SE_out <= 1'b0;
            MemToReg_out <= 1'b0;
        end
        else begin
            ALU_out <= ALU_in;
            SD_out <= SD_in;
            RD_out <= RD_in;
            RF_LE_out <= RF_LE_in;
            RW_out <= RW_in;
            E_out <= E_in;
            Size_out <= Size_in;
            SE_out <= SE_in;
            MemToReg_out <= MemToReg_in;
        end
    end
endmodule
