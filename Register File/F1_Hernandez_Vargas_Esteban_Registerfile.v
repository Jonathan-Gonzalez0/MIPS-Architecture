`timescale 1ns/1ps


// ============================================================
// 32-BIT REGISTER
// ============================================================

module register (
    input  [31:0] Ds,
    input         Ld,
    input         Clk,
    output reg [31:0] Qs
);

    always @(posedge Clk) begin
        if (Ld)
            Qs <= Ds;
    end

endmodule



// ============================================================
// 5-TO-32 DECODER
// ============================================================

module decoder (
    input  [4:0]  RW,
    input         E,
    output [31:0] O
);

    assign O = E ? (32'b1 << RW) : 32'b0;

endmodule



// ============================================================
// 32-TO-1 MULTIPLEXER
// ============================================================

module mux32to1 (
    input [31:0] Q0,
    input [31:0] Q1,
    input [31:0] Q2,
    input [31:0] Q3,
    input [31:0] Q4,
    input [31:0] Q5,
    input [31:0] Q6,
    input [31:0] Q7,
    input [31:0] Q8,
    input [31:0] Q9,
    input [31:0] Q10,
    input [31:0] Q11,
    input [31:0] Q12,
    input [31:0] Q13,
    input [31:0] Q14,
    input [31:0] Q15,
    input [31:0] Q16,
    input [31:0] Q17,
    input [31:0] Q18,
    input [31:0] Q19,
    input [31:0] Q20,
    input [31:0] Q21,
    input [31:0] Q22,
    input [31:0] Q23,
    input [31:0] Q24,
    input [31:0] Q25,
    input [31:0] Q26,
    input [31:0] Q27,
    input [31:0] Q28,
    input [31:0] Q29,
    input [31:0] Q30,
    input [31:0] Q31,

    input [4:0] S,

    output reg [31:0] Y
);

    always @(*) begin
        case (S)

            5'd0:  Y = Q0;
            5'd1:  Y = Q1;
            5'd2:  Y = Q2;
            5'd3:  Y = Q3;
            5'd4:  Y = Q4;
            5'd5:  Y = Q5;
            5'd6:  Y = Q6;
            5'd7:  Y = Q7;
            5'd8:  Y = Q8;
            5'd9:  Y = Q9;
            5'd10: Y = Q10;
            5'd11: Y = Q11;
            5'd12: Y = Q12;
            5'd13: Y = Q13;
            5'd14: Y = Q14;
            5'd15: Y = Q15;
            5'd16: Y = Q16;
            5'd17: Y = Q17;
            5'd18: Y = Q18;
            5'd19: Y = Q19;
            5'd20: Y = Q20;
            5'd21: Y = Q21;
            5'd22: Y = Q22;
            5'd23: Y = Q23;
            5'd24: Y = Q24;
            5'd25: Y = Q25;
            5'd26: Y = Q26;
            5'd27: Y = Q27;
            5'd28: Y = Q28;
            5'd29: Y = Q29;
            5'd30: Y = Q30;
            5'd31: Y = Q31;

            default: Y = 32'bx;

        endcase
    end

endmodule



// ============================================================
// REGISTER FILE
// ============================================================

module register_file (
    input         CLK,
    input         LE,

    input  [4:0]  RW,
    input  [4:0]  RA,
    input  [4:0]  RB,

    input  [31:0] PW,

    output [31:0] PA,
    output [31:0] PB
);


    // --------------------------------------------------------
    // Register output wires
    // --------------------------------------------------------
    wire [31:0] load;
    wire [31:0] Q0;
    wire [31:0] Q1;
    wire [31:0] Q2;
    wire [31:0] Q3;
    wire [31:0] Q4;
    wire [31:0] Q5;
    wire [31:0] Q6;
    wire [31:0] Q7;
    wire [31:0] Q8;
    wire [31:0] Q9;
    wire [31:0] Q10;
    wire [31:0] Q11;
    wire [31:0] Q12;
    wire [31:0] Q13;
    wire [31:0] Q14;
    wire [31:0] Q15;
    wire [31:0] Q16;
    wire [31:0] Q17;
    wire [31:0] Q18;
    wire [31:0] Q19;
    wire [31:0] Q20;
    wire [31:0] Q21;
    wire [31:0] Q22;
    wire [31:0] Q23;
    wire [31:0] Q24;
    wire [31:0] Q25;
    wire [31:0] Q26;
    wire [31:0] Q27;
    wire [31:0] Q28;
    wire [31:0] Q29;
    wire [31:0] Q30;
    wire [31:0] Q31;


    // ========================================================
    // DECODER 
    // ========================================================

    decoder D0 (
        .RW(RW),
        .E(LE),
        .O(load)
    );


    // ========================================================
    // 32 REGISTERS
    // ========================================================

    register R0 (
        .Ds(PW),
        .Ld(load[0]),
        .Clk(CLK),
        .Qs(Q0)
    );

    register R1 (
        .Ds(PW),
        .Ld(load[1]),
        .Clk(CLK),
        .Qs(Q1)
    );

    register R2 (
        .Ds(PW),
        .Ld(load[2]),
        .Clk(CLK),
        .Qs(Q2)
    );

    register R3 (
        .Ds(PW),
        .Ld(load[3]),
        .Clk(CLK),
        .Qs(Q3)
    );

    register R4 (
        .Ds(PW),
        .Ld(load[4]),
        .Clk(CLK),
        .Qs(Q4)
    );

    register R5 (
        .Ds(PW),
        .Ld(load[5]),
        .Clk(CLK),
        .Qs(Q5)
    );

    register R6 (
        .Ds(PW),
        .Ld(load[6]),
        .Clk(CLK),
        .Qs(Q6)
    );

    register R7 (
        .Ds(PW),
        .Ld(load[7]),
        .Clk(CLK),
        .Qs(Q7)
    );

    register R8 (
        .Ds(PW),
        .Ld(load[8]),
        .Clk(CLK),
        .Qs(Q8)
    );

    register R9 (
        .Ds(PW),
        .Ld(load[9]),
        .Clk(CLK),
        .Qs(Q9)
    );

    register R10 (
        .Ds(PW),
        .Ld(load[10]),
        .Clk(CLK),
        .Qs(Q10)
    );

    register R11 (
        .Ds(PW),
        .Ld(load[11]),
        .Clk(CLK),
        .Qs(Q11)
    );

    register R12 (
        .Ds(PW),
        .Ld(load[12]),
        .Clk(CLK),
        .Qs(Q12)
    );

    register R13 (
        .Ds(PW),
        .Ld(load[13]),
        .Clk(CLK),
        .Qs(Q13)
    );

    register R14 (
        .Ds(PW),
        .Ld(load[14]),
        .Clk(CLK),
        .Qs(Q14)
    );

    register R15 (
        .Ds(PW),
        .Ld(load[15]),
        .Clk(CLK),
        .Qs(Q15)
    );

    register R16 (
        .Ds(PW),
        .Ld(load[16]),
        .Clk(CLK),
        .Qs(Q16)
    );

    register R17 (
        .Ds(PW),
        .Ld(load[17]),
        .Clk(CLK),
        .Qs(Q17)
    );

    register R18 (
        .Ds(PW),
        .Ld(load[18]),
        .Clk(CLK),
        .Qs(Q18)
    );

    register R19 (
        .Ds(PW),
        .Ld(load[19]),
        .Clk(CLK),
        .Qs(Q19)
    );

    register R20 (
        .Ds(PW),
        .Ld(load[20]),
        .Clk(CLK),
        .Qs(Q20)
    );

    register R21 (
        .Ds(PW),
        .Ld(load[21]),
        .Clk(CLK),
        .Qs(Q21)
    );

    register R22 (
        .Ds(PW),
        .Ld(load[22]),
        .Clk(CLK),
        .Qs(Q22)
    );

    register R23 (
        .Ds(PW),
        .Ld(load[23]),
        .Clk(CLK),
        .Qs(Q23)
    );

    register R24 (
        .Ds(PW),
        .Ld(load[24]),
        .Clk(CLK),
        .Qs(Q24)
    );

    register R25 (
        .Ds(PW),
        .Ld(load[25]),
        .Clk(CLK),
        .Qs(Q25)
    );

    register R26 (
        .Ds(PW),
        .Ld(load[26]),
        .Clk(CLK),
        .Qs(Q26)
    );

    register R27 (
        .Ds(PW),
        .Ld(load[27]),
        .Clk(CLK),
        .Qs(Q27)
    );

    register R28 (
        .Ds(PW),
        .Ld(load[28]),
        .Clk(CLK),
        .Qs(Q28)
    );

    register R29 (
        .Ds(PW),
        .Ld(load[29]),
        .Clk(CLK),
        .Qs(Q29)
    );

    register R30 (
        .Ds(PW),
        .Ld(load[30]),
        .Clk(CLK),
        .Qs(Q30)
    );

    register R31 (
        .Ds(PW),
        .Ld(load[31]),
        .Clk(CLK),
        .Qs(Q31)
    );


    // ========================================================
    // MUX A
    // ========================================================

    mux32to1 MUX_A (

        .Q0(32'b0),
        .Q1(Q1),
        .Q2(Q2),
        .Q3(Q3),
        .Q4(Q4),
        .Q5(Q5),
        .Q6(Q6),
        .Q7(Q7),
        .Q8(Q8),
        .Q9(Q9),
        .Q10(Q10),
        .Q11(Q11),
        .Q12(Q12),
        .Q13(Q13),
        .Q14(Q14),
        .Q15(Q15),
        .Q16(Q16),
        .Q17(Q17),
        .Q18(Q18),
        .Q19(Q19),
        .Q20(Q20),
        .Q21(Q21),
        .Q22(Q22),
        .Q23(Q23),
        .Q24(Q24),
        .Q25(Q25),
        .Q26(Q26),
        .Q27(Q27),
        .Q28(Q28),
        .Q29(Q29),
        .Q30(Q30),
        .Q31(Q31),

        .S(RA),

        .Y(PA)
    );


    // ========================================================
    // MUX B
    // ========================================================

    mux32to1 MUX_B (

        .Q0(32'b0),
        .Q1(Q1),
        .Q2(Q2),
        .Q3(Q3),
        .Q4(Q4),
        .Q5(Q5),
        .Q6(Q6),
        .Q7(Q7),
        .Q8(Q8),
        .Q9(Q9),
        .Q10(Q10),
        .Q11(Q11),
        .Q12(Q12),
        .Q13(Q13),
        .Q14(Q14),
        .Q15(Q15),
        .Q16(Q16),
        .Q17(Q17),
        .Q18(Q18),
        .Q19(Q19),
        .Q20(Q20),
        .Q21(Q21),
        .Q22(Q22),
        .Q23(Q23),
        .Q24(Q24),
        .Q25(Q25),
        .Q26(Q26),
        .Q27(Q27),
        .Q28(Q28),
        .Q29(Q29),
        .Q30(Q30),
        .Q31(Q31),

        .S(RB),

        .Y(PB)
    );

endmodule



// ============================================================
// TESTBENCH
// ============================================================

module register_file_tb;

    // Inputs to Register File
    reg         CLK;
    reg         LE;

    reg  [4:0]  RW;
    reg  [4:0]  RA;
    reg  [4:0]  RB;

    reg  [31:0] PW;

    // Outputs from Register File
    wire [31:0] PA;
    wire [31:0] PB;


    // ========================================================
    // DEVICE UNDER TEST
    // ========================================================

    register_file DUT (
        .CLK(CLK),
        .LE(LE),

        .RW(RW),
        .RA(RA),
        .RB(RB),

        .PW(PW),

        .PA(PA),
        .PB(PB)
    );

    always #2 CLK = ~CLK;


    // ========================================================
    // TEST SEQUENCE
    // ========================================================

    initial begin

        CLK = 0;
        LE = 1;
        PW = 30;
        RW = 0;
        RA = 0;
        RB = 31;

        repeat (31) begin
            #4;
            PW = PW + 1;
            RW = RW + 1;
            RA = RA + 1;
            RB = RB + 1;

        end

        #4;
        LE = 0;
        PW = 55;
        RW = 0;
        RA = 0;
        RB = 31;

        repeat (4) begin

            #4;

            PW = PW + 1;
            RW = RW + 1;
            RA = RA + 1;
            RB = RB + 1;

        end


        #4;

        $finish;

    end


    initial begin

        $timeformat(-9, 0, "", 0);

        $monitor(
            "Time=%0t  RA=%0d  RB=%0d  RW=%0d  PW=%0d  PA=%0d  PB=%0d",
            $time,
            RA,
            RB,
            RW,
            PW,
            PA,
            PB
        );

    end

endmodule
