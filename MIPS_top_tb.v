`timescale 1ns/1ps

// Phase III: real PASG + instruction ROM + control-unit pipeline.
// Run from the MIPS-Architecture repository root.
module MIPS_top_tb;
    reg Clk;
    reg Reset;
    reg S;
    integer byte_index;
    integer passed;
    integer failed;
    integer decoder_alerts;

    MIPS_top dut (.Clk(Clk), .Reset(Reset), .S(S));

    // Group the controls only to make pipeline comparisons easier to read.
    wire [20:0] controls_ID = {
        dut.OS1_ID, 
        dut.OS2_ID, 
        dut.OP_ID,
        dut.BranchType_ID, 
        dut.WriteCond_ID, 
        dut.RF_LE_ID, 
        dut.MemToReg_ID,
        dut.RW_ID, 
        dut.E_ID, 
        dut.Size_ID, 
        dut.SE_ID, 
        dut.L_ID, 
        dut.OutSel_ID};
    wire [20:0] controls_mux = {
      dut.OS1_mux, 
      dut.OS2_mux, 
      dut.OP_mux,
      dut.BranchType_mux, 
      dut.WriteCond_mux, 
      dut.RF_LE_mux, 
      dut.MemToReg_mux,
      dut.RW_mux,
       dut.E_mux, 
       dut.Size_mux, 
       dut.SE_mux, 
       dut.L_mux, 
       dut.OutSel_mux};
    wire [20:0] controls_EX = {
      dut.OS1_ex, 
      dut.OS2_ex, 
      dut.OP_ex,
      dut.BranchType_ex, 
      dut.WriteCond_ex, 
      dut.RF_LE_ex, 
      dut.MemToReg_ex,
      dut.RW_ex, 
      dut.E_ex, 
      dut.Size_ex, 
      dut.SE_ex, 
      dut.L_ex, 
      dut.OutSel_ex};
    wire [6:0] controls_MEM_input = {
      dut.RF_LE_ex, 
      dut.RW_ex, 
      dut.E_ex,
      dut.Size_ex, 
      dut.SE_ex, 
      dut.MemToReg_ex};
    wire [6:0] controls_MEM = {
      dut.RF_LE_mem, 
      dut.RW_mem, 
      dut.E_mem,
      dut.Size_mem, 
      dut.SE_mem, 
      dut.MemToReg_mem};

    reg [20:0] expected_EX;
    reg [6:0] expected_MEM;
    reg expected_WB;
    reg [31:0] expected_instruction;
    reg [31:0] expected_ID_PC;
    reg [31:0] expected_IF_PC;

    // Monitor-only labels: follow the instruction associated with each control.
    // 0 = reset/empty, 1 = instruction, 2 = inserted bubble, 3 = rejected decode.
    reg trace_ID_ready;
    reg [1:0] trace_EX_kind, trace_MEM_kind, trace_WB_kind;
    reg [31:0] trace_EX_word, trace_MEM_word, trace_WB_word;
    reg [31:0] trace_EX_PC, trace_MEM_PC, trace_WB_PC;

    // Requirement: Clk starts at 0 and changes every two time units.
    initial begin
        Clk = 1'b0;
        forever #2 Clk = ~Clk;
    end

    // Requirement: Reset falls at 3, S rises at 72, simulation ends at 84.
    initial begin
        $timeformat(-9, 0, " ns", 6);
        Reset = 1'b1;
        S = 1'b0;
        passed = 0;
        failed = 0;
        decoder_alerts = 0;

        for (byte_index = 0; byte_index < 512; byte_index = byte_index + 1)
            dut.IM.Mem[byte_index] = 8'b0;
        $readmemb("Instruction Memory/test_instructions_memory.txt", dut.IM.Mem, 0, 99);

        #3 Reset = 1'b0;
        #69 S = 1'b1;  // Absolute time is now 72.
        #12;
        $display("\nIntegration checks: %0d passed, %0d failed.", passed, failed);
        $display("Decoder alerts: %0d. Inspect these separately from the wiring/latency checks.", decoder_alerts);
        if (failed != 0) $stop;
        $finish;
    end

    function [95:0] instruction_name;
        input [31:0] word;
        begin
            instruction_name = "INVALID";
            if (word === 32'b0) instruction_name = "NOP";
            else case (word[31:26])
                6'b000000: case (word[5:0])
                    6'b100000: instruction_name = "ADD";
                    6'b100010: instruction_name = "SUB";
                    6'b000011: instruction_name = "SRA";
                    6'b000100: instruction_name = "SLLV";
                    6'b001010: instruction_name = "MOVZ";
                    6'b001011: instruction_name = "MOVN";
                    6'b001000: instruction_name = "JR";
                    6'b001001: instruction_name = "JALR";
                    default: instruction_name = "R-TYPE";
                endcase
                6'b001000: instruction_name = "ADDI";
                6'b001001: instruction_name = "ADDIU";
                6'b100100: instruction_name = "LBU";
                6'b100001: instruction_name = "LH";
                6'b101011: instruction_name = "SW";
                6'b000001: case (word[20:16])
                    5'b10001: instruction_name = "BGEZAL";
                    5'b10000: instruction_name = "BLTZAL";
                    5'b00001: instruction_name = "BGEZ";
                    5'b00000: instruction_name = "BLTZ";
                    default: instruction_name = "INVALID";
                endcase
                6'b000100: instruction_name = "BEQ";
                6'b000111: instruction_name = "BGTZ";
                6'b000011: instruction_name = "JAL";
                6'b001111: instruction_name = "LUI";
                default: instruction_name = "INVALID";
            endcase
        end
    endfunction

    task check;
        input condition;
        input [319:0] label_text;
        begin
            if (condition === 1'b1) passed = passed + 1;
            else begin
                failed = failed + 1;
                $display("FAIL at %0t: %0s", $time, label_text);
            end
        end
    endtask

    task print_stage_label;
        input [23:0] stage_name;
        input [1:0] kind;
        input [31:0] word;
        input [31:0] pc_value;
        begin
            if (kind == 2'd0)
                $write("Etapa %0s: RESET/NOP | ", stage_name);
            else if (kind == 2'd2)
                $write("Etapa %0s: BUBBLE (S=1) | ", stage_name);
            else if (kind == 2'd3)
                $write("Etapa %0s: %0s PC=%0d [UNSUPPORTED] | ",
                       stage_name, instruction_name(word), pc_value);
            else
                $write("Etapa %0s: %0s PC=%0d | ",
                       stage_name, instruction_name(word), pc_value);
        end
    endtask

    task check_first_register_writes;
        input [31:0] word;
        input [31:0] pc_value;
        input write_enable;
        input [319:0] stage_description;
        begin
            if (((word === 32'h20050000) && (pc_value === 32'd0)) ||
                ((word === 32'h00031822) && (pc_value === 32'd4)))
                check(write_enable === 1'b1, stage_description);
        end
    endtask

    always @(posedge Clk) begin
        // Capture what each register must sample BEFORE nonblocking updates.
        expected_instruction = Reset ? 32'b0 : dut.Instruction_Memory;
        expected_ID_PC = Reset ? 32'b0 : dut.program_counter;
        expected_IF_PC = Reset ? 32'b0 : dut.program_counter + 32'd4;
        expected_EX = Reset ? 21'b0 : controls_mux;
        expected_MEM = Reset ? 7'b0 : controls_MEM_input;
        expected_WB = Reset ? 1'b0 : dut.RF_LE_mem;

        // These diagnostic tags sample the OLD ID instruction, just like IDEX.
        // Update downstream tags first so every label advances only one stage.
        if (Reset) begin
            trace_ID_ready = 1'b0;
            trace_EX_kind = 2'd0;
            trace_MEM_kind = 2'd0;
            trace_WB_kind = 2'd0;
            trace_EX_word = 32'b0;
            trace_MEM_word = 32'b0;
            trace_WB_word = 32'b0;
            trace_EX_PC = 32'b0;
            trace_MEM_PC = 32'b0;
            trace_WB_PC = 32'b0;
        end else begin
            trace_WB_kind = trace_MEM_kind;
            trace_WB_word = trace_MEM_word;
            trace_WB_PC = trace_MEM_PC;
            trace_MEM_kind = trace_EX_kind;
            trace_MEM_word = trace_EX_word;
            trace_MEM_PC = trace_EX_PC;
            if (S) begin
                trace_EX_kind = 2'd2;
                trace_EX_word = 32'b0;
                trace_EX_PC = 32'b0;
            end else if (!trace_ID_ready) begin
                trace_EX_kind = 2'd0;
                trace_EX_word = 32'b0;
                trace_EX_PC = 32'b0;
            end else begin
                trace_EX_kind = dut.CU.instruction_supported ? 2'd1 : 2'd3;
                trace_EX_word = dut.Instruction;
                trace_EX_PC = dut.PASG.Q0;
            end
            trace_ID_ready = 1'b1;
        end

        // Wait one picosecond for registers, ROM, and decoder to settle.
        #0.001;
        check(dut.Instruction === expected_instruction, "IF/ID instruction capture");
        check(dut.PASG.Q0 === expected_ID_PC, "IF/ID instruction address capture");
        check(dut.program_counter === expected_IF_PC, "sequential fetch address");
        check(controls_EX === expected_EX, "ID/EX control propagation/reset");
        check(controls_MEM === expected_MEM, "EX/MEM control propagation/reset");
        check(dut.RF_LE_wb === expected_WB, "MEM/WB control propagation/reset");
        check(controls_mux === (S ? 21'b0 : controls_ID), "NOP mux selection");
        check((^controls_ID !== 1'bx), "ID controls have no floating/unknown bits");

        check_first_register_writes(dut.Instruction, dut.PASG.Q0, dut.RF_LE_ID,
                                    "ADDI/SUB RF_LE stays asserted in ID");
        check_first_register_writes(trace_EX_word, trace_EX_PC, dut.RF_LE_ex,
                                    "ADDI/SUB RF_LE stays asserted in EX");
        check_first_register_writes(trace_MEM_word, trace_MEM_PC, dut.RF_LE_mem,
                                    "ADDI/SUB RF_LE stays asserted in MEM");
        check_first_register_writes(trace_WB_word, trace_WB_PC, dut.RF_LE_wb,
                                    "ADDI/SUB RF_LE stays asserted in WB");

        $display("\n%0s (ID), PC=%0d, I=%h, t=%0t, S=%b",
                 instruction_name(dut.Instruction), dut.PASG.Q0, dut.Instruction, $time, S);
        print_stage_label("ID", Reset ? 2'd0 :
                          (dut.CU.instruction_supported ? 2'd1 : 2'd3),
                          dut.Instruction, dut.PASG.Q0);
        $display("Jump=%b RegDst=%b OS1=%b OS2=%b OP=%b BranchType=%b WriteCond=%b RF_LE=%b MemToReg=%b RW=%b E=%b Size=%b SE=%b L=%b OutSel=%b SRA=%b SRB=%b",
            dut.Jump_ID, dut.RegDst_ID, dut.OS1_ID, dut.OS2_ID, dut.OP_ID,
            dut.BranchType_ID, dut.WriteCond_ID, dut.RF_LE_ID, dut.MemToReg_ID,
            dut.RW_ID, dut.E_ID, dut.Size_ID, dut.SE_ID, dut.L_ID, dut.OutSel_ID, dut.SRA_ID, dut.SRB_ID);
        print_stage_label("EX", trace_EX_kind, trace_EX_word, trace_EX_PC);
        $display("OS1=%b OS2=%b OP=%b BranchType=%b WriteCond=%b RF_LE=%b MemToReg=%b RW=%b E=%b Size=%b SE=%b L=%b OutSel=%b",
            dut.OS1_ex, dut.OS2_ex, dut.OP_ex, dut.BranchType_ex, dut.WriteCond_ex,
            dut.RF_LE_ex, dut.MemToReg_ex, dut.RW_ex, dut.E_ex, dut.Size_ex, dut.SE_ex, dut.L_ex, dut.OutSel_ex);
        print_stage_label("MEM", trace_MEM_kind, trace_MEM_word, trace_MEM_PC);
        $display("RF_LE=%b MemToReg=%b RW=%b E=%b Size=%b SE=%b",
            dut.RF_LE_mem, dut.MemToReg_mem, dut.RW_mem, dut.E_mem, dut.Size_mem, dut.SE_mem);
        print_stage_label("WB", trace_WB_kind, trace_WB_word, trace_WB_PC);
        $display("RF_LE=%b", dut.RF_LE_wb);
        if (dut.CU.instruction_supported === 1'b0) begin
            decoder_alerts = decoder_alerts + 1;
            $display("ALERT: control unit rejects this instruction/encoding.");
        end
    end
endmodule
