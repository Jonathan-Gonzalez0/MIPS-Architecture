`timescale 1ns/1ps

module PhaseIIIMux32 (
    input wire [31:0] A,
    input wire [31:0] B,
    input wire S,
    output reg [31:0] Out
);
    always @(*) begin
        if (S) Out = B;
        else Out = A;
    end
endmodule

module PhaseIIIRegDstMux (
    input wire [4:0] RT,
    input wire [4:0] RD,
    input wire [1:0] RegDst,
    output reg [4:0] Out
);
    always @(*) begin
        case (RegDst)
            2'b00: Out = RT;
            2'b01: Out = RD;
            2'b10: Out = 5'd31;
            2'b11: Out = 5'd0;
            default: Out = 5'b0;
        endcase
    end
endmodule

module PhaseIIIBranchControl (
    input wire LE,
    input wire EQ,
    input wire GT,
    input wire [2:0] BranchType,
    output reg BranchTaken
);
    always @(*) begin
        case (BranchType)
            3'b000: BranchTaken = 1'b0;
            3'b001: BranchTaken = EQ;
            3'b010: BranchTaken = !LE;
            3'b011: BranchTaken = GT;
            3'b100: BranchTaken = LE || EQ;
            3'b101: BranchTaken = LE;
            3'b110: BranchTaken = !EQ;
            default: BranchTaken = 1'b0;
        endcase
    end
endmodule

module PhaseIIIWriteCondition (
    input wire [31:0] B,
    input wire [1:0] WriteCond,
    input wire BranchTaken,
    output reg Allowed
);
    always @(*) begin
        case (WriteCond)
            2'b00: Allowed = 1'b1;
            2'b01: Allowed = (B != 32'b0);
            2'b10: Allowed = (B == 32'b0);
            2'b11: Allowed = BranchTaken;
            default: Allowed = 1'b0;
        endcase
    end
endmodule
