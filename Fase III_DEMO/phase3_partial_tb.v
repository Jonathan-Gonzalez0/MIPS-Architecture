`timescale 1ns/1ps

// PARTIAL TEST ONLY. The ROM is real. The sequential ID input driver below is
// a test stimulus, NOT a PASG, nPC or IF/ID implementation. No fetch is validated.
module phase3_partial_tb;
    reg Clk;
    reg Reset;
    reg S;
    reg [8:0] ROM_Address;
    wire [31:0] I_ID;
    reg [31:0] PC_ID;
    reg [31:0] PA_ID;
    reg [31:0] PB_ID;
    reg [31:0] TA_ID;
    reg [31:0] DataMemory_DO;
    wire Jump_ID;
    wire BranchTaken_EX;
    wire Redirect_IF;
    wire [31:0] Target_IF;
    wire [31:0] Memory_Address;
    wire [31:0] Memory_DI;
    wire Memory_RW;
    wire Memory_E;
    wire [1:0] Memory_Size;
    wire Memory_SE;
    wire [31:0] PW_WB;
    wire [4:0] RW_WB;
    wire RF_LE_WB;
    integer instruction_index;
    integer byte_index;
    integer passed;
    integer failed;
    integer check_number;
    integer hold_number;
    integer input_hold_number;
    reg check_ok;
    reg [255:0] check_name;
    reg [127:0] mnemonic;
    reg [31:0] program_words [0:24];

    reg ref_Jump;
    reg [1:0] ref_RegDst;
    reg ref_OS1;
    reg [1:0] ref_OS2;
    reg [3:0] ref_OP;
    reg [2:0] ref_BranchType;
    reg [1:0] ref_WriteCond;
    reg ref_RF_LE;
    reg ref_MemToReg;
    reg ref_RW;
    reg ref_E;
    reg [1:0] ref_Size;
    reg ref_SE;
    reg ref_L;
    reg ref_OutSel;
    reg ref_SRA;
    reg ref_SRB;
    reg ref_valid;
    reg [4:0] ref_RD_ID;
    wire [25:0] actual_ID;
    wire [25:0] expected_ID;
    wire [20:0] actual_NOP;
    wire [20:0] expected_NOP;
    wire [174:0] actual_EX;
    wire [75:0] actual_MEM;
    wire [37:0] actual_WB;
    reg [174:0] expected_EX;
    reg [75:0] expected_MEM;
    reg [37:0] expected_WB;

    // EX: {PC8[31:0], TA[31:0], PA[31:0], PB[31:0], SA[4:0], I[15:0], RD[4:0],
    //      OS1, OS2[1:0], OP[3:0], BranchType[2:0], WriteCond[1:0], RF_LE,
    //      MemToReg, RW, E, Size[1:0], SE, L, OutSel} = 175 bits.
    // MEM: {ALU[31:0], SD[31:0], RD[4:0], RF_LE, RW, E, Size[1:0], SE, MemToReg}.
    // WB: {PW[31:0], RW[4:0], RF_LE}. Memory RW is a DIFFERENT, 1-bit signal.
    wire [31:0] ref_PC8_EX;
    assign ref_PC8_EX = expected_EX[174:143];
    wire [31:0] ref_TA_EX;
    assign ref_TA_EX = expected_EX[142:111];
    wire [31:0] ref_PA_EX;
    assign ref_PA_EX = expected_EX[110:79];
    wire [31:0] ref_PB_EX;
    assign ref_PB_EX = expected_EX[78:47];
    wire [4:0] ref_SA_EX;
    assign ref_SA_EX = expected_EX[46:42];
    wire [15:0] ref_I_EX;
    assign ref_I_EX = expected_EX[41:26];
    wire [4:0] ref_RD_EX;
    assign ref_RD_EX = expected_EX[25:21];
    wire ref_OS1_EX;
    assign ref_OS1_EX = expected_EX[20];
    wire [1:0] ref_OS2_EX;
    assign ref_OS2_EX = expected_EX[19:18];
    wire [3:0] ref_OP_EX;
    assign ref_OP_EX = expected_EX[17:14];
    wire [2:0] ref_BranchType_EX;
    assign ref_BranchType_EX = expected_EX[13:11];
    wire [1:0] ref_WriteCond_EX;
    assign ref_WriteCond_EX = expected_EX[10:9];
    wire ref_RF_LE_EX;
    assign ref_RF_LE_EX = expected_EX[8];
    wire ref_MemToReg_EX;
    assign ref_MemToReg_EX = expected_EX[7];
    wire ref_RW_EX;
    assign ref_RW_EX = expected_EX[6];
    wire ref_E_EX;
    assign ref_E_EX = expected_EX[5];
    wire [1:0] ref_Size_EX;
    assign ref_Size_EX = expected_EX[4:3];
    wire ref_SE_EX;
    assign ref_SE_EX = expected_EX[2];
    wire ref_L_EX;
    assign ref_L_EX = expected_EX[1];
    wire ref_OutSel_EX;
    assign ref_OutSel_EX = expected_EX[0];
    wire [31:0] ref_ALU_MEM;
    assign ref_ALU_MEM = expected_MEM[75:44];
    wire [31:0] ref_SD_MEM;
    assign ref_SD_MEM = expected_MEM[43:12];
    wire [4:0] ref_RD_MEM;
    assign ref_RD_MEM = expected_MEM[11:7];
    wire ref_RF_LE_MEM;
    assign ref_RF_LE_MEM = expected_MEM[6];
    wire ref_RW_MEM;
    assign ref_RW_MEM = expected_MEM[5];
    wire ref_E_MEM;
    assign ref_E_MEM = expected_MEM[4];
    wire [1:0] ref_Size_MEM;
    assign ref_Size_MEM = expected_MEM[3:2];
    wire ref_SE_MEM;
    assign ref_SE_MEM = expected_MEM[1];
    wire ref_MemToReg_MEM;
    assign ref_MemToReg_MEM = expected_MEM[0];
    reg [31:0] ref_A;
    reg [31:0] ref_B;
    reg [31:0] ref_Result;
    reg ref_LE;
    reg ref_EQ;
    reg ref_GT;
    reg ref_BranchTaken;
    reg ref_WriteAllowed;
    reg ref_effective_RF_LE;
    reg [31:0] ref_Output;

    assign actual_ID = {dut.Jump_ID, dut.RegDst_ID, dut.OS1_ID, dut.OS2_ID, dut.OP_ID, dut.BranchType_ID, dut.WriteCond_ID, dut.RF_LE_ID, dut.MemToReg_ID, dut.RW_ID, dut.E_ID, dut.Size_ID, dut.SE_ID, dut.L_ID, dut.OutSel_ID, dut.SRA_ID, dut.SRB_ID};
    assign expected_ID = {ref_Jump, ref_RegDst, ref_OS1, ref_OS2, ref_OP, ref_BranchType, ref_WriteCond, ref_RF_LE, ref_MemToReg, ref_RW, ref_E, ref_Size, ref_SE, ref_L, ref_OutSel, ref_SRA, ref_SRB};
    assign actual_NOP = {dut.OS1_N, dut.OS2_N, dut.OP_N, dut.BranchType_N, dut.WriteCond_N, dut.RF_LE_N, dut.MemToReg_N, dut.RW_N, dut.E_N, dut.Size_N, dut.SE_N, dut.L_N, dut.OutSel_N};
    assign expected_NOP = S ? 21'b0 : {ref_OS1, ref_OS2, ref_OP, ref_BranchType, ref_WriteCond, ref_RF_LE, ref_MemToReg, ref_RW, ref_E, ref_Size, ref_SE, ref_L, ref_OutSel};
    assign actual_EX = {dut.PC8_EX, dut.TA_EX, dut.PA_EX, dut.PB_EX, dut.SA_EX, dut.I_EX, dut.RD_EX, dut.OS1_EX, dut.OS2_EX, dut.OP_EX, dut.BranchType_EX, dut.WriteCond_EX, dut.RF_LE_EX, dut.MemToReg_EX, dut.RW_EX, dut.E_EX, dut.Size_EX, dut.SE_EX, dut.L_EX, dut.OutSel_EX};
    assign actual_MEM = {dut.ALU_MEM, dut.SD_MEM, dut.RD_MEM, dut.RF_LE_MEM, dut.RW_MEM, dut.E_MEM, dut.Size_MEM, dut.SE_MEM, dut.MemToReg_MEM};
    assign actual_WB = {PW_WB, RW_WB, RF_LE_WB};

    InstructionMemory program_memory (.A(ROM_Address), .I(I_ID));
    PhaseIIIControlPath dut (
        .Clk(Clk), .Reset(Reset), .S(S),
        .I_ID(I_ID), .PC_ID(PC_ID), .TA_ID(TA_ID), .PA_ID(PA_ID), .PB_ID(PB_ID),
        .DataMemory_DO(DataMemory_DO),
        .Jump_ID(Jump_ID), .BranchTaken_EX(BranchTaken_EX),
        .Redirect_IF(Redirect_IF), .Target_IF(Target_IF),
        .Memory_Address(Memory_Address), .Memory_DI(Memory_DI),
        .Memory_RW(Memory_RW), .Memory_E(Memory_E),
        .Memory_Size(Memory_Size), .Memory_SE(Memory_SE),
        .PW_WB(PW_WB), .RW_WB(RW_WB), .RF_LE_WB(RF_LE_WB)
    );

    // External data fixtures, not RF, forwarding, TAG or Data Memory hardware.
    always @(*) begin
        PA_ID = 32'd7;
        PB_ID = 32'd3;
        if (I_ID[25:21] == 5'b0) PA_ID = 32'b0;
        if (I_ID[20:16] == 5'b0) PB_ID = 32'b0;
        case (I_ID)
            32'h0003180A: PB_ID = 32'd5; // MOVZ must reject the write.
            32'h0471FFFD: begin
                if (PC_ID == 32'd36) PA_ID = 32'hFFFFFFFF;
                else PA_ID = 32'd1;     // The second BGEZAL takes the branch/link.
            end
            32'h1060FFFD: PA_ID = 32'b0;
            32'h1C60FFFD: PA_ID = 32'd1;
            32'h03E00008: PA_ID = 32'h00000080;
        endcase
        TA_ID = 32'h00001000 + PC_ID; // Target-MUX fixture, NOT computed MIPS TA.
        DataMemory_DO = 32'hA5000000 ^ Memory_Address;
    end

    // Independent expected controls for the actual words in the supplied program.
    always @(*) begin
        ref_Jump = 1'b0;
        ref_RegDst = 2'b0;
        ref_OS1 = 1'b0;
        ref_OS2 = 2'b0;
        ref_OP = 4'b0;
        ref_BranchType = 3'b0;
        ref_WriteCond = 2'b0;
        ref_RF_LE = 1'b0;
        ref_MemToReg = 1'b0;
        ref_RW = 1'b0;
        ref_E = 1'b0;
        ref_Size = 2'b0;
        ref_SE = 1'b0;
        ref_L = 1'b0;
        ref_OutSel = 1'b0;
        ref_SRA = 1'b0;
        ref_SRB = 1'b0;
        ref_valid = 1'b1;
        mnemonic = "INVALID";
        case (I_ID)
            32'h00000000: begin
                mnemonic = "NOP";
            end
            32'h20050000: begin
                mnemonic = "ADDI";
                ref_OS2 = 2'b01;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_SRA = 1'b1;
            end
            32'h24050000: begin
                mnemonic = "ADDIU";
                ref_OS2 = 2'b01;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_SRA = 1'b1;
            end
            32'h00031822: begin
                mnemonic = "SUB";
                ref_OP = 4'b0001;
                ref_RegDst = 2'b01;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_SRA = 1'b1;
                ref_SRB = 1'b1;
            end
            32'h90220000: begin
                mnemonic = "LBU";
                ref_OS2 = 2'b01;
                ref_RF_LE = 1'b1;
                ref_L = 1'b1;
                ref_SRA = 1'b1;
            end
            32'h84220000: begin
                mnemonic = "LH";
                ref_OS2 = 2'b01;
                ref_RF_LE = 1'b1;
                ref_Size = 2'b01;
                ref_SE = 1'b1;
                ref_L = 1'b1;
                ref_SRA = 1'b1;
            end
            32'hAC250001: begin
                mnemonic = "SW";
                ref_OS2 = 2'b01;
                ref_RW = 1'b1;
                ref_E = 1'b1;
                ref_Size = 2'b10;
                ref_SRA = 1'b1;
                ref_SRB = 1'b1;
            end
            32'h00031903: begin
                mnemonic = "SRA";
                ref_OP = 4'b1011;
                ref_OS1 = 1'b1;
                ref_RegDst = 2'b01;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_SRB = 1'b1;
            end
            32'h00233904: begin
                mnemonic = "SLLV";
                ref_OP = 4'b1001;
                ref_RegDst = 2'b01;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_SRA = 1'b1;
                ref_SRB = 1'b1;
            end
            32'h0003180A: begin
                mnemonic = "MOVZ";
                ref_OP = 4'b0111;
                ref_RegDst = 2'b01;
                ref_WriteCond = 2'b10;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_SRA = 1'b1;
                ref_SRB = 1'b1;
            end
            32'h0471FFFD: begin
                mnemonic = "BGEZAL";
                ref_OP = 4'b0111;
                ref_RegDst = 2'b10;
                ref_BranchType = 3'b010;
                ref_WriteCond = 2'b11;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_OutSel = 1'b1;
                ref_SRA = 1'b1;
            end
            32'h1060FFFD: begin
                mnemonic = "BEQ";
                ref_OP = 4'b0001;
                ref_BranchType = 3'b001;
                ref_SRA = 1'b1;
                ref_SRB = 1'b1;
            end
            32'h1C60FFFD: begin
                mnemonic = "BGTZ";
                ref_OP = 4'b0111;
                ref_BranchType = 3'b011;
                ref_SRA = 1'b1;
            end
            32'h0C000004: begin
                mnemonic = "JAL";
                ref_Jump = 1'b1;
                ref_RegDst = 2'b10;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_OutSel = 1'b1;
            end
            32'h03E00008: begin
                mnemonic = "JR";
                ref_Jump = 1'b1;
                ref_OP = 4'b0111;
                ref_SRA = 1'b1;
            end
            32'h3C053F0F: begin
                mnemonic = "LUI";
                ref_OP = 4'b1000;
                ref_OS2 = 2'b10;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
            end
            default: ref_valid = 1'b0;
        endcase
        case (ref_RegDst)
            2'b00: ref_RD_ID = I_ID[20:16];
            2'b01: ref_RD_ID = I_ID[15:11];
            2'b10: ref_RD_ID = 5'd31;
            2'b11: ref_RD_ID = 5'd0;
            default: ref_RD_ID = 5'b0;
        endcase
    end

    // Reference EX behavior uses ONLY the expected EX register and known inputs.
    always @(*) begin
        if (ref_OS1_EX) ref_A = {27'b0, ref_SA_EX};
        else ref_A = ref_PA_EX;
        case (ref_OS2_EX)
            2'b00: ref_B = ref_PB_EX;
            2'b01: ref_B = {{16{ref_I_EX[15]}}, ref_I_EX};
            2'b10: ref_B = {ref_I_EX, 16'b0};
            default: ref_B = 32'b0;
        endcase
        case (ref_OP_EX)
            4'b0000: ref_Result = ref_A + ref_B;
            4'b0001: ref_Result = ref_A - ref_B;
            4'b0010: ref_Result = ref_A & ref_B;
            4'b0011: ref_Result = ref_A | ref_B;
            4'b0100: ref_Result = ref_A ^ ref_B;
            4'b0101: ref_Result = ~(ref_A | ref_B);
            4'b0110: ref_Result = ($signed(ref_A) < $signed(ref_B)) ? 32'd1 : 32'd0;
            4'b0111: ref_Result = ref_A;
            4'b1000: ref_Result = ref_B;
            4'b1001: ref_Result = ref_B << ref_A[4:0];
            4'b1010: ref_Result = ref_B >> ref_A[4:0];
            4'b1011: ref_Result = $signed(ref_B) >>> ref_A[4:0];
            default: ref_Result = 32'b0;
        endcase
        ref_LE = ref_Result[31];
        ref_EQ = (ref_Result == 32'b0);
        ref_GT = !ref_Result[31] && (ref_Result != 32'b0);
        case (ref_BranchType_EX)
            3'b000: ref_BranchTaken = 1'b0;
            3'b001: ref_BranchTaken = ref_EQ;
            3'b010: ref_BranchTaken = !ref_LE;
            3'b011: ref_BranchTaken = ref_GT;
            3'b100: ref_BranchTaken = ref_LE || ref_EQ;
            3'b101: ref_BranchTaken = ref_LE;
            3'b110: ref_BranchTaken = !ref_EQ;
            default: ref_BranchTaken = 1'b0;
        endcase
        case (ref_WriteCond_EX)
            2'b00: ref_WriteAllowed = 1'b1;
            2'b01: ref_WriteAllowed = (ref_B != 32'b0);
            2'b10: ref_WriteAllowed = (ref_B == 32'b0);
            2'b11: ref_WriteAllowed = ref_BranchTaken;
            default: ref_WriteAllowed = 1'b0;
        endcase
        ref_effective_RF_LE = ref_RF_LE_EX && ref_WriteAllowed;
        if (ref_OutSel_EX) ref_Output = ref_PC8_EX;
        else ref_Output = ref_Result;
    end

    initial begin
        Clk = 1'b0;
        forever #2 Clk = ~Clk;
    end

    initial begin
        passed = 0;
        failed = 0;
        Reset = 1'b1;
        S = 1'b0;
        ROM_Address = 9'b0;
        PC_ID = 32'b0;
        instruction_index = 0;
        expected_EX = 175'b0;
        expected_MEM = 76'b0;
        expected_WB = 38'b0;
        program_words[0] = 32'h20050000;
        program_words[1] = 32'h00031822;
        program_words[2] = 32'h90220000;
        program_words[3] = 32'h84220000;
        program_words[4] = 32'hAC250001;
        program_words[5] = 32'h00031903;
        program_words[6] = 32'h00233904;
        program_words[7] = 32'h00000000;
        program_words[8] = 32'h0003180A;
        program_words[9] = 32'h0471FFFD;
        program_words[10] = 32'h1060FFFD;
        program_words[11] = 32'h0471FFFD;
        program_words[12] = 32'h1C60FFFD;
        program_words[13] = 32'h0C000004;
        program_words[14] = 32'h03E00008;
        program_words[15] = 32'h3C053F0F;
        program_words[16] = 32'h24050000;
        program_words[17] = 32'h00031822;
        program_words[18] = 32'h90220000;
        program_words[19] = 32'h84220000;
        program_words[20] = 32'hAC250001;
        program_words[21] = 32'h00000000;
        program_words[22] = 32'h00000000;
        program_words[23] = 32'h00000000;
        program_words[24] = 32'h00000000;
        for (byte_index = 0; byte_index < 512; byte_index = byte_index + 1)
            program_memory.Mem[byte_index] = 8'b0;
        $readmemb("Instruction Memory/test_instructions_memory.txt", program_memory.Mem, 0, 99);
        $display("PARTIAL ID->WB TEST: PASG/nPC/IF-ID absent; ROM-driven ID stimuli, external operand/TA/DO fixtures.");
        $display("No L_MEM exists. MEM RW is 1 bit; WB RW is a 5-bit destination.");
        #3 Reset = 1'b0;
        #69 S = 1'b1;              // Exactly time 72.
        #0.001;
        if ((actual_NOP === 21'b0) && (actual_EX[20:0] === expected_EX[20:0]) &&
            (actual_EX[20:0] !== 21'b0)) begin
            passed = passed + 1;
            $display("PASS: t=72 NOP MUX cleared immediately; EX waits for t=74 edge.");
        end
        else begin
            failed = failed + 1;
            $display("FAIL: t=72 bubble timing.");
        end
        #11.999;                  // Exactly time 84.
        $display("PARTIAL_RESULT: passed=%0d failed=%0d total=%0d end_time=%0d", passed, failed, passed + failed, $time);
        $display("FULL_PHASE_III_COMPLETE=NO: real PASG/nPC/IF-ID and unmodeled boundaries are still missing.");
        if (failed != 0) $stop;
        $finish;
    end

    // Explicit ROM-to-ID stimulus driver. This is NOT a substitute PASG module.
    always @(negedge Clk) begin
        if (($time > 0) && ($time < 84)) begin
            #0.01;                // Run hold checks before changing the ID inputs.
            ROM_Address = instruction_index * 4;
            PC_ID = instruction_index * 4;
            instruction_index = instruction_index + 1;
            #0.001;
            for (input_hold_number = 0; input_hold_number < 3; input_hold_number = input_hold_number + 1) begin
                case (input_hold_number)
                    0: check_ok = (actual_EX === expected_EX);
                    1: check_ok = (actual_MEM === expected_MEM);
                    2: check_ok = (actual_WB === expected_WB);
                endcase
                if (check_ok === 1'b1) passed = passed + 1;
                else begin
                    failed = failed + 1;
                    $display("FAIL: input change altered a register between edges at t=%0t stage=%0d",
                             $time, input_hold_number);
                end
            end
        end
    end

    // Before the first rising edge, synchronous Reset must not initialize Q.
    initial begin
        #1;
        if ((actual_EX === {175{1'bx}}) && (actual_MEM === {76{1'bx}}) &&
            (actual_WB === {38{1'bx}})) begin
            passed = passed + 1;
            $display("PASS: reset is synchronous; outputs remain uninitialized before t=2.");
        end
        else begin
            failed = failed + 1;
            $display("FAIL: outputs initialized before the first rising edge.");
        end
    end

    always @(posedge Clk) begin
        if (Reset) begin
            expected_WB = 38'b0;
            expected_MEM = 76'b0;
            expected_EX = 175'b0;
        end
        else begin
            // Update the reference from WB backwards so every RHS uses old stages.
            if (ref_MemToReg_MEM)
                expected_WB = {ref_ALU_MEM, ref_RD_MEM, ref_RF_LE_MEM};
            else
                expected_WB = {DataMemory_DO, ref_RD_MEM, ref_RF_LE_MEM};
            expected_MEM = {ref_Output, ref_PB_EX, ref_RD_EX, ref_effective_RF_LE,
                            ref_RW_EX, ref_E_EX, ref_Size_EX, ref_SE_EX, ref_MemToReg_EX};
            expected_EX = {PC_ID + 32'd8, TA_ID, PA_ID, PB_ID, I_ID[10:6],
                           I_ID[15:0], ref_RD_ID, expected_NOP};
        end
        #0.001;                   // Sample after all sequential updates settle.
        for (check_number = 0; check_number < 9; check_number = check_number + 1) begin
            case (check_number)
                0: begin
                    check_name = "ROM word and PC association";
                    check_ok = (PC_ID < 100) && (PC_ID[1:0] == 2'b00) &&
                               (I_ID === program_words[PC_ID / 4]);
                end
                1: begin
                    check_name = "ID controls from machine bits";
                    check_ok = ref_valid && (actual_ID === expected_ID);
                end
                2: begin
                    check_name = "NOP MUX controls";
                    check_ok = (actual_NOP === expected_NOP);
                end
                3: begin
                    check_name = "IDEX data/control latency/reset";
                    check_ok = (actual_EX === expected_EX);
                end
                4: begin
                    check_name = "EXMEM data/control latency/reset";
                    check_ok = (actual_MEM === expected_MEM);
                end
                5: begin
                    check_name = "MEMWB data/control latency/reset";
                    check_ok = (actual_WB === expected_WB);
                end
                6: begin
                    check_name = "Real EX ALU/branch/write/output";
                    check_ok = (dut.OA_EX === ref_A) && (dut.OB_EX === ref_B) &&
                               (dut.ALU_Result_EX === ref_Result) &&
                               (dut.LE_EX === ref_LE) && (dut.EQ_EX === ref_EQ) && (dut.GT_EX === ref_GT) &&
                               (BranchTaken_EX === ref_BranchTaken) &&
                               (dut.WriteAllowed_EX === ref_WriteAllowed) &&
                               (dut.RF_LE_effective_EX === ref_effective_RF_LE) &&
                               (dut.Result_EX === ref_Output);
                end
                7: begin
                    check_name = "RegDst and exposed IF routing";
                    check_ok = (dut.RD_ID === ref_RD_ID) &&
                               (Redirect_IF === (ref_Jump || ref_BranchTaken)) &&
                               (Target_IF === (ref_BranchTaken ? ref_TA_EX : TA_ID));
                end
                8: begin
                    check_name = "Memory boundary and WB MUX";
                    check_ok = (Memory_Address === ref_ALU_MEM) && (Memory_DI === ref_SD_MEM) &&
                               (Memory_RW === ref_RW_MEM) && (Memory_E === ref_E_MEM) &&
                               (Memory_Size === ref_Size_MEM) && (Memory_SE === ref_SE_MEM) &&
                               (dut.PW_MEM === (ref_MemToReg_MEM ? ref_ALU_MEM : DataMemory_DO));
                end
            endcase
            if (check_ok === 1'b1) passed = passed + 1;
            else begin
                failed = failed + 1;
                $display("FAIL t=%0t %0s", $time, check_name);
                $display("EX actual=%h expected=%h MEM actual=%h expected=%h WB actual=%h expected=%h",
                         actual_EX, expected_EX, actual_MEM, expected_MEM, actual_WB, expected_WB);
            end
        end
        if (($time == 74) || ($time == 78) || ($time == 82)) begin
            check_ok = (($time == 74) && (actual_EX[20:0] === 21'b0)) ||
                       (($time == 78) && (actual_MEM[6:0] === 7'b0)) ||
                       (($time == 82) && (RF_LE_WB === 1'b0));
            if (check_ok === 1'b1) passed = passed + 1;
            else begin failed = failed + 1; $display("FAIL: bubble propagation at t=%0t", $time); end
        end
        $display("\n%0s PC_ID=%0d I_ID=%h t=%0d S=%b [PARTIAL ID stimulus]", mnemonic, PC_ID, I_ID, $time, S);
        $display("ID: Jump=%b RegDst=%b OS1=%b OS2=%b OP=%b BranchType=%b WriteCond=%b RF_LE=%b MemToReg=%b RW_MEM_CTRL=%b E=%b Size=%b SE=%b L=%b OutSel=%b SRA=%b SRB=%b",
                 Jump_ID, dut.RegDst_ID, dut.OS1_ID, dut.OS2_ID, dut.OP_ID, dut.BranchType_ID,
                 dut.WriteCond_ID, dut.RF_LE_ID, dut.MemToReg_ID, dut.RW_ID, dut.E_ID,
                 dut.Size_ID, dut.SE_ID, dut.L_ID, dut.OutSel_ID, dut.SRA_ID, dut.SRB_ID);
        $display("EX: OS1=%b OS2=%b OP=%b BranchType=%b WriteCond=%b RF_LE=%b RF_LE_effective=%b MemToReg=%b RW=%b E=%b Size=%b SE=%b L=%b OutSel=%b BranchTaken=%b",
                 dut.OS1_EX, dut.OS2_EX, dut.OP_EX, dut.BranchType_EX, dut.WriteCond_EX,
                 dut.RF_LE_EX, dut.RF_LE_effective_EX, dut.MemToReg_EX, dut.RW_EX, dut.E_EX,
                 dut.Size_EX, dut.SE_EX, dut.L_EX, dut.OutSel_EX, BranchTaken_EX);
        $display("MEM: RF_LE=%b MemToReg=%b RW[0]=%b E=%b Size=%b SE=%b [L_MEM absent in diagram]",
                 dut.RF_LE_MEM, dut.MemToReg_MEM, Memory_RW, Memory_E, Memory_Size, Memory_SE);
        $display("WB: RF_LE=%b RW_destination[4:0]=%b PW=%h", RF_LE_WB, RW_WB, PW_WB);
    end

    always @(negedge Clk) begin
        if (($time > 0) && ($time < 84)) begin
            #0.001;
            for (hold_number = 0; hold_number < 3; hold_number = hold_number + 1) begin
                case (hold_number)
                    0: check_ok = (actual_EX === expected_EX);
                    1: check_ok = (actual_MEM === expected_MEM);
                    2: check_ok = (actual_WB === expected_WB);
                endcase
                if (check_ok === 1'b1) passed = passed + 1;
                else begin
                    failed = failed + 1;
                    $display("FAIL: register hold at falling edge t=%0t stage=%0d", $time, hold_number);
                end
            end
        end
    end
endmodule
