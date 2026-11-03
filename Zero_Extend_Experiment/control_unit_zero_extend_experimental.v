`timescale 1ns/1ps

// Experimental adapter: reuse the existing CU for every other instruction.
module ControlUnitZeroExtendExperimental (
    input wire [31:0] I,
    output reg Jump,
    output reg [1:0] RegDst,
    output reg OS1,
    output reg [1:0] OS2,
    output reg [3:0] OP,
    output reg [2:0] BranchType,
    output reg [1:0] WriteCond,
    output reg RF_LE,
    output reg MemToReg,
    output reg RW,
    output reg E,
    output reg [1:0] Size,
    output reg SE,
    output reg L,
    output reg OutSel,
    output reg SRA,
    output reg SRB
);
    reg logical_immediate;
    reg [31:0] baseline_instruction;
    wire base_Jump;
    wire [1:0] base_RegDst;
    wire base_OS1;
    wire [1:0] base_OS2;
    wire [3:0] base_OP;
    wire [2:0] base_BranchType;
    wire [1:0] base_WriteCond;
    wire base_RF_LE;
    wire base_MemToReg;
    wire base_RW;
    wire base_E;
    wire [1:0] base_Size;
    wire base_SE;
    wire base_L;
    wire base_OutSel;
    wire base_SRA;
    wire base_SRB;

    // Select both values in one step; never pass a logical opcode transiently.
    always @(*) begin
        case (I[31:26])
            6'b001100, 6'b001101, 6'b001110: begin
                logical_immediate = 1'b1;
                baseline_instruction = 32'b0;
            end
            default: begin
                logical_immediate = 1'b0;
                baseline_instruction = I;
            end
        endcase
    end

    ControlUnit baseline (
        .I(baseline_instruction),
        .Jump(base_Jump),
        .RegDst(base_RegDst),
        .OS1(base_OS1),
        .OS2(base_OS2),
        .OP(base_OP),
        .BranchType(base_BranchType),
        .WriteCond(base_WriteCond),
        .RF_LE(base_RF_LE),
        .MemToReg(base_MemToReg),
        .RW(base_RW),
        .E(base_E),
        .Size(base_Size),
        .SE(base_SE),
        .L(base_L),
        .OutSel(base_OutSel),
        .SRA(base_SRA),
        .SRB(base_SRB)
    );

    always @(*) begin
        Jump = base_Jump;
        RegDst = base_RegDst;
        OS1 = base_OS1;
        OS2 = base_OS2;
        OP = base_OP;
        BranchType = base_BranchType;
        WriteCond = base_WriteCond;
        RF_LE = base_RF_LE;
        MemToReg = base_MemToReg;
        RW = base_RW;
        E = base_E;
        Size = base_Size;
        SE = base_SE;
        L = base_L;
        OutSel = base_OutSel;
        SRA = base_SRA;
        SRB = base_SRB;
        if (logical_immediate) begin
            Jump = 1'b0;
            RegDst = 2'b00;
            OS1 = 1'b0;
            OS2 = 2'b11;        // Zero-extended immediate
            BranchType = 3'b000;
            WriteCond = 2'b00;
            RF_LE = 1'b1;
            MemToReg = 1'b1;
            RW = 1'b0;
            E = 1'b0;
            Size = 2'b00;
            SE = 1'b0;
            L = 1'b0;
            OutSel = 1'b0;
            SRA = 1'b1;         // rs is a source
            SRB = 1'b0;         // rt is a destination
            case (I[31:26])
                6'b001100: OP = 4'b0010; // ANDI
                6'b001101: OP = 4'b0011; // ORI
                6'b001110: OP = 4'b0100; // XORI
                default: OP = 4'b0000;
            endcase
        end
    end
endmodule
