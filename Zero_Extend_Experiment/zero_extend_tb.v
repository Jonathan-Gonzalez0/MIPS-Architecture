`timescale 1ns/1ps

module zero_extend_tb;
    reg [31:0] I;
    reg [31:0] reference_I;
    reg [31:0] RA;
    reg [31:0] RB;
    wire Jump;
    wire reference_Jump;
    wire [1:0] RegDst;
    wire [1:0] reference_RegDst;
    wire OS1;
    wire reference_OS1;
    wire [1:0] OS2;
    wire [1:0] reference_OS2;
    wire [3:0] OP;
    wire [3:0] reference_OP;
    wire [2:0] BranchType;
    wire [2:0] reference_BranchType;
    wire [1:0] WriteCond;
    wire [1:0] reference_WriteCond;
    wire RF_LE;
    wire reference_RF_LE;
    wire MemToReg;
    wire reference_MemToReg;
    wire RW;
    wire reference_RW;
    wire E;
    wire reference_E;
    wire [1:0] Size;
    wire [1:0] reference_Size;
    wire SE;
    wire reference_SE;
    wire L;
    wire reference_L;
    wire OutSel;
    wire reference_OutSel;
    wire SRA;
    wire reference_SRA;
    wire SRB;
    wire reference_SRB;
    wire [25:0] controls;
    wire [25:0] reference_controls;
    wire [31:0] OA;
    wire [31:0] OB;
    wire [31:0] Out;
    wire LE;
    wire EQ;
    wire GT;
    wire [4:0] RD;
    wire [31:0] reference_Out;
    wire reference_LE;
    wire reference_EQ;
    wire reference_GT;
    reg [3:0] expected_OP;
    reg [31:0] expected_Out;
    reg [5:0] opcode;
    reg [15:0] immediate;
    reg [255:0] instruction_name;
    reg [7:0] program_bytes [0:99];
    integer operation_number;
    integer immediate_number;
    integer operand_number;
    integer word_number;
    integer passed;
    integer failed;

    reg [31:0] probe_RB;
    reg [15:0] probe_I;
    reg [1:0] probe_OS2;
    wire [31:0] probe_OB;
    wire [31:0] original_probe_OB;
    reg [31:0] expected_probe_OB;
    integer selector_number;

    assign controls = {Jump, RegDst, OS1, OS2, OP, BranchType, WriteCond, RF_LE, MemToReg, RW, E, Size, SE, L, OutSel, SRA, SRB};
    assign reference_controls = {reference_Jump, reference_RegDst, reference_OS1, reference_OS2, reference_OP, reference_BranchType, reference_WriteCond, reference_RF_LE, reference_MemToReg, reference_RW, reference_E, reference_Size, reference_SE, reference_L, reference_OutSel, reference_SRA, reference_SRB};
    ControlUnitZeroExtendExperimental proposed_control (
        .I(I),
        .Jump(Jump),
        .RegDst(RegDst),
        .OS1(OS1),
        .OS2(OS2),
        .OP(OP),
        .BranchType(BranchType),
        .WriteCond(WriteCond),
        .RF_LE(RF_LE),
        .MemToReg(MemToReg),
        .RW(RW),
        .E(E),
        .Size(Size),
        .SE(SE),
        .L(L),
        .OutSel(OutSel),
        .SRA(SRA),
        .SRB(SRB)
    );
    ControlUnit original_control (
        .I(reference_I),
        .Jump(reference_Jump),
        .RegDst(reference_RegDst),
        .OS1(reference_OS1),
        .OS2(reference_OS2),
        .OP(reference_OP),
        .BranchType(reference_BranchType),
        .WriteCond(reference_WriteCond),
        .RF_LE(reference_RF_LE),
        .MemToReg(reference_MemToReg),
        .RW(reference_RW),
        .E(reference_E),
        .Size(reference_Size),
        .SE(reference_SE),
        .L(reference_L),
        .OutSel(reference_OutSel),
        .SRA(reference_SRA),
        .SRB(reference_SRB)
    );
    foh first_operand (
        .RA(RA), .SA(I[10:6]), .OS1(OS1), .OA(OA)
    );
    SOHZeroExtendExperimental second_operand (
        .RB(RB), .I(I[15:0]), .OS2(OS2), .OB(OB)
    );
    alu calculator (
        .A(OA), .B(OB), .OP(OP), .LE(LE), .EQ(EQ), .GT(GT), .Out(Out)
    );
    PhaseIIIRegDstMux destination (
        .RT(I[20:16]), .RD(I[15:11]), .RegDst(RegDst), .Out(RD)
    );
    alu_system original_calculator (
        .RA(RA), .SA(reference_I[10:6]), .OS1(reference_OS1),
        .RB(RB), .I(reference_I[15:0]), .OS2(reference_OS2), .OP(reference_OP),
        .LE(reference_LE), .EQ(reference_EQ), .GT(reference_GT), .Out(reference_Out)
    );
    SOHZeroExtendExperimental proposed_probe (
        .RB(probe_RB), .I(probe_I), .OS2(probe_OS2), .OB(probe_OB)
    );
    soh original_probe (
        .RB(probe_RB), .I(probe_I), .OS2(probe_OS2), .OB(original_probe_OB)
    );

    initial begin
        passed = 0;
        failed = 0;
        I = 32'b0;
        reference_I = 32'b0;
        RA = 32'b0;
        RB = 32'b0;
        probe_RB = 32'b0;
        probe_I = 16'b0;
        probe_OS2 = 2'b00;
        $readmemb("Instruction Memory/test_instructions_memory.txt", program_bytes, 0, 99);

        // 48 checks: preserve the three old choices and verify the new fourth.
        for (operand_number = 0; operand_number < 3; operand_number = operand_number + 1) begin
            case (operand_number)
                0: probe_RB = 32'b0;
                1: probe_RB = 32'hA5A55A5A;
                2: probe_RB = 32'hFFFFFFFF;
            endcase
            for (immediate_number = 0; immediate_number < 4; immediate_number = immediate_number + 1) begin
                case (immediate_number)
                    0: probe_I = 16'h0000;
                    1: probe_I = 16'h7FFF;
                    2: probe_I = 16'h8001;
                    3: probe_I = 16'hFFFF;
                endcase
                for (selector_number = 0; selector_number < 4; selector_number = selector_number + 1) begin
                    case (selector_number)
                        0: begin probe_OS2 = 2'b00; expected_probe_OB = probe_RB; end
                        1: begin probe_OS2 = 2'b01; expected_probe_OB = {{16{probe_I[15]}}, probe_I}; end
                        2: begin probe_OS2 = 2'b10; expected_probe_OB = {probe_I, 16'b0}; end
                        3: begin probe_OS2 = 2'b11; expected_probe_OB = {16'b0, probe_I}; end
                    endcase
                    #1;
                    if ((probe_OB === expected_probe_OB) &&
                        (((probe_OS2 != 2'b11) && (probe_OB === original_probe_OB)) ||
                         ((probe_OS2 == 2'b11) && (original_probe_OB === 32'b0))))
                        passed = passed + 1;
                    else begin
                        failed = failed + 1;
                        $display("FAIL: SOH OS2=%b I=%h new=%h old=%h expected=%h",
                                 probe_OS2, probe_I, probe_OB, original_probe_OB, expected_probe_OB);
                    end
                end
            end
        end

        for (operation_number = 0; operation_number < 3; operation_number = operation_number + 1) begin
            case (operation_number)
                0: begin opcode = 6'b001100; expected_OP = 4'b0010; instruction_name = "ANDI"; end
                1: begin opcode = 6'b001101; expected_OP = 4'b0011; instruction_name = "ORI"; end
                2: begin opcode = 6'b001110; expected_OP = 4'b0100; instruction_name = "XORI"; end
            endcase
            for (immediate_number = 0; immediate_number < 4; immediate_number = immediate_number + 1) begin
                case (immediate_number)
                    0: immediate = 16'h0000;
                    1: immediate = 16'h7FFF;
                    2: immediate = 16'h8001;
                    3: immediate = 16'hFFFF;
                endcase
                for (operand_number = 0; operand_number < 4; operand_number = operand_number + 1) begin
                    case (operand_number)
                        0: RA = 32'h00000000;
                        1: RA = 32'hFFFFFFFF;
                        2: RA = 32'hA5A55A5A;
                        3: RA = 32'h80000000;
                    endcase
                    RB = 32'hDEADBEEF; // Must not be used by an immediate instruction.
                    I = {opcode, 5'd1, 5'd5, immediate};
                    case (operation_number)
                        0: expected_Out = RA & {16'b0, immediate};
                        1: expected_Out = RA | {16'b0, immediate};
                        2: expected_Out = RA ^ {16'b0, immediate};
                    endcase
                    #1;
                    // Order: Jump, RegDst, OS1, OS2, OP, BranchType, WriteCond,
                    // RF_LE, MemToReg, RW, E, Size, SE, L, OutSel, SRA, SRB.
                    if (controls === {1'b0, 2'b00, 1'b0, 2'b11, expected_OP,
                                      3'b000, 2'b00, 1'b1, 1'b1, 1'b0, 1'b0,
                                      2'b00, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0})
                        passed = passed + 1;
                    else begin
                        failed = failed + 1;
                        $display("FAIL: controls %0s OP=%b OS2=%b RegDst=%b RF_LE=%b MemToReg=%b SRA=%b SRB=%b",
                                 instruction_name, OP, OS2, RegDst, RF_LE, MemToReg, SRA, SRB);
                    end
                    if ((OA === RA) && (OB === {16'b0, immediate}) &&
                        (Out === expected_Out) && (RD === 5'd5) &&
                        (LE === expected_Out[31]) &&
                        (EQ === (expected_Out == 32'b0)) &&
                        (GT === (!expected_Out[31] && (expected_Out != 32'b0))))
                        passed = passed + 1;
                    else begin
                        failed = failed + 1;
                        $display("FAIL: numeric %0s actual=%h expected=%h OB=%h RD=%0d",
                                 instruction_name, Out, expected_Out, OB, RD);
                    end
                    $display("%0s rs=%h imm=%h result=%h expected=%h",
                             instruction_name, RA, immediate, Out, expected_Out);
                end
            end
        end

        // Compare every real ROM word with the original CU and ALU system.
        for (word_number = 0; word_number < 25; word_number = word_number + 1) begin
            I = {program_bytes[4*word_number], program_bytes[4*word_number+1],
                 program_bytes[4*word_number+2], program_bytes[4*word_number+3]};
            reference_I = I;
            RA = 32'h80000009;
            RB = 32'd3;
            #1;
            if (controls === reference_controls) passed = passed + 1;
            else begin
                failed = failed + 1;
                $display("FAIL: legacy controls PC=%0d I=%h", 4*word_number, I);
            end
            if ((Out === reference_Out) && (LE === reference_LE) &&
                (EQ === reference_EQ) && (GT === reference_GT))
                passed = passed + 1;
            else begin
                failed = failed + 1;
                $display("FAIL: legacy ALU PC=%0d I=%h new=%h old=%h",
                         4*word_number, I, Out, reference_Out);
            end
        end
        $display("ZERO_EXTEND_RESULT: passed=%0d failed=%0d total=%0d", passed, failed, passed + failed);
        if (failed != 0) $stop;
        $finish;
    end
endmodule
