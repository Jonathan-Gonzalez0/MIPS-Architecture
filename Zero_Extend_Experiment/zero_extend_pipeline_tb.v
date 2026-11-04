`timescale 1ns/1ps

// Generated ID inputs test the proposal through real ID/EX, EX/MEM and MEM/WB.
// This is a focused experiment, not a ROM/PASG or Register File execution test.
module zero_extend_pipeline_tb;
    reg Clk;
    reg Reset;
    reg S;
    reg [31:0] I_ID;
    reg [31:0] PC_ID;
    reg [31:0] PA_ID;
    reg [31:0] PB_ID;
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
    wire [174:0] actual_EX;
    wire [75:0] actual_MEM;
    wire [37:0] actual_WB;
    wire [20:0] actual_NOP;
    wire [25:0] actual_ID;
    reg [174:0] expected_EX;
    reg [75:0] expected_MEM;
    reg [37:0] expected_WB;
    reg [31:0] expected_result_EX;
    reg [31:0] expected_result_ID;
    reg [1:0] ref_OS2;
    reg [3:0] ref_OP;
    reg ref_RF_LE;
    reg ref_MemToReg;
    reg ref_SRA;
    reg ref_SRB;
    reg [1:0] ref_RegDst;
    reg [4:0] ref_RD;
    wire [20:0] ref_controls;
    wire [25:0] ref_ID;
    reg [5:0] opcode;
    reg [15:0] immediate;
    integer vector_number;
    integer passed;
    integer failed;

    assign actual_EX = {dut.PC8_EX, dut.TA_EX, dut.PA_EX, dut.PB_EX, dut.SA_EX, dut.I_EX, dut.RD_EX, dut.OS1_EX, dut.OS2_EX, dut.OP_EX, dut.BranchType_EX, dut.WriteCond_EX, dut.RF_LE_EX, dut.MemToReg_EX, dut.RW_EX, dut.E_EX, dut.Size_EX, dut.SE_EX, dut.L_EX, dut.OutSel_EX};
    assign actual_MEM = {dut.ALU_MEM, dut.SD_MEM, dut.RD_MEM, dut.RF_LE_MEM, dut.RW_MEM, dut.E_MEM, dut.Size_MEM, dut.SE_MEM, dut.MemToReg_MEM};
    assign actual_WB = {PW_WB, RW_WB, RF_LE_WB};
    assign actual_NOP = {dut.OS1_N, dut.OS2_N, dut.OP_N, dut.BranchType_N, dut.WriteCond_N, dut.RF_LE_N, dut.MemToReg_N, dut.RW_N, dut.E_N, dut.Size_N, dut.SE_N, dut.L_N, dut.OutSel_N};
    assign actual_ID = {dut.Jump_ID, dut.RegDst_ID, dut.OS1_ID, dut.OS2_ID, dut.OP_ID, dut.BranchType_ID, dut.WriteCond_ID, dut.RF_LE_ID, dut.MemToReg_ID, dut.RW_ID, dut.E_ID, dut.Size_ID, dut.SE_ID, dut.L_ID, dut.OutSel_ID, dut.SRA_ID, dut.SRB_ID};
    assign ref_controls = {1'b0, ref_OS2, ref_OP, 3'b000, 2'b00,
                           ref_RF_LE, ref_MemToReg, 1'b0, 1'b0, 2'b00,
                           1'b0, 1'b0, 1'b0};
    assign ref_ID = {1'b0, ref_RegDst, 1'b0, ref_OS2, ref_OP,
                     3'b000, 2'b00, ref_RF_LE, ref_MemToReg,
                     1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, ref_SRA, ref_SRB};

    PhaseIIIZeroExtendPath dut (
        .Clk(Clk), .Reset(Reset), .S(S),
        .I_ID(I_ID), .PC_ID(PC_ID), .TA_ID(32'b0), .PA_ID(PA_ID), .PB_ID(PB_ID),
        .DataMemory_DO(32'h5A5A1234), // Sentinel: logical instructions must select ALU.
        .Jump_ID(Jump_ID), .BranchTaken_EX(BranchTaken_EX),
        .Redirect_IF(Redirect_IF), .Target_IF(Target_IF),
        .Memory_Address(Memory_Address), .Memory_DI(Memory_DI),
        .Memory_RW(Memory_RW), .Memory_E(Memory_E),
        .Memory_Size(Memory_Size), .Memory_SE(Memory_SE),
        .PW_WB(PW_WB), .RW_WB(RW_WB), .RF_LE_WB(RF_LE_WB)
    );

    // Independent instruction semantics for the generated stream.
    always @(*) begin
        ref_OS2 = 2'b00;
        ref_OP = 4'b0000;
        ref_RF_LE = 1'b0;
        ref_MemToReg = 1'b0;
        ref_SRA = 1'b0;
        ref_SRB = 1'b0;
        ref_RegDst = 2'b00;
        ref_RD = I_ID[20:16];
        expected_result_ID = PA_ID + PB_ID;
        case (I_ID[31:26])
            6'b001100, 6'b001101, 6'b001110: begin
                ref_OS2 = 2'b11;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_SRA = 1'b1;
                case (I_ID[31:26])
                    6'b001100: begin
                        ref_OP = 4'b0010;
                        expected_result_ID = PA_ID & {16'b0, I_ID[15:0]};
                    end
                    6'b001101: begin
                        ref_OP = 4'b0011;
                        expected_result_ID = PA_ID | {16'b0, I_ID[15:0]};
                    end
                    6'b001110: begin
                        ref_OP = 4'b0100;
                        expected_result_ID = PA_ID ^ {16'b0, I_ID[15:0]};
                    end
                endcase
            end
            6'b001000: begin
                ref_OS2 = 2'b01;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                ref_SRA = 1'b1;
                expected_result_ID = PA_ID + {{16{I_ID[15]}}, I_ID[15:0]};
            end
            6'b001111: begin
                ref_OS2 = 2'b10;
                ref_OP = 4'b1000;
                ref_RF_LE = 1'b1;
                ref_MemToReg = 1'b1;
                expected_result_ID = {I_ID[15:0], 16'b0};
            end
            6'b000000: begin
                if (I_ID[5:0] == 6'b100101) begin // OR rd,rs,rt
                    ref_OP = 4'b0011;
                    ref_RF_LE = 1'b1;
                    ref_MemToReg = 1'b1;
                    ref_SRA = 1'b1;
                    ref_SRB = 1'b1;
                    ref_RegDst = 2'b01;
                    ref_RD = I_ID[15:11];
                    expected_result_ID = PA_ID | PB_ID;
                end
            end
        endcase
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
        I_ID = 32'b0;
        PC_ID = 32'b0;
        PA_ID = 32'b0;
        PB_ID = 32'b0;
        #3 Reset = 1'b0;

        for (vector_number = 0; vector_number < 15; vector_number = vector_number + 1) begin
            @(negedge Clk);
            #0.1;
            PC_ID = 32'd100 + 4*vector_number;
            PB_ID = 32'hDEADBEEF;
            case (vector_number % 4)
                0: begin immediate = 16'h0000; PA_ID = 32'h00000000; end
                1: begin immediate = 16'h7FFF; PA_ID = 32'hFFFFFFFF; end
                2: begin immediate = 16'h8001; PA_ID = 32'hA5A55A5A; end
                3: begin immediate = 16'hFFFF; PA_ID = 32'h80000000; end
            endcase
            case (vector_number / 4)
                0: opcode = 6'b001100;
                1: opcode = 6'b001101;
                2: opcode = 6'b001110;
                default: opcode = 6'b001000;
            endcase
            I_ID = {opcode, 5'd1, 5'd5, immediate};
            case (vector_number)
                12: begin I_ID = 32'h2025FFFF; PA_ID = 32'd100; end
                13: begin I_ID = 32'h3C058001; PA_ID = 32'hFFFFFFFF; end
                14: begin I_ID = 32'h00221825; PA_ID = 32'hA5000000; PB_ID = 32'h00008001; end
            endcase
        end

        @(negedge Clk);
        #0.1;
        S = 1'b1;
        I_ID = 32'h3025FFFF;
        #0.001;
        if ((actual_NOP === 21'b0) && (actual_EX === expected_EX))
            passed = passed + 1;
        else begin failed = failed + 1; $display("FAIL: immediate bubble before rising edge"); end

        @(negedge Clk);
        #0.1;
        I_ID = 32'h38258001; // A second bubble masks OS2=11 as well.
        @(negedge Clk);
        #0.1;
        S = 1'b0;
        I_ID = 32'b0;
        PA_ID = 32'b0;
        PB_ID = 32'b0;

        repeat (4) @(negedge Clk);
        #0.1;
        Reset = 1'b1;
        #0.001;
        if ((actual_EX === expected_EX) && (actual_MEM === expected_MEM) &&
            (actual_WB === expected_WB)) passed = passed + 1;
        else begin failed = failed + 1; $display("FAIL: reset acted asynchronously"); end

        @(posedge Clk);
        #0.1;
        @(negedge Clk);
        #0.1;
        Reset = 1'b0;
        I_ID = 32'h34258001;
        PA_ID = 32'h80000000;
        PB_ID = 32'hDEADBEEF;
        repeat (3) @(posedge Clk);
        #0.1;
        if ((PW_WB === 32'h80008001) && (RW_WB === 5'd5) && (RF_LE_WB === 1'b1))
            passed = passed + 1;
        else begin failed = failed + 1; $display("FAIL: recovery and final WB result"); end

        $display("EXPERIMENTAL_WB: PW=%h destination=%0d RF_LE=%b", PW_WB, RW_WB, RF_LE_WB);
        $display("ZERO_EXTEND_PIPELINE_RESULT: passed=%0d failed=%0d total=%0d", passed, failed, passed + failed);
        if (failed != 0) $stop;
        $finish;
    end

    always @(posedge Clk) begin
        if (Reset) begin
            expected_EX = 175'b0;
            expected_MEM = 76'b0;
            expected_WB = 38'b0;
            expected_result_EX = 32'b0;
        end
        else begin
            // WB first: each calculation uses the previous pipeline stage.
            if (expected_MEM[0])
                expected_WB = {expected_MEM[75:44], expected_MEM[11:7], expected_MEM[6]};
            else
                expected_WB = {32'h5A5A1234, expected_MEM[11:7], expected_MEM[6]};
            expected_MEM = {expected_result_EX, expected_EX[78:47], expected_EX[25:21],
                            expected_EX[8], expected_EX[6], expected_EX[5],
                            expected_EX[4:3], expected_EX[2], expected_EX[7]};
            expected_EX = {PC_ID + 32'd8, 32'b0, PA_ID, PB_ID, I_ID[10:6], I_ID[15:0],
                           ref_RD, (S ? 21'b0 : ref_controls)};
            if (S) expected_result_EX = PA_ID + PB_ID;
            else expected_result_EX = expected_result_ID;
        end
        #0.001;
        if (actual_EX === expected_EX) passed = passed + 1;
        else begin failed = failed + 1; $display("FAIL: EX state t=%0t", $time); end
        if (actual_MEM === expected_MEM) passed = passed + 1;
        else begin failed = failed + 1; $display("FAIL: MEM state t=%0t actual=%h expected=%h", $time, actual_MEM, expected_MEM); end
        if (actual_WB === expected_WB) passed = passed + 1;
        else begin failed = failed + 1; $display("FAIL: WB state t=%0t", $time); end
        if ((dut.ALU_Result_EX === expected_result_EX) &&
            (BranchTaken_EX === 1'b0) && (Jump_ID === 1'b0) &&
            (Redirect_IF === 1'b0) && (Memory_RW === 1'b0) && (Memory_E === 1'b0))
            passed = passed + 1;
        else begin failed = failed + 1; $display("FAIL: EX logic or memory safety t=%0t", $time); end
        if ((actual_ID === ref_ID) && (actual_NOP === (S ? 21'b0 : ref_controls)))
            passed = passed + 1;
        else begin failed = failed + 1; $display("FAIL: ID or NOP controls t=%0t", $time); end
    end

    always @(negedge Clk) begin
        if ($time > 0) begin
            #0.001;
            if (actual_EX === expected_EX) passed = passed + 1;
            else begin failed = failed + 1; $display("FAIL: EX falling edge"); end
            if (actual_MEM === expected_MEM) passed = passed + 1;
            else begin failed = failed + 1; $display("FAIL: MEM falling edge"); end
            if (actual_WB === expected_WB) passed = passed + 1;
            else begin failed = failed + 1; $display("FAIL: WB falling edge"); end
        end
    end
endmodule
