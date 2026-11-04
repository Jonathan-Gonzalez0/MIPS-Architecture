`timescale 1ns/1ps

// ID/EX stores 154 data bits and 21 control bits, with individual ports.
// The diagram's unconnected "Cl" label is not a separate input here.
// Fase III specifies synchronous Reset and no Load Enable for this register.
module IDEX (
    input wire Clk,
    input wire Reset,

    // Data from Adder8, TAG, forwarding muxes, instruction and destination mux.
    input wire [31:0] PC8_in,
    input wire [31:0] TA_in,
    input wire [31:0] PA_in,
    input wire [31:0] PB_in,
    input wire [4:0] SA_in,
    input wire [15:0] I_in,
    input wire [4:0] RD_in,

    // Control inputs come from the NOP MUX.
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

    // Stored data delivered to EX. I is the 16-bit immediate, not all 32 bits.
    output reg [31:0] PC8_out,
    output reg [31:0] TA_out,
    output reg [31:0] PA_out,
    output reg [31:0] PB_out,
    output reg [4:0] SA_out,
    output reg [15:0] I_out,
    output reg [4:0] RD_out,

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

    always @(posedge Clk) begin
        if (Reset) begin
            PC8_out <= 32'b0;
            TA_out <= 32'b0;
            PA_out <= 32'b0;
            PB_out <= 32'b0;
            SA_out <= 5'b0;
            I_out <= 16'b0;
            RD_out <= 5'b0;

            OS1_out <= 1'b0;
            OS2_out <= 2'b00;
            OP_out <= 4'b0000;
            BranchType_out <= 3'b000;
            WriteCond_out <= 2'b00;
            RF_LE_out <= 1'b0;
            MemToReg_out <= 1'b0;
            RW_out <= 1'b0;
            E_out <= 1'b0;
            Size_out <= 2'b00;
            SE_out <= 1'b0;
            L_out <= 1'b0;
            OutSel_out <= 1'b0;
        end
        else begin
            PC8_out <= PC8_in;
            TA_out <= TA_in;
            PA_out <= PA_in;
            PB_out <= PB_in;
            SA_out <= SA_in;
            I_out <= I_in;
            RD_out <= RD_in;

            OS1_out <= OS1_in;
            OS2_out <= OS2_in;
            OP_out <= OP_in;
            BranchType_out <= BranchType_in;
            WriteCond_out <= WriteCond_in;
            RF_LE_out <= RF_LE_in;
            MemToReg_out <= MemToReg_in;
            RW_out <= RW_in;
            E_out <= E_in;
            Size_out <= Size_in;
            SE_out <= SE_in;
            L_out <= L_in;
            OutSel_out <= OutSel_in;
        end
    end
endmodule
