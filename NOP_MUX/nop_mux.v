`timescale 1ns/1ps

// Each *_in comes from ControlUnit; its matching *_out goes to ID/EX.
// Jump, RegDst, SRA and SRB stay in ID and do not pass through this module.
module NOPMux (
    input wire S,
    input wire OS1_in,
    input wire [1:0] OS2_in,
    input wire [3:0] OP_in,
    input wire [2:0] BranchType_in,
    input wire [1:0] WriteCond_in,
    input wire RF_LE_in,
    input wire MemToReg_in,
    input wire RW_in,
    input wire E_in,
    input wire [1:0] Size_in,
    input wire SE_in,
    input wire L_in,
    input wire OutSel_in,

    output reg OS1_out,
    output reg [1:0] OS2_out,
    output reg [3:0] OP_out,
    output reg [2:0] BranchType_out,
    output reg [1:0] WriteCond_out,
    output reg RF_LE_out,
    output reg MemToReg_out,
    output reg RW_out,
    output reg E_out,
    output reg [1:0] Size_out,
    output reg SE_out,
    output reg L_out,
    output reg OutSel_out
);

    always @(*) begin
        if (S) begin
            // Insert a bubble: disable all controls entering ID/EX.
            OS1_out = 1'b0;
            OS2_out = 2'b00;
            OP_out = 4'b0000;
            BranchType_out = 3'b000;
            WriteCond_out = 2'b00;
            RF_LE_out = 1'b0;
            MemToReg_out = 1'b0;
            RW_out = 1'b0;
            E_out = 1'b0;
            Size_out = 2'b00;
            SE_out = 1'b0;
            L_out = 1'b0;
            OutSel_out = 1'b0;
        end
        else begin
            OS1_out = OS1_in;
            OS2_out = OS2_in;
            OP_out = OP_in;
            BranchType_out = BranchType_in;
            WriteCond_out = WriteCond_in;
            RF_LE_out = RF_LE_in;
            MemToReg_out = MemToReg_in;
            RW_out = RW_in;
            E_out = E_in;
            Size_out = Size_in;
            SE_out = SE_in;
            L_out = L_in;
            OutSel_out = OutSel_in;
        end
    end
endmodule
