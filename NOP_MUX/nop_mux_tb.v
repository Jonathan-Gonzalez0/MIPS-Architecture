`timescale 1ns/1ps

module nop_mux_tb;
    reg S;
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

    // Bit mapping, used identically for inputs, expected values and outputs:
    // [20] OS1, [19:18] OS2, [17:14] OP, [13:11] BranchType,
    // [10:9] WriteCond, [8] RF_LE, [7] MemToReg, [6] RW, [5] E,
    // [4:3] Size, [2] SE, [1] L, [0] OutSel.
    reg [20:0] input_pattern;
    reg [20:0] initial_pattern;
    reg [20:0] expected_outputs;
    wire [20:0] actual_outputs;
    integer pattern_number;
    integer step_number;
    integer passed;
    integer failed;

    assign OS1_in = input_pattern[20];
    assign OS2_in = input_pattern[19:18];
    assign OP_in = input_pattern[17:14];
    assign BranchType_in = input_pattern[13:11];
    assign WriteCond_in = input_pattern[10:9];
    assign RF_LE_in = input_pattern[8];
    assign MemToReg_in = input_pattern[7];
    assign RW_in = input_pattern[6];
    assign E_in = input_pattern[5];
    assign Size_in = input_pattern[4:3];
    assign SE_in = input_pattern[2];
    assign L_in = input_pattern[1];
    assign OutSel_in = input_pattern[0];

    assign actual_outputs = {OS1_out, OS2_out, OP_out, BranchType_out,
                             WriteCond_out, RF_LE_out, MemToReg_out, RW_out,
                             E_out, Size_out, SE_out, L_out, OutSel_out};

    NOPMux nop_mux (
        .S(S),
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

        // Four base patterns and 21 patterns with one bit set at a time.
        for (pattern_number = 0; pattern_number < 25; pattern_number = pattern_number + 1) begin
            case (pattern_number)
                0: initial_pattern = 21'b000000000000000000000;
                1: initial_pattern = 21'b111111111111111111111;
                2: initial_pattern = 21'b101010101010101010101;
                3: initial_pattern = 21'b010101010101010101010;
                default: initial_pattern = 21'b1 << (pattern_number - 4);
            endcase

            for (step_number = 0; step_number < 4; step_number = step_number + 1) begin
                case (step_number)
                    0: begin
                        S = 1'b0;
                        input_pattern = initial_pattern;
                        expected_outputs = initial_pattern;
                    end
                    1: begin
                        S = 1'b1;
                        expected_outputs = 21'b0;
                    end
                    2: begin
                        input_pattern = ~initial_pattern;
                        expected_outputs = 21'b0;
                    end
                    3: begin
                        S = 1'b0;
                        expected_outputs = ~initial_pattern;
                    end
                endcase

                // Allow combinational logic to settle; no clock edge is used.
                #1;
                $display("Test %0d: pattern=%0d step=%0d S=%b input=%b output=%b",
                         passed + failed + 1, pattern_number, step_number,
                         S, input_pattern, actual_outputs);
                if (actual_outputs === expected_outputs) begin
                    passed = passed + 1;
                    $display("PASS: all 21 bits match.");
                end
                else begin
                    failed = failed + 1;
                    $display("FAIL: expected=%b", expected_outputs);
                    $display("OS1=%b OS2=%b OP=%b BranchType=%b WriteCond=%b",
                             OS1_out, OS2_out, OP_out, BranchType_out, WriteCond_out);
                    $display("RF_LE=%b MemToReg=%b RW=%b E=%b Size=%b SE=%b L=%b OutSel=%b",
                             RF_LE_out, MemToReg_out, RW_out, E_out, Size_out,
                             SE_out, L_out, OutSel_out);
                end
            end
        end

        $display("RESULT: passed=%0d failed=%0d total=%0d", passed, failed, passed + failed);
        if (failed != 0) begin
            $stop;
        end
        $finish;
    end
endmodule
