`timescale 1ns/1ps

// Unit test of the decoder, not the complete pipelined Phase III circuit.
module control_unit_tb;
    reg [31:0] I;
    wire Jump;
    wire [1:0] RegDst;
    wire OS1;
    wire [1:0] OS2;
    wire [3:0] OP;
    wire [2:0] BranchType;
    wire [1:0] WriteCond;
    wire RF_LE;
    wire MemToReg;
    wire RW;
    wire E;
    wire [1:0] Size;
    wire SE;
    wire L;
    wire OutSel;
    wire SRA;
    wire SRB;

    reg expected_Jump;
    reg [1:0] expected_RegDst;
    reg expected_OS1;
    reg [1:0] expected_OS2;
    reg [3:0] expected_OP;
    reg [2:0] expected_BranchType;
    reg [1:0] expected_WriteCond;
    reg expected_RF_LE;
    reg expected_MemToReg;
    reg expected_RW;
    reg expected_E;
    reg [1:0] expected_Size;
    reg expected_SE;
    reg expected_L;
    reg expected_OutSel;
    reg expected_SRA;
    reg expected_SRB;

    reg [255:0] instruction_name;
    integer test_number;
    integer passed;
    integer failed;

    ControlUnit control (
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

    initial begin
        passed = 0;
        failed = 0;

        for (test_number = 0; test_number < 25; test_number = test_number + 1) begin
            expected_Jump = 1'b0;
            expected_RegDst = 2'b00;
            expected_OS1 = 1'b0;
            expected_OS2 = 2'b00;
            expected_OP = 4'b0000;
            expected_BranchType = 3'b000;
            expected_WriteCond = 2'b00;
            expected_RF_LE = 1'b0;
            expected_MemToReg = 1'b0;
            expected_RW = 1'b0;
            expected_E = 1'b0;
            expected_Size = 2'b00;
            expected_SE = 1'b0;
            expected_L = 1'b0;
            expected_OutSel = 1'b0;
            expected_SRA = 1'b0;
            expected_SRB = 1'b0;

            case (test_number)
                0: begin
                    I = 32'h20050000;
                    instruction_name = "ADDI r5,r0,0";
                    expected_OS2 = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                end

                1: begin
                    I = 32'h00031822;
                    instruction_name = "SUB r3,r0,r3";
                    expected_OP = 4'b0001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                end

                2: begin
                    I = 32'h90220000;
                    instruction_name = "LBU r2,0(r1)";
                    expected_OS2 = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_SRA = 1'b1;
                end

                3: begin
                    I = 32'h84220000;
                    instruction_name = "LH r2,0(r1)";
                    expected_OS2 = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_Size = 2'b01;
                    expected_SE = 1'b1;
                    expected_L = 1'b1;
                    expected_SRA = 1'b1;
                end

                4: begin
                    I = 32'hAC250001;
                    instruction_name = "SW r5,1(r1)";
                    expected_OS2 = 2'b01;
                    expected_RW = 1'b1;
                    expected_E = 1'b1;
                    expected_Size = 2'b10;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                end

                5: begin
                    I = 32'h00031903;
                    instruction_name = "SRA r3,r3,4";
                    expected_OP = 4'b1011;
                    expected_OS1 = 1'b1;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRB = 1'b1;
                end

                6: begin
                    I = 32'h00233904;
                    // Actual fields: rs=1, rt=3, rd=7, unused sa=4.
                    // The PDF label SLLV r3,r1,r7 does not match these bits.
                    instruction_name = "SLLV r7,r3,r1 (sa=4 ignored)";
                    expected_OP = 4'b1001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                end

                7: begin
                    I = 32'h00000000;
                    instruction_name = "NOP";
                end

                8: begin
                    I = 32'h0003180A;
                    instruction_name = "MOVZ r3,r0,r3";
                    expected_OP = 4'b0111;
                    expected_RegDst = 2'b01;
                    expected_WriteCond = 2'b10;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                end

                9: begin
                    I = 32'h0471FFFD;
                    // rs=3, rt=10001: BGEZAL, not unconditional BAL.
                    // The PDF uses both labels BGZAL and BAL for this word.
                    instruction_name = "BGEZAL r3,-3";
                    expected_OP = 4'b0111;
                    expected_RegDst = 2'b10;
                    expected_BranchType = 3'b010;
                    expected_WriteCond = 2'b11;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_OutSel = 1'b1;
                    expected_SRA = 1'b1;
                end

                10: begin
                    I = 32'h1060FFFD;
                    // rs=3, rt=0: BEQ r3,r0,-3, not unconditional B.
                    instruction_name = "BEQ r3,r0,-3";
                    expected_OP = 4'b0001;
                    expected_BranchType = 3'b001;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                end

                11: begin
                    I = 32'h1C60FFFD;
                    instruction_name = "BGTZ r3,-3";
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b011;
                    expected_SRA = 1'b1;
                end

                12: begin
                    I = 32'h0C000004;
                    // index=4 means target 0x10 when the upper PC bits are 0.
                    // It is not a PC-relative displacement of four bytes.
                    instruction_name = "JAL index=4 (target=0x10)";
                    expected_Jump = 1'b1;
                    expected_RegDst = 2'b10;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_OutSel = 1'b1;
                end

                13: begin
                    I = 32'h03E00008;
                    instruction_name = "JR r31";
                    expected_Jump = 1'b1;
                    expected_OP = 4'b0111;
                    expected_SRA = 1'b1;
                end

                14: begin
                    I = 32'h3C053F0F;
                    instruction_name = "LUI r5,0x3F0F";
                    expected_OP = 4'b1000;
                    expected_OS2 = 2'b10;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                end

                15: begin
                    I = 32'h24050000;
                    instruction_name = "ADDIU r5,r0,0";
                    expected_OS2 = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                end

                16: begin
                    I = 32'h1000FFFD;       // BEQ r0,r0,-3
                    instruction_name = "B -3 (unconditional)";
                    expected_Jump = 1'b1;
                end

                17: begin
                    I = 32'h0411FFFD;       // BGEZAL r0,-3
                    instruction_name = "BAL -3 (unconditional)";
                    expected_Jump = 1'b1;
                    expected_OP = 4'b0111;
                    expected_RegDst = 2'b10;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_OutSel = 1'b1;
                end

                18: begin
                    I = 32'h00233804;
                    instruction_name = "SLLV r7,r3,r1 (sa=0)";
                    expected_OP = 4'b1001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                end

                19: begin
                    I = 32'hFC000000;
                    instruction_name = "INVALID opcode=111111";
                end

                20: begin
                    I = 32'h00000000;
                    instruction_name = "NOP after invalid instruction";
                end

                21: begin
                    I = 32'h0000003F;
                    instruction_name = "INVALID function=111111";
                end

                22: begin
                    I = 32'h047FFFFD;
                    instruction_name = "INVALID REGIMM rt=11111";
                end

                23: begin
                    I = 32'h1C61FFFD;
                    instruction_name = "INVALID BGTZ rt=00001";
                end

                24: begin
                    I = 32'h2025FFFF;
                    instruction_name = "ADDI r5,r1,-1 after invalid";
                    expected_OS2 = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                end
            endcase

            #1;
            $display("\nTest %0d: %0s, I=%h", test_number + 1, instruction_name, I);
            $display("Fields: opcode=%b rs=%0d rt=%0d rd=%0d sa=%0d function=%b",
                     I[31:26], I[25:21], I[20:16], I[15:11], I[10:6], I[5:0]);
            $display("Jump=%b RegDst=%b OS1=%b OS2=%b OP=%b BranchType=%b WriteCond=%b",
                     Jump, RegDst, OS1, OS2, OP, BranchType, WriteCond);
            $display("RF_LE=%b MemToReg=%b RW=%b E=%b Size=%b SE=%b L=%b OutSel=%b SRA=%b SRB=%b",
                     RF_LE, MemToReg, RW, E, Size, SE, L, OutSel, SRA, SRB);

            // Case equality (===) also rejects unexpected X or Z outputs.
            if ((Jump === expected_Jump) &&
                (RegDst === expected_RegDst) &&
                (OS1 === expected_OS1) &&
                (OS2 === expected_OS2) &&
                (OP === expected_OP) &&
                (BranchType === expected_BranchType) &&
                (WriteCond === expected_WriteCond) &&
                (RF_LE === expected_RF_LE) &&
                (MemToReg === expected_MemToReg) &&
                (RW === expected_RW) &&
                (E === expected_E) &&
                (Size === expected_Size) &&
                (SE === expected_SE) &&
                (L === expected_L) &&
                (OutSel === expected_OutSel) &&
                (SRA === expected_SRA) &&
                (SRB === expected_SRB)) begin
                passed = passed + 1;
                $display("PASS: all 17 control signals match.");
            end
            else begin
                failed = failed + 1;
                $display("FAIL: expected the following values:");
                $display("Jump=%b RegDst=%b OS1=%b OS2=%b OP=%b BranchType=%b WriteCond=%b",
                         expected_Jump, expected_RegDst, expected_OS1, expected_OS2,
                         expected_OP, expected_BranchType, expected_WriteCond);
                $display("RF_LE=%b MemToReg=%b RW=%b E=%b Size=%b SE=%b L=%b OutSel=%b SRA=%b SRB=%b",
                         expected_RF_LE, expected_MemToReg, expected_RW, expected_E,
                         expected_Size, expected_SE, expected_L, expected_OutSel,
                         expected_SRA, expected_SRB);
            end
        end

        $display("\nRESULT: passed=%0d failed=%0d total=%0d", passed, failed, passed + failed);
        if (failed != 0) begin
            $stop;
        end
        $finish;
    end
endmodule

// Numeric tests check the decoder together with the real operand handlers/ALU.
// Branch Control and Write Condition below are testbench models of the diagram.
// This does not implement Data Memory, TAG, NOP MUX or pipeline registers.
module control_unit_alu_tb;
    reg [31:0] I;
    reg [31:0] RA;
    reg [31:0] RB;
    reg [31:0] PC;

    wire Jump;
    wire [1:0] RegDst;
    wire OS1;
    wire [1:0] OS2;
    wire [3:0] OP;
    wire [2:0] BranchType;
    wire [1:0] WriteCond;
    wire RF_LE;
    wire MemToReg;
    wire RW;
    wire E;
    wire [1:0] Size;
    wire SE;
    wire L;
    wire OutSel;
    wire SRA;
    wire SRB;

    wire [31:0] Out;
    wire LE;
    wire EQ;
    wire GT;
    reg BranchTaken;
    reg write_condition;
    wire register_write;
    wire redirect_pc;
    wire [31:0] ALU_or_PC8;

    reg [31:0] expected_Out;
    reg expected_BranchTaken;
    reg expected_register_write;
    reg expected_redirect_pc;
    reg [31:0] expected_ALU_or_PC8;
    reg [255:0] instruction_name;
    integer test_number;
    integer passed;
    integer failed;

    ControlUnit control (
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

    alu_system calculator (
        .RA(RA),
        .SA(I[10:6]),
        .OS1(OS1),
        .RB(RB),
        .I(I[15:0]),
        .OS2(OS2),
        .OP(OP),
        .LE(LE),
        .EQ(EQ),
        .GT(GT),
        .Out(Out)
    );

    // BranchType encodings come from the Phase II control-reference table.
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

    always @(*) begin
        case (WriteCond)
            2'b00: write_condition = 1'b1;
            2'b01: write_condition = (RB != 32'b0);
            2'b10: write_condition = (RB == 32'b0);
            2'b11: write_condition = BranchTaken;
            default: write_condition = 1'b0;
        endcase
    end

    assign register_write = RF_LE && write_condition;
    assign redirect_pc = Jump || BranchTaken;
    assign ALU_or_PC8 = OutSel ? (PC + 32'd8) : Out;

    initial begin
        passed = 0;
        failed = 0;
        PC = 32'd100;                 // Expected link value is always 108.

        for (test_number = 0; test_number < 26; test_number = test_number + 1) begin
            RA = 32'd0;
            RB = 32'd0;
            expected_Out = 32'd0;
            expected_BranchTaken = 1'b0;
            expected_register_write = 1'b0;
            expected_redirect_pc = 1'b0;

            case (test_number)
                0: begin
                    I = 32'h20250003;
                    instruction_name = "ADDI: 10 + 3";
                    RA = 32'd10;
                    expected_Out = 32'd13;
                    expected_register_write = 1'b1;
                end
                1: begin
                    I = 32'h2425FFFF;
                    instruction_name = "ADDIU: signed immediate -1";
                    expected_Out = 32'hFFFFFFFF;
                    expected_register_write = 1'b1;
                end
                2: begin
                    I = 32'h00221822;
                    instruction_name = "SUB: 10 - 3";
                    RA = 32'd10;
                    RB = 32'd3;
                    expected_Out = 32'd7;
                    expected_register_write = 1'b1;
                end
                3: begin
                    I = 32'h90220000;
                    instruction_name = "LBU: effective address 16";
                    RA = 32'd16;
                    expected_Out = 32'd16;
                    expected_register_write = 1'b1;
                end
                4: begin
                    I = 32'h8422FFFE;
                    instruction_name = "LH: effective address 16 - 2";
                    RA = 32'd16;
                    expected_Out = 32'd14;
                    expected_register_write = 1'b1;
                end
                5: begin
                    I = 32'hAC250001;
                    instruction_name = "SW: base + imm, not base + rt";
                    RA = 32'd16;
                    RB = 32'hA5A5A5A5;
                    expected_Out = 32'd17;
                end
                6: begin
                    I = 32'h00031903;
                    instruction_name = "SRA: -16 >>> 4 = -1";
                    RB = 32'hFFFFFFF0;
                    expected_Out = 32'hFFFFFFFF;
                    expected_register_write = 1'b1;
                end
                7: begin
                    I = 32'h00233904;
                    instruction_name = "SLLV demo: 3 << 2 = 12";
                    RA = 32'd2;
                    RB = 32'd3;
                    expected_Out = 32'd12;
                    expected_register_write = 1'b1;
                end
                8: begin
                    I = 32'h00233804;
                    instruction_name = "SLLV: only low 5 bits of rs";
                    RA = 32'd34;
                    RB = 32'd3;
                    expected_Out = 32'd12;
                    expected_register_write = 1'b1;
                end
                9: begin
                    I = 32'h0022180A;
                    instruction_name = "MOVZ: rt value is zero, write";
                    RA = 32'd7;
                    expected_Out = 32'd7;
                    expected_register_write = 1'b1;
                end
                10: begin
                    I = 32'h0022180A;
                    instruction_name = "MOVZ: rt value is 5, no write";
                    RA = 32'd7;
                    RB = 32'd5;
                    expected_Out = 32'd7;
                end
                11: begin
                    I = 32'h0471FFFD;
                    instruction_name = "BGEZAL: negative, no link";
                    RA = 32'hFFFFFFFF;
                    expected_Out = 32'hFFFFFFFF;
                end
                12: begin
                    I = 32'h0471FFFD;
                    instruction_name = "BGEZAL: zero, branch and link";
                    expected_BranchTaken = 1'b1;
                    expected_register_write = 1'b1;
                    expected_redirect_pc = 1'b1;
                end
                13: begin
                    I = 32'h0471FFFD;
                    instruction_name = "BGEZAL: positive, branch/link";
                    RA = 32'd1;
                    expected_Out = 32'd1;
                    expected_BranchTaken = 1'b1;
                    expected_register_write = 1'b1;
                    expected_redirect_pc = 1'b1;
                end
                14: begin
                    I = 32'h1022FFFD;
                    instruction_name = "BEQ: equal registers, branch";
                    RA = 32'd7;
                    RB = 32'd7;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                end
                15: begin
                    I = 32'h1022FFFD;
                    instruction_name = "BEQ: unequal registers";
                    RA = 32'd7;
                    RB = 32'd8;
                    expected_Out = 32'hFFFFFFFF;
                end
                16: begin
                    I = 32'h1C60FFFD;
                    instruction_name = "BGTZ: negative, no branch";
                    RA = 32'hFFFFFFFF;
                    expected_Out = 32'hFFFFFFFF;
                end
                17: begin
                    I = 32'h1C60FFFD;
                    instruction_name = "BGTZ: zero, no branch";
                end
                18: begin
                    I = 32'h1C60FFFD;
                    instruction_name = "BGTZ: positive, branch";
                    RA = 32'd1;
                    expected_Out = 32'd1;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                end
                19: begin
                    I = 32'h0C000004;
                    instruction_name = "JAL: redirect and save PC + 8";
                    expected_register_write = 1'b1;
                    expected_redirect_pc = 1'b1;
                end
                20: begin
                    I = 32'h03E00008;
                    instruction_name = "JR: redirect without link";
                    RA = 32'h00000040;
                    expected_Out = 32'h00000040;
                    expected_redirect_pc = 1'b1;
                end
                21: begin
                    I = 32'h3C053F0F;
                    instruction_name = "LUI: 0x3F0F0000";
                    expected_Out = 32'h3F0F0000;
                    expected_register_write = 1'b1;
                end
                22: begin
                    I = 32'h1000FFFD;
                    instruction_name = "B: unconditional, no link";
                    expected_redirect_pc = 1'b1;
                end
                23: begin
                    I = 32'h0411FFFD;
                    instruction_name = "BAL: unconditional, link";
                    expected_register_write = 1'b1;
                    expected_redirect_pc = 1'b1;
                end
                24: begin
                    I = 32'h00000000;
                    instruction_name = "NOP: no write or redirect";
                end
                25: begin
                    I = 32'hFC000000;
                    instruction_name = "INVALID: no write or redirect";
                end
            endcase

            // Check the Output MUX against instruction semantics, not OutSel.
            if ((test_number == 11) || (test_number == 12) ||
                (test_number == 13) || (test_number == 19) ||
                (test_number == 23)) begin
                expected_ALU_or_PC8 = 32'd108;
            end
            else begin
                expected_ALU_or_PC8 = expected_Out;
            end

            #1;
            $display("\nALU test %0d: %0s, I=%h RA=%h RB=%h",
                     test_number + 1, instruction_name, I, RA, RB);
            $display("Out=%h LE=%b EQ=%b GT=%b BranchTaken=%b register_write=%b redirect_pc=%b ALU_or_PC8=%h",
                     Out, LE, EQ, GT, BranchTaken, register_write, redirect_pc, ALU_or_PC8);

            if ((Out === expected_Out) &&
                (LE === expected_Out[31]) &&
                (EQ === (expected_Out == 32'b0)) &&
                (GT === (!expected_Out[31] && (expected_Out != 32'b0))) &&
                (BranchTaken === expected_BranchTaken) &&
                (register_write === expected_register_write) &&
                (redirect_pc === expected_redirect_pc) &&
                (ALU_or_PC8 === expected_ALU_or_PC8)) begin
                passed = passed + 1;
                $display("PASS: numeric result, flags and control effects match.");
            end
            else begin
                failed = failed + 1;
                $display("FAIL: expected Out=%h BranchTaken=%b register_write=%b redirect_pc=%b ALU_or_PC8=%h",
                         expected_Out, expected_BranchTaken, expected_register_write,
                         expected_redirect_pc, expected_ALU_or_PC8);
            end
        end

        // Load tests above validate address generation, not loaded memory data.
        $display("\nALU_RESULT: passed=%0d failed=%0d total=%0d", passed, failed, passed + failed);
        if (failed != 0) begin
            $stop;
        end
        $finish;
    end
endmodule

// Extended tests live in a separate top so the old 25/26 tests stay intact.
// Run with -s control_unit_coverage_tb and the real FOH, SOH, ALU and stage logic.
// The unchanged run_checks scripts select the original tops and counts only.
// Load/store tests check addresses and controls, not a Data Memory implementation.
module control_unit_coverage_tb;
    reg [31:0] I;
    reg [31:0] RA;
    reg [31:0] RB;
    wire Jump;
    reg expected_Jump;
    wire [1:0] RegDst;
    reg [1:0] expected_RegDst;
    wire OS1;
    reg expected_OS1;
    wire [1:0] OS2;
    reg [1:0] expected_OS2;
    wire [3:0] OP;
    reg [3:0] expected_OP;
    wire [2:0] BranchType;
    reg [2:0] expected_BranchType;
    wire [1:0] WriteCond;
    reg [1:0] expected_WriteCond;
    wire RF_LE;
    reg expected_RF_LE;
    wire MemToReg;
    reg expected_MemToReg;
    wire RW;
    reg expected_RW;
    wire E;
    reg expected_E;
    wire [1:0] Size;
    reg [1:0] expected_Size;
    wire SE;
    reg expected_SE;
    wire L;
    reg expected_L;
    wire OutSel;
    reg expected_OutSel;
    wire SRA;
    reg expected_SRA;
    wire SRB;
    reg expected_SRB;
    wire [31:0] OA;
    wire [31:0] OB;
    wire [31:0] Out;
    wire LE;
    wire EQ;
    wire GT;
    wire BranchTaken;
    wire write_allowed;
    wire register_write;
    wire redirect_pc;
    wire [4:0] RD;
    wire [31:0] ALU_or_PC8;

    reg [31:0] expected_Out;
    reg expected_BranchTaken;
    reg expected_register_write;
    reg expected_redirect_pc;
    reg expected_supported;
    reg [4:0] expected_RD;
    reg [31:0] expected_ALU_or_PC8;
    reg [511:0] instruction_name;
    integer test_number;
    integer passed;
    integer failed;

    integer jalr_rd;

    // Probe all four existing SOH choices with an immediate whose sign bit is 1.
    reg [1:0] probe_OS2;
    wire [31:0] probe_OB;
    reg [31:0] expected_probe_OB;
    integer probe_number;

    ControlUnit control (
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
    foh first_operand (
        .RA(RA), .SA(I[10:6]), .OS1(OS1), .OA(OA)
    );
    soh second_operand (
        .RB(RB), .I(I[15:0]), .OS2(OS2), .OB(OB)
    );
    alu calculator (
        .A(OA), .B(OB), .OP(OP), .LE(LE), .EQ(EQ), .GT(GT), .Out(Out)
    );
    PhaseIIIBranchControl branch_control (
        .LE(LE), .EQ(EQ), .GT(GT), .BranchType(BranchType),
        .BranchTaken(BranchTaken)
    );
    PhaseIIIWriteCondition write_condition (
        .B(OB), .WriteCond(WriteCond), .BranchTaken(BranchTaken),
        .Allowed(write_allowed)
    );
    PhaseIIIRegDstMux destination (
        .RT(I[20:16]), .RD(I[15:11]), .RegDst(RegDst), .Out(RD)
    );
    PhaseIIIMux32 output_mux (
        .A(Out), .B(32'd108), .S(OutSel), .Out(ALU_or_PC8)
    );
    soh logical_immediate_probe (
        .RB(32'h12345678), .I(16'h8001), .OS2(probe_OS2), .OB(probe_OB)
    );
    assign register_write = RF_LE && write_allowed;
    assign redirect_pc = Jump || BranchTaken;

    initial begin
        passed = 0;
        failed = 0;
        I = 32'b0;
        RA = 32'b0;
        RB = 32'b0;
        probe_OS2 = 2'b00;

        for (test_number = 0; test_number < 111; test_number = test_number + 1) begin
            expected_Jump = 1'b0;
            expected_RegDst = 2'b00;
            expected_OS1 = 1'b0;
            expected_OS2 = 2'b00;
            expected_OP = 4'b0000;
            expected_BranchType = 3'b000;
            expected_WriteCond = 2'b00;
            expected_RF_LE = 1'b0;
            expected_MemToReg = 1'b0;
            expected_RW = 1'b0;
            expected_E = 1'b0;
            expected_Size = 2'b00;
            expected_SE = 1'b0;
            expected_L = 1'b0;
            expected_OutSel = 1'b0;
            expected_SRA = 1'b0;
            expected_SRB = 1'b0;
            expected_Out = 32'b0;
            expected_BranchTaken = 1'b0;
            expected_register_write = 1'b0;
            expected_redirect_pc = 1'b0;
            expected_supported = 1'b1;
            expected_ALU_or_PC8 = 32'b0;

            case (test_number)
                0: begin
                    instruction_name = "ADD: operand pattern 1";
                    I = 32'h00221820;
                    RA = 32'h0000000A;
                    RB = 32'h00000003;
                    expected_Out = 32'h0000000D;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h0000000D;
                end
                1: begin
                    instruction_name = "ADD: operand pattern 2";
                    I = 32'h00221820;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFF;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                2: begin
                    instruction_name = "ADD: operand pattern 3";
                    I = 32'h00221820;
                    RA = 32'h80000000;
                    RB = 32'h7FFFFFFF;
                    expected_Out = 32'hFFFFFFFF;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                3: begin
                    instruction_name = "AND: operand pattern 1";
                    I = 32'h00221824;
                    RA = 32'h0000000A;
                    RB = 32'h00000003;
                    expected_Out = 32'h00000002;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0010;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000002;
                end
                4: begin
                    instruction_name = "AND: operand pattern 2";
                    I = 32'h00221824;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0010;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                5: begin
                    instruction_name = "AND: operand pattern 3";
                    I = 32'h00221824;
                    RA = 32'h80000000;
                    RB = 32'h7FFFFFFF;
                    expected_Out = 32'h00000000;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0010;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                6: begin
                    instruction_name = "OR: operand pattern 1";
                    I = 32'h00221825;
                    RA = 32'h0000000A;
                    RB = 32'h00000003;
                    expected_Out = 32'h0000000B;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0011;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h0000000B;
                end
                7: begin
                    instruction_name = "OR: operand pattern 2";
                    I = 32'h00221825;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFF;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0011;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                8: begin
                    instruction_name = "OR: operand pattern 3";
                    I = 32'h00221825;
                    RA = 32'h80000000;
                    RB = 32'h7FFFFFFF;
                    expected_Out = 32'hFFFFFFFF;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0011;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                9: begin
                    instruction_name = "XOR: operand pattern 1";
                    I = 32'h00221826;
                    RA = 32'h0000000A;
                    RB = 32'h00000003;
                    expected_Out = 32'h00000009;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0100;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000009;
                end
                10: begin
                    instruction_name = "XOR: operand pattern 2";
                    I = 32'h00221826;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFF;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0100;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                11: begin
                    instruction_name = "XOR: operand pattern 3";
                    I = 32'h00221826;
                    RA = 32'h80000000;
                    RB = 32'h7FFFFFFF;
                    expected_Out = 32'hFFFFFFFF;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0100;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                12: begin
                    instruction_name = "NOR: operand pattern 1";
                    I = 32'h00221827;
                    RA = 32'h0000000A;
                    RB = 32'h00000003;
                    expected_Out = 32'hFFFFFFF4;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0101;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFF4;
                end
                13: begin
                    instruction_name = "NOR: operand pattern 2";
                    I = 32'h00221827;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0101;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                14: begin
                    instruction_name = "NOR: operand pattern 3";
                    I = 32'h00221827;
                    RA = 32'h80000000;
                    RB = 32'h7FFFFFFF;
                    expected_Out = 32'h00000000;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0101;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                15: begin
                    instruction_name = "SLT: operand pattern 1";
                    I = 32'h0022182A;
                    RA = 32'h0000000A;
                    RB = 32'h00000003;
                    expected_Out = 32'h00000000;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0110;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                16: begin
                    instruction_name = "SLT: operand pattern 2";
                    I = 32'h0022182A;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0110;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                17: begin
                    instruction_name = "SLT: operand pattern 3";
                    I = 32'h0022182A;
                    RA = 32'h80000000;
                    RB = 32'h7FFFFFFF;
                    expected_Out = 32'h00000001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0110;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                18: begin
                    instruction_name = "MOVN: operand pattern 1";
                    I = 32'h0022180B;
                    RA = 32'h0000000A;
                    RB = 32'h00000003;
                    expected_Out = 32'h0000000A;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0111;
                    expected_WriteCond = 2'b01;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h0000000A;
                end
                19: begin
                    instruction_name = "MOVN: operand pattern 2";
                    I = 32'h0022180B;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFF;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0111;
                    expected_WriteCond = 2'b01;
                    expected_register_write = 1'b0;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                20: begin
                    instruction_name = "MOVN: operand pattern 3";
                    I = 32'h0022180B;
                    RA = 32'h80000000;
                    RB = 32'h7FFFFFFF;
                    expected_Out = 32'h80000000;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b0111;
                    expected_WriteCond = 2'b01;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h80000000;
                end
                21: begin
                    instruction_name = "SLL: shift 0";
                    I = 32'h00021800;
                    RA = 32'h00000000;
                    RB = 32'h80000001;
                    expected_Out = 32'h80000001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1001;
                    expected_OS1 = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h80000001;
                end
                22: begin
                    instruction_name = "SLL: shift 31";
                    I = 32'h00021FC0;
                    RA = 32'h00000000;
                    RB = 32'h00000003;
                    expected_Out = 32'h80000000;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1001;
                    expected_OS1 = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h80000000;
                end
                23: begin
                    instruction_name = "SLL: shift 4";
                    I = 32'h00021900;
                    RA = 32'h00000000;
                    RB = 32'h80000001;
                    expected_Out = 32'h00000010;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1001;
                    expected_OS1 = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000010;
                end
                24: begin
                    instruction_name = "SRL: shift 0";
                    I = 32'h00021802;
                    RA = 32'h00000000;
                    RB = 32'h80000001;
                    expected_Out = 32'h80000001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1010;
                    expected_OS1 = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h80000001;
                end
                25: begin
                    instruction_name = "SRL: shift 31";
                    I = 32'h00021FC2;
                    RA = 32'h00000000;
                    RB = 32'h80000001;
                    expected_Out = 32'h00000001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1010;
                    expected_OS1 = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                26: begin
                    instruction_name = "SRL: shift 4";
                    I = 32'h00021902;
                    RA = 32'h00000000;
                    RB = 32'hFFFFFFF0;
                    expected_Out = 32'h0FFFFFFF;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1010;
                    expected_OS1 = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h0FFFFFFF;
                end
                27: begin
                    instruction_name = "SRLV: shift 0";
                    I = 32'h00221806;
                    RA = 32'h00000000;
                    RB = 32'h80000001;
                    expected_Out = 32'h80000001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1010;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h80000001;
                end
                28: begin
                    instruction_name = "SRLV: shift 31";
                    I = 32'h00221806;
                    RA = 32'h0000001F;
                    RB = 32'h80000001;
                    expected_Out = 32'h00000001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1010;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                29: begin
                    instruction_name = "SRLV: shift 34";
                    I = 32'h00221806;
                    RA = 32'h00000022;
                    RB = 32'h80000001;
                    expected_Out = 32'h20000000;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1010;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h20000000;
                end
                30: begin
                    instruction_name = "SRAV: shift 0";
                    I = 32'h00221807;
                    RA = 32'h00000000;
                    RB = 32'h80000001;
                    expected_Out = 32'h80000001;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1011;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h80000001;
                end
                31: begin
                    instruction_name = "SRAV: shift 31";
                    I = 32'h00221807;
                    RA = 32'h0000001F;
                    RB = 32'h80000001;
                    expected_Out = 32'hFFFFFFFF;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1011;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                32: begin
                    instruction_name = "SRAV: shift 34";
                    I = 32'h00221807;
                    RA = 32'h00000022;
                    RB = 32'hFFFFFFF0;
                    expected_Out = 32'hFFFFFFFC;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_OP = 4'b1011;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFC;
                end
                33: begin
                    instruction_name = "SLTI: signed comparison";
                    I = 32'h28220001;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000001;
                    expected_OP = 4'b0110;
                    expected_OS2 = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                34: begin
                    instruction_name = "SLTI: signed comparison";
                    I = 32'h2822FFFF;
                    RA = 32'h7FFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_OP = 4'b0110;
                    expected_OS2 = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                35: begin
                    instruction_name = "SLTI: signed comparison";
                    I = 32'h28228000;
                    RA = 32'h80000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000001;
                    expected_OP = 4'b0110;
                    expected_OS2 = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                36: begin
                    instruction_name = "SLTI: signed comparison";
                    I = 32'h28220000;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_OP = 4'b0110;
                    expected_OS2 = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                37: begin
                    instruction_name = "LB: signed address offset";
                    I = 32'h80220004;
                    RA = 32'h00000064;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000068;
                    expected_OS2 = 2'b01;
                    expected_SE = 1'b1;
                    expected_SRA = 1'b1;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000068;
                end
                38: begin
                    instruction_name = "LB: signed address offset";
                    I = 32'h8022FFFC;
                    RA = 32'h00000064;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000060;
                    expected_OS2 = 2'b01;
                    expected_SE = 1'b1;
                    expected_SRA = 1'b1;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000060;
                end
                39: begin
                    instruction_name = "LB: signed address offset";
                    I = 32'h80228000;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFF8000;
                    expected_OS2 = 2'b01;
                    expected_SE = 1'b1;
                    expected_SRA = 1'b1;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFF8000;
                end
                40: begin
                    instruction_name = "LHU: signed address offset";
                    I = 32'h94220004;
                    RA = 32'h00000064;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000068;
                    expected_OS2 = 2'b01;
                    expected_Size = 2'b01;
                    expected_SRA = 1'b1;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000068;
                end
                41: begin
                    instruction_name = "LHU: signed address offset";
                    I = 32'h9422FFFC;
                    RA = 32'h00000064;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000060;
                    expected_OS2 = 2'b01;
                    expected_Size = 2'b01;
                    expected_SRA = 1'b1;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000060;
                end
                42: begin
                    instruction_name = "LHU: signed address offset";
                    I = 32'h94228000;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFF8000;
                    expected_OS2 = 2'b01;
                    expected_Size = 2'b01;
                    expected_SRA = 1'b1;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFF8000;
                end
                43: begin
                    instruction_name = "LW: signed address offset";
                    I = 32'h8C220004;
                    RA = 32'h00000064;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000068;
                    expected_OS2 = 2'b01;
                    expected_Size = 2'b10;
                    expected_SRA = 1'b1;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000068;
                end
                44: begin
                    instruction_name = "LW: signed address offset";
                    I = 32'h8C22FFFC;
                    RA = 32'h00000064;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000060;
                    expected_OS2 = 2'b01;
                    expected_Size = 2'b10;
                    expected_SRA = 1'b1;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000060;
                end
                45: begin
                    instruction_name = "LW: signed address offset";
                    I = 32'h8C228000;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFF8000;
                    expected_OS2 = 2'b01;
                    expected_Size = 2'b10;
                    expected_SRA = 1'b1;
                    expected_RF_LE = 1'b1;
                    expected_L = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFF8000;
                end
                46: begin
                    instruction_name = "SB: signed address offset";
                    I = 32'hA0220004;
                    RA = 32'h00000064;
                    RB = 32'hA5A55A5A;
                    expected_Out = 32'h00000068;
                    expected_OS2 = 2'b01;
                    expected_SRA = 1'b1;
                    expected_RW = 1'b1;
                    expected_E = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000068;
                end
                47: begin
                    instruction_name = "SB: signed address offset";
                    I = 32'hA022FFFC;
                    RA = 32'h00000064;
                    RB = 32'hA5A55A5A;
                    expected_Out = 32'h00000060;
                    expected_OS2 = 2'b01;
                    expected_SRA = 1'b1;
                    expected_RW = 1'b1;
                    expected_E = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000060;
                end
                48: begin
                    instruction_name = "SB: signed address offset";
                    I = 32'hA0228000;
                    RA = 32'h00000000;
                    RB = 32'hA5A55A5A;
                    expected_Out = 32'hFFFF8000;
                    expected_OS2 = 2'b01;
                    expected_SRA = 1'b1;
                    expected_RW = 1'b1;
                    expected_E = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b0;
                    expected_ALU_or_PC8 = 32'hFFFF8000;
                end
                49: begin
                    instruction_name = "SH: signed address offset";
                    I = 32'hA4220004;
                    RA = 32'h00000064;
                    RB = 32'hA5A55A5A;
                    expected_Out = 32'h00000068;
                    expected_OS2 = 2'b01;
                    expected_Size = 2'b01;
                    expected_SRA = 1'b1;
                    expected_RW = 1'b1;
                    expected_E = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000068;
                end
                50: begin
                    instruction_name = "SH: signed address offset";
                    I = 32'hA422FFFC;
                    RA = 32'h00000064;
                    RB = 32'hA5A55A5A;
                    expected_Out = 32'h00000060;
                    expected_OS2 = 2'b01;
                    expected_Size = 2'b01;
                    expected_SRA = 1'b1;
                    expected_RW = 1'b1;
                    expected_E = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000060;
                end
                51: begin
                    instruction_name = "SH: signed address offset";
                    I = 32'hA4228000;
                    RA = 32'h00000000;
                    RB = 32'hA5A55A5A;
                    expected_Out = 32'hFFFF8000;
                    expected_OS2 = 2'b01;
                    expected_Size = 2'b01;
                    expected_SRA = 1'b1;
                    expected_RW = 1'b1;
                    expected_E = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b0;
                    expected_ALU_or_PC8 = 32'hFFFF8000;
                end
                52: begin
                    instruction_name = "BLTZ: sign/zero case 1";
                    I = 32'h0420FFFD;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFF;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                53: begin
                    instruction_name = "BLTZ: sign/zero case 2";
                    I = 32'h0420FFFD;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                54: begin
                    instruction_name = "BLTZ: sign/zero case 3";
                    I = 32'h0420FFFD;
                    RA = 32'h00000001;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000001;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                55: begin
                    instruction_name = "BLTZ: sign/zero case 4";
                    I = 32'h0420FFFD;
                    RA = 32'h80000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h80000000;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'h80000000;
                end
                56: begin
                    instruction_name = "BLTZ: sign/zero case 5";
                    I = 32'h0420FFFD;
                    RA = 32'h7FFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'h7FFFFFFF;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'h7FFFFFFF;
                end
                57: begin
                    instruction_name = "BGEZ: sign/zero case 1";
                    I = 32'h0421FFFD;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFF;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b010;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                58: begin
                    instruction_name = "BGEZ: sign/zero case 2";
                    I = 32'h0421FFFD;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b010;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                59: begin
                    instruction_name = "BGEZ: sign/zero case 3";
                    I = 32'h0421FFFD;
                    RA = 32'h00000001;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000001;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b010;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                60: begin
                    instruction_name = "BGEZ: sign/zero case 4";
                    I = 32'h0421FFFD;
                    RA = 32'h80000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h80000000;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b010;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'h80000000;
                end
                61: begin
                    instruction_name = "BGEZ: sign/zero case 5";
                    I = 32'h0421FFFD;
                    RA = 32'h7FFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'h7FFFFFFF;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b010;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'h7FFFFFFF;
                end
                62: begin
                    instruction_name = "BLEZ: sign/zero case 1";
                    I = 32'h1820FFFD;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFF;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b100;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                63: begin
                    instruction_name = "BLEZ: sign/zero case 2";
                    I = 32'h1820FFFD;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b100;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                64: begin
                    instruction_name = "BLEZ: sign/zero case 3";
                    I = 32'h1820FFFD;
                    RA = 32'h00000001;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000001;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b100;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                65: begin
                    instruction_name = "BLEZ: sign/zero case 4";
                    I = 32'h1820FFFD;
                    RA = 32'h80000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h80000000;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b100;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'h80000000;
                end
                66: begin
                    instruction_name = "BLEZ: sign/zero case 5";
                    I = 32'h1820FFFD;
                    RA = 32'h7FFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'h7FFFFFFF;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b100;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'h7FFFFFFF;
                end
                67: begin
                    instruction_name = "BLTZAL: sign/zero case 1";
                    I = 32'h0430FFFD;
                    RA = 32'hFFFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFF;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_RegDst = 2'b10;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_WriteCond = 2'b11;
                    expected_OutSel = 1'b1;
                    expected_register_write = 1'b1;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'd108;
                end
                68: begin
                    instruction_name = "BLTZAL: sign/zero case 2";
                    I = 32'h0430FFFD;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_RegDst = 2'b10;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_WriteCond = 2'b11;
                    expected_OutSel = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'd108;
                end
                69: begin
                    instruction_name = "BLTZAL: sign/zero case 3";
                    I = 32'h0430FFFD;
                    RA = 32'h00000001;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000001;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_RegDst = 2'b10;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_WriteCond = 2'b11;
                    expected_OutSel = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'd108;
                end
                70: begin
                    instruction_name = "BLTZAL: sign/zero case 4";
                    I = 32'h0430FFFD;
                    RA = 32'h80000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h80000000;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_RegDst = 2'b10;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_WriteCond = 2'b11;
                    expected_OutSel = 1'b1;
                    expected_register_write = 1'b1;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'd108;
                end
                71: begin
                    instruction_name = "BLTZAL: sign/zero case 5";
                    I = 32'h0430FFFD;
                    RA = 32'h7FFFFFFF;
                    RB = 32'h00000000;
                    expected_Out = 32'h7FFFFFFF;
                    expected_OP = 4'b0111;
                    expected_BranchType = 3'b101;
                    expected_SRA = 1'b1;
                    expected_RegDst = 2'b10;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_WriteCond = 2'b11;
                    expected_OutSel = 1'b1;
                    expected_register_write = 1'b0;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'd108;
                end
                72: begin
                    instruction_name = "BNE: equality and overflow boundary";
                    I = 32'h1422FFFD;
                    RA = 32'h00000007;
                    RB = 32'h00000007;
                    expected_Out = 32'h00000000;
                    expected_OP = 4'b0001;
                    expected_BranchType = 3'b110;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                73: begin
                    instruction_name = "BNE: equality and overflow boundary";
                    I = 32'h1422FFFD;
                    RA = 32'h00000007;
                    RB = 32'h00000008;
                    expected_Out = 32'hFFFFFFFF;
                    expected_OP = 4'b0001;
                    expected_BranchType = 3'b110;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'hFFFFFFFF;
                end
                74: begin
                    instruction_name = "BNE: equality and overflow boundary";
                    I = 32'h1422FFFD;
                    RA = 32'h80000000;
                    RB = 32'h7FFFFFFF;
                    expected_Out = 32'h00000001;
                    expected_OP = 4'b0001;
                    expected_BranchType = 3'b110;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_BranchTaken = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000001;
                end
                75: begin
                    instruction_name = "BNE: equality and overflow boundary";
                    I = 32'h1422FFFD;
                    RA = 32'hFFFFFFFF;
                    RB = 32'hFFFFFFFF;
                    expected_Out = 32'h00000000;
                    expected_OP = 4'b0001;
                    expected_BranchType = 3'b110;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_BranchTaken = 1'b0;
                    expected_redirect_pc = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                76: begin
                    instruction_name = "J: unconditional jump";
                    I = 32'h08000004;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_Jump = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                77: begin
                    instruction_name = "J: unconditional jump";
                    I = 32'h0BFFFFFF;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_Jump = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                78: begin
                    instruction_name = "JALR r31,rs: explicit rd";
                    I = 32'h0020F809;
                    RA = 32'h00000080;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000080;
                    expected_Jump = 1'b1;
                    expected_OP = 4'b0111;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_OutSel = 1'b1;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'd108;
                end
                79: begin
                    instruction_name = "JALR r31,rs: explicit rd";
                    I = 32'h0020F809;
                    RA = 32'hFFFFFFFC;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFC;
                    expected_Jump = 1'b1;
                    expected_OP = 4'b0111;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_OutSel = 1'b1;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'd108;
                end
                80: begin
                    instruction_name = "ANDI: REQUIRED BUT UNSUPPORTED";
                    I = 32'h30227FFF;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                81: begin
                    instruction_name = "ANDI: REQUIRED BUT UNSUPPORTED";
                    I = 32'h30228000;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                82: begin
                    instruction_name = "ANDI: REQUIRED BUT UNSUPPORTED";
                    I = 32'h3022FFFF;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                83: begin
                    instruction_name = "ORI: REQUIRED BUT UNSUPPORTED";
                    I = 32'h34227FFF;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                84: begin
                    instruction_name = "ORI: REQUIRED BUT UNSUPPORTED";
                    I = 32'h34228000;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                85: begin
                    instruction_name = "ORI: REQUIRED BUT UNSUPPORTED";
                    I = 32'h3422FFFF;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                86: begin
                    instruction_name = "XORI: REQUIRED BUT UNSUPPORTED";
                    I = 32'h38227FFF;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                87: begin
                    instruction_name = "XORI: REQUIRED BUT UNSUPPORTED";
                    I = 32'h38228000;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                88: begin
                    instruction_name = "XORI: REQUIRED BUT UNSUPPORTED";
                    I = 32'h3822FFFF;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                89: begin
                    instruction_name = "ADD: invalid nonzero sa";
                    I = 32'h00221860;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                90: begin
                    instruction_name = "AND: invalid nonzero sa";
                    I = 32'h00221864;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                91: begin
                    instruction_name = "OR: invalid nonzero sa";
                    I = 32'h00221865;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                92: begin
                    instruction_name = "XOR: invalid nonzero sa";
                    I = 32'h00221866;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                93: begin
                    instruction_name = "NOR: invalid nonzero sa";
                    I = 32'h00221867;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                94: begin
                    instruction_name = "SLT: invalid nonzero sa";
                    I = 32'h0022186A;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                95: begin
                    instruction_name = "MOVN: invalid nonzero sa";
                    I = 32'h0022184B;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                96: begin
                    instruction_name = "SLL: invalid nonzero rs";
                    I = 32'h00221800;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                97: begin
                    instruction_name = "SRL: invalid nonzero rs";
                    I = 32'h00221802;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                98: begin
                    instruction_name = "SRLV: invalid nonzero sa";
                    I = 32'h00221846;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                99: begin
                    instruction_name = "SRAV: invalid nonzero sa";
                    I = 32'h00221847;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                100: begin
                    instruction_name = "JALR: invalid nonzero rt";
                    I = 32'h0021F809;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                101: begin
                    instruction_name = "JALR: invalid nonzero sa";
                    I = 32'h0020F849;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                102: begin
                    instruction_name = "JALR r5,rs: explicit rd";
                    I = 32'h00202809;
                    RA = 32'h00000080;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000080;
                    expected_Jump = 1'b1;
                    expected_OP = 4'b0111;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_OutSel = 1'b1;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'd108;
                end
                103: begin
                    instruction_name = "JALR r0,rs: explicit rd";
                    I = 32'h00200009;
                    RA = 32'hFFFFFFFC;
                    RB = 32'h00000000;
                    expected_Out = 32'hFFFFFFFC;
                    expected_Jump = 1'b1;
                    expected_OP = 4'b0111;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_OutSel = 1'b1;
                    expected_SRA = 1'b1;
                    expected_register_write = 1'b1;
                    expected_redirect_pc = 1'b1;
                    expected_ALU_or_PC8 = 32'd108;
                end
                104: begin
                    instruction_name = "BLEZ: invalid nonzero rt";
                    I = 32'h18210004;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                105: begin
                    instruction_name = "REGIMM: invalid secondary opcode";
                    I = 32'h04220004;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                106: begin
                    instruction_name = "REGIMM: invalid secondary opcode";
                    I = 32'h04320004;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                107: begin
                    instruction_name = "CLO: excluded from project";
                    I = 32'h70221821;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                108: begin
                    instruction_name = "CLZ: excluded from project";
                    I = 32'h70221820;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_supported = 1'b0;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                109: begin
                    instruction_name = "NOP after rejected instruction";
                    I = 32'h00000000;
                    RA = 32'h00000000;
                    RB = 32'h00000000;
                    expected_Out = 32'h00000000;
                    expected_ALU_or_PC8 = 32'h00000000;
                end
                110: begin
                    instruction_name = "ADD recovers after rejected words";
                    I = 32'h00221820;
                    RA = 32'h0000000A;
                    RB = 32'h00000003;
                    expected_Out = 32'h0000000D;
                    expected_RegDst = 2'b01;
                    expected_RF_LE = 1'b1;
                    expected_MemToReg = 1'b1;
                    expected_SRA = 1'b1;
                    expected_SRB = 1'b1;
                    expected_register_write = 1'b1;
                    expected_ALU_or_PC8 = 32'h0000000D;
                end
            endcase

            case (expected_RegDst)
                2'b00: expected_RD = I[20:16];
                2'b01: expected_RD = I[15:11];
                2'b10: expected_RD = 5'd31;
                default: expected_RD = 5'd0;
            endcase

            #1;
            $display("Coverage case %0d: %0s I=%h RA=%h RB=%h",
                     test_number + 1, instruction_name, I, RA, RB);
            if (
                (Jump === expected_Jump) &&
                (RegDst === expected_RegDst) &&
                (OS1 === expected_OS1) &&
                (OS2 === expected_OS2) &&
                (OP === expected_OP) &&
                (BranchType === expected_BranchType) &&
                (WriteCond === expected_WriteCond) &&
                (RF_LE === expected_RF_LE) &&
                (MemToReg === expected_MemToReg) &&
                (RW === expected_RW) &&
                (E === expected_E) &&
                (Size === expected_Size) &&
                (SE === expected_SE) &&
                (L === expected_L) &&
                (OutSel === expected_OutSel) &&
                (SRA === expected_SRA) &&
                (SRB === expected_SRB) &&
                (control.instruction_supported === expected_supported)) begin
                passed = passed + 1;
            end
            else begin
                failed = failed + 1;
                $display("FAIL: controls or supported flag, case %0d", test_number + 1);
                $display("Actual OP=%b OS1=%b OS2=%b RegDst=%b BranchType=%b WriteCond=%b RF_LE=%b RW=%b E=%b Size=%b SE=%b",
                         OP, OS1, OS2, RegDst, BranchType, WriteCond, RF_LE, RW, E, Size, SE);
                $display("Expected OP=%b OS1=%b OS2=%b RegDst=%b BranchType=%b WriteCond=%b RF_LE=%b RW=%b E=%b Size=%b SE=%b",
                         expected_OP, expected_OS1, expected_OS2, expected_RegDst,
                         expected_BranchType, expected_WriteCond, expected_RF_LE,
                         expected_RW, expected_E, expected_Size, expected_SE);
            end

            if ((Out === expected_Out) &&
                (LE === expected_Out[31]) &&
                (EQ === (expected_Out == 32'b0)) &&
                (GT === (!expected_Out[31] && (expected_Out != 32'b0))) &&
                (BranchTaken === expected_BranchTaken) &&
                (register_write === expected_register_write) &&
                (redirect_pc === expected_redirect_pc) &&
                (RD === expected_RD) &&
                (ALU_or_PC8 === expected_ALU_or_PC8)) begin
                passed = passed + 1;
            end
            else begin
                failed = failed + 1;
                $display("FAIL: numeric/control effects, case %0d", test_number + 1);
                $display("Actual Out=%h BranchTaken=%b write=%b redirect=%b RD=%0d link_mux=%h",
                         Out, BranchTaken, register_write, redirect_pc, RD, ALU_or_PC8);
                $display("Expected Out=%h BranchTaken=%b write=%b redirect=%b RD=%0d link_mux=%h",
                         expected_Out, expected_BranchTaken, expected_register_write,
                         expected_redirect_pc, expected_RD, expected_ALU_or_PC8);
            end
        end

        // JALR uses rd, not an implicit r31. Check every encoded destination.
        // rd=0 checks selection only; a real Register File must discard its write.
        for (jalr_rd = 0; jalr_rd < 32; jalr_rd = jalr_rd + 1) begin
            I = {6'b000000, 5'd1, 5'd0, jalr_rd[4:0], 5'd0, 6'b001001};
            RA = 32'h89ABCDFC;
            RB = 32'b0;
            #1;
            if ((Jump === 1'b1) && (RegDst === 2'b01) &&
                (OS1 === 1'b0) && (OS2 === 2'b00) && (OP === 4'b0111) &&
                (BranchType === 3'b000) && (WriteCond === 2'b00) &&
                (RF_LE === 1'b1) && (MemToReg === 1'b1) &&
                (RW === 1'b0) && (E === 1'b0) && (Size === 2'b00) &&
                (SE === 1'b0) && (L === 1'b0) && (OutSel === 1'b1) &&
                (SRA === 1'b1) && (SRB === 1'b0) &&
                (control.instruction_supported === 1'b1)) begin
                passed = passed + 1;
            end
            else begin
                failed = failed + 1;
                $display("FAIL: JALR controls rd=%0d", jalr_rd);
            end
            if ((RD === jalr_rd[4:0]) && (Out === RA) &&
                (ALU_or_PC8 === 32'd108) && (register_write === 1'b1) &&
                (redirect_pc === 1'b1) && (BranchTaken === 1'b0)) begin
                passed = passed + 1;
            end
            else begin
                failed = failed + 1;
                $display("FAIL: JALR destination/link expected rd=%0d actual RD=%0d", jalr_rd, RD);
            end
        end

        // None of the SOH options produces the required 00008001.
        for (probe_number = 0; probe_number < 4; probe_number = probe_number + 1) begin
            case (probe_number)
                0: begin probe_OS2 = 2'b00; expected_probe_OB = 32'h12345678; end
                1: begin probe_OS2 = 2'b01; expected_probe_OB = 32'hFFFF8001; end
                2: begin probe_OS2 = 2'b10; expected_probe_OB = 32'h80010000; end
                3: begin probe_OS2 = 2'b11; expected_probe_OB = 32'h00000000; end
            endcase
            #1;
            if ((probe_OB === expected_probe_OB) && (probe_OB !== 32'h00008001))
                passed = passed + 1;
            else begin
                failed = failed + 1;
                $display("FAIL: SOH limitation probe OS2=%b OB=%h", probe_OS2, probe_OB);
            end
        end
        $display("Unsupported logical immediates are rejected safely, not counted as implemented.");
        $display("JALR uses explicit rd per the notes; the Fase II wording differs.");
        $display("COVERAGE_RESULT: passed=%0d failed=%0d total=%0d cases=143 soh_probes=4 jalr_destinations=32",
                 passed, failed, passed + failed);
        if (failed != 0) $stop;
        $finish;
    end
endmodule
