`timescale 1ns/1ps

module id_ex_tb;
    reg Clk;
    reg Reset;
    reg S;

    wire [31:0] PC8_in;
    wire [31:0] TA_in;
    wire [31:0] PA_in;
    wire [31:0] PB_in;
    wire [4:0] SA_in;
    wire [15:0] I_in;
    wire [4:0] RD_in;

    wire OS1_in;
    wire [1:0] OS2_in;
    wire [3:0] OP_in;
    wire [2:0] BranchType_in;
    wire [1:0] WriteCond_in;
    wire RF_LE_in;
    wire MemToReg_in;
    wire RW_in;
    wire E_in;
    wire [1:0] Size_in;
    wire SE_in;
    wire L_in;
    wire OutSel_in;

    wire [31:0] PC8_out;
    wire [31:0] TA_out;
    wire [31:0] PA_out;
    wire [31:0] PB_out;
    wire [4:0] SA_out;
    wire [15:0] I_out;
    wire [4:0] RD_out;
    wire OS1_out;
    wire [1:0] OS2_out;
    wire [3:0] OP_out;
    wire [2:0] BranchType_out;
    wire [1:0] WriteCond_out;
    wire RF_LE_out;
    wire MemToReg_out;
    wire RW_out;
    wire E_out;
    wire [1:0] Size_out;
    wire SE_out;
    wire L_out;
    wire OutSel_out;

    // [174:143] PC8, [142:111] TA, [110:79] PA, [78:47] PB,
    // [46:42] SA, [41:26] I (16 bits), [25:21] RD.
    // Control mapping: [20] OS1, [19:18] OS2, [17:14] OP,
    // [13:11] BranchType, [10:9] WriteCond, [8] RF_LE, [7] MemToReg,
    // [6] RW, [5] E, [4:3] Size, [2] SE, [1] L, [0] OutSel.
    reg [174:0] input_pattern;
    reg [174:0] initial_pattern;
    reg [174:0] expected_outputs;
    wire [174:0] actual_outputs;
    wire [20:0] mux_controls;
    reg [20:0] expected_mux_controls;
    integer pattern_number;
    integer step_number;
    integer passed;
    integer failed;

    assign PC8_in = input_pattern[174:143];
    assign TA_in = input_pattern[142:111];
    assign PA_in = input_pattern[110:79];
    assign PB_in = input_pattern[78:47];
    assign SA_in = input_pattern[46:42];
    assign I_in = input_pattern[41:26];
    assign RD_in = input_pattern[25:21];

    assign actual_outputs = {PC8_out, TA_out, PA_out, PB_out, SA_out, I_out, RD_out,
                             OS1_out, OS2_out, OP_out, BranchType_out, WriteCond_out,
                             RF_LE_out, MemToReg_out, RW_out, E_out, Size_out,
                             SE_out, L_out, OutSel_out};
    assign mux_controls = {OS1_in, OS2_in, OP_in, BranchType_in, WriteCond_in,
                           RF_LE_in, MemToReg_in, RW_in, E_in, Size_in,
                           SE_in, L_in, OutSel_in};

    NOPMux nop_mux (
        .S(S),
        .OS1_in(input_pattern[20]),
        .OS2_in(input_pattern[19:18]),
        .OP_in(input_pattern[17:14]),
        .BranchType_in(input_pattern[13:11]),
        .WriteCond_in(input_pattern[10:9]),
        .RF_LE_in(input_pattern[8]),
        .MemToReg_in(input_pattern[7]),
        .RW_in(input_pattern[6]),
        .E_in(input_pattern[5]),
        .Size_in(input_pattern[4:3]),
        .SE_in(input_pattern[2]),
        .L_in(input_pattern[1]),
        .OutSel_in(input_pattern[0]),
        .OS1_out(OS1_in),
        .OS2_out(OS2_in),
        .OP_out(OP_in),
        .BranchType_out(BranchType_in),
        .WriteCond_out(WriteCond_in),
        .RF_LE_out(RF_LE_in),
        .MemToReg_out(MemToReg_in),
        .RW_out(RW_in),
        .E_out(E_in),
        .Size_out(Size_in),
        .SE_out(SE_in),
        .L_out(L_in),
        .OutSel_out(OutSel_in)
    );

    IDEX pipeline_register (
        .Clk(Clk),
        .Reset(Reset),
        .PC8_in(PC8_in),
        .TA_in(TA_in),
        .PA_in(PA_in),
        .PB_in(PB_in),
        .SA_in(SA_in),
        .I_in(I_in),
        .RD_in(RD_in),
        .OS1_in(OS1_in),
        .OS2_in(OS2_in),
        .OP_in(OP_in),
        .BranchType_in(BranchType_in),
        .WriteCond_in(WriteCond_in),
        .RF_LE_in(RF_LE_in),
        .MemToReg_in(MemToReg_in),
        .RW_in(RW_in),
        .E_in(E_in),
        .Size_in(Size_in),
        .SE_in(SE_in),
        .L_in(L_in),
        .OutSel_in(OutSel_in),
        .PC8_out(PC8_out),
        .TA_out(TA_out),
        .PA_out(PA_out),
        .PB_out(PB_out),
        .SA_out(SA_out),
        .I_out(I_out),
        .RD_out(RD_out),
        .OS1_out(OS1_out),
        .OS2_out(OS2_out),
        .OP_out(OP_out),
        .BranchType_out(BranchType_out),
        .WriteCond_out(WriteCond_out),
        .RF_LE_out(RF_LE_out),
        .MemToReg_out(MemToReg_out),
        .RW_out(RW_out),
        .E_out(E_out),
        .Size_out(Size_out),
        .SE_out(SE_out),
        .L_out(L_out),
        .OutSel_out(OutSel_out)
    );

    initial begin
        passed = 0;
        failed = 0;
        Clk = 1'b0;
        Reset = 1'b1;
        S = 1'b0;
        input_pattern = ~175'b0;
        expected_outputs = 175'b0;

        #1;
        Clk = 1'b1;
        #1;                         // Wait for the nonblocking assignments.
        if (actual_outputs === expected_outputs) begin
            passed = passed + 1;
            $display("PASS: initial synchronous reset clears all 175 bits.");
        end
        else begin
            failed = failed + 1;
            $display("FAIL: initial reset, actual=%h expected=%h", actual_outputs, expected_outputs);
        end
        Clk = 1'b0;
        #1;

        // Zero, ones, two alternating patterns and each of the 175 bits alone.
        for (pattern_number = 0; pattern_number < 179; pattern_number = pattern_number + 1) begin
            case (pattern_number)
                0: initial_pattern = 175'b0;
                1: initial_pattern = ~175'b0;
                2: initial_pattern = {{87{2'b10}}, 1'b1};
                3: initial_pattern = {{87{2'b01}}, 1'b0};
                default: initial_pattern = 175'b1 << (pattern_number - 4);
            endcase

            for (step_number = 0; step_number < 4; step_number = step_number + 1) begin
                case (step_number)
                    0: begin
                        Reset = 1'b0;
                        S = 1'b0;
                        input_pattern = initial_pattern;
                    end
                    1: begin
                        Clk = 1'b1;
                        expected_outputs = initial_pattern;
                    end
                    2: begin
                        input_pattern = ~initial_pattern;
                    end
                    3: begin
                        Clk = 1'b0;
                    end
                endcase

                #1;
                if (actual_outputs === expected_outputs) begin
                    passed = passed + 1;
                    $display("PASS: pattern=%0d step=%0d Clk=%b, all 175 bits match.",
                             pattern_number, step_number, Clk);
                end
                else begin
                    failed = failed + 1;
                    $display("FAIL: pattern=%0d step=%0d actual=%h expected=%h",
                             pattern_number, step_number, actual_outputs, expected_outputs);
                end
            end
        end

        // Reset must clear ones on a rising edge, not immediately or on negedge.
        for (step_number = 0; step_number < 7; step_number = step_number + 1) begin
            case (step_number)
                0: begin
                    input_pattern = ~175'b0;
                    #1;
                    Clk = 1'b1;
                    expected_outputs = ~175'b0;
                end
                1: begin
                    Reset = 1'b1;
                    input_pattern = 175'b0;
                end
                2: begin
                    Clk = 1'b0;
                end
                3: begin
                    input_pattern = ~175'b0;
                    #1;
                    Clk = 1'b1;
                    expected_outputs = 175'b0;
                end
                4: begin
                    Reset = 1'b0;
                end
                5: begin
                    Clk = 1'b0;
                end
                6: begin
                    Clk = 1'b1;
                    expected_outputs = ~175'b0;
                end
            endcase

            #1;
            if (actual_outputs === expected_outputs) begin
                passed = passed + 1;
                $display("PASS: reset step=%0d Clk=%b Reset=%b.", step_number, Clk, Reset);
            end
            else begin
                failed = failed + 1;
                $display("FAIL: reset step=%0d actual=%h expected=%h",
                         step_number, actual_outputs, expected_outputs);
            end
        end

        // Integration: a bubble clears controls, while data still gets captured.
        for (step_number = 0; step_number < 6; step_number = step_number + 1) begin
            case (step_number)
                0: begin
                    S = 1'b1;
                    input_pattern = {32'h0000006C,
                                     32'h12345678,
                                     32'h89ABCDEF,
                                     32'hFEDCBA98,
                                     5'b10101,
                                     16'hA55A,
                                     5'b11011,
                                     21'b101010101010101010101};
                    expected_mux_controls = 21'b0;
                    // MUX clears now; IDEX must hold its previous ones.
                end
                1: begin
                    Clk = 1'b0;
                end
                2: begin
                    Clk = 1'b1;
                    expected_outputs = {input_pattern[174:21], 21'b0};
                end
                3: begin
                    S = 1'b0;
                    expected_mux_controls = input_pattern[20:0];
                    // Controls return at the MUX, but IDEX holds the bubble.
                end
                4: begin
                    Clk = 1'b0;
                end
                5: begin
                    Clk = 1'b1;
                    expected_outputs = input_pattern;
                end
            endcase

            #1;
            if ((actual_outputs === expected_outputs) &&
                (mux_controls === expected_mux_controls)) begin
                passed = passed + 1;
                $display("PASS: NOP MUX step=%0d S=%b Clk=%b controls_in=%b controls_out=%b.",
                         step_number, S, Clk, mux_controls, actual_outputs[20:0]);
            end
            else begin
                failed = failed + 1;
                $display("FAIL: NOP MUX step=%0d actual=%h expected=%h controls_in=%b expected_in=%b",
                         step_number, actual_outputs, expected_outputs,
                         mux_controls, expected_mux_controls);
            end
        end

        $display("RESULT: passed=%0d failed=%0d total=%0d", passed, failed, passed + failed);
        if (failed != 0) begin
            $stop;
        end
        $finish;
    end
endmodule
