`timescale 1ns/1ps

module ex_mem_tb;
    reg Clk;
    reg Reset;

    // Unit-test inputs stand in for the results and controls produced in EX.
    wire [31:0] ALU_in;
    wire [31:0] SD_in;
    wire [4:0] RD_in;
    wire RF_LE_in;
    wire RW_in;
    wire E_in;
    wire [1:0] Size_in;
    wire SE_in;
    wire MemToReg_in;

    wire [31:0] ALU_out;
    wire [31:0] SD_out;
    wire [4:0] RD_out;
    wire RF_LE_out;
    wire RW_out;
    wire E_out;
    wire [1:0] Size_out;
    wire SE_out;
    wire MemToReg_out;

    // Mapping: [75:44] ALU, [43:12] SD, [11:7] RD, [6] RF_LE,
    // [5] RW, [4] E, [3:2] Size, [1] SE, [0] MemToReg.
    reg [75:0] input_pattern;
    reg [75:0] initial_pattern;
    reg [75:0] expected_outputs;
    wire [75:0] actual_outputs;
    integer pattern_number;
    integer step_number;
    integer passed;
    integer failed;

    assign ALU_in = input_pattern[75:44];
    assign SD_in = input_pattern[43:12];
    assign RD_in = input_pattern[11:7];
    assign RF_LE_in = input_pattern[6];
    assign RW_in = input_pattern[5];
    assign E_in = input_pattern[4];
    assign Size_in = input_pattern[3:2];
    assign SE_in = input_pattern[1];
    assign MemToReg_in = input_pattern[0];

    assign actual_outputs = {ALU_out, SD_out, RD_out, RF_LE_out,
                             RW_out, E_out, Size_out, SE_out, MemToReg_out};

    EXMEM pipeline_register (
        .Clk(Clk),
        .Reset(Reset),
        .ALU_in(ALU_in),
        .SD_in(SD_in),
        .RD_in(RD_in),
        .RF_LE_in(RF_LE_in),
        .RW_in(RW_in),
        .E_in(E_in),
        .Size_in(Size_in),
        .SE_in(SE_in),
        .MemToReg_in(MemToReg_in),
        .ALU_out(ALU_out),
        .SD_out(SD_out),
        .RD_out(RD_out),
        .RF_LE_out(RF_LE_out),
        .RW_out(RW_out),
        .E_out(E_out),
        .Size_out(Size_out),
        .SE_out(SE_out),
        .MemToReg_out(MemToReg_out)
    );

    initial begin
        passed = 0;
        failed = 0;
        Clk = 1'b0;
        Reset = 1'b1;
        input_pattern = ~76'b0;
        expected_outputs = 76'b0;

        #1;
        Clk = 1'b1;
        #1;                         // Wait for nonblocking assignments to finish.
        if (actual_outputs === expected_outputs) begin
            passed = passed + 1;
            $display("PASS: initial reset clears all 76 bits.");
        end
        else begin
            failed = failed + 1;
            $display("FAIL: initial reset actual=%h expected=%h", actual_outputs, expected_outputs);
        end
        Clk = 1'b0;
        #1;

        // Four base patterns plus one pattern for each individual stored bit.
        // This also checks captures when RF_LE=0: it is not a load enable.
        for (pattern_number = 0; pattern_number < 80; pattern_number = pattern_number + 1) begin
            case (pattern_number)
                0: initial_pattern = 76'b0;
                1: initial_pattern = ~76'b0;
                2: initial_pattern = {38{2'b10}};
                3: initial_pattern = {38{2'b01}};
                default: initial_pattern = 76'b1 << (pattern_number - 4);
            endcase

            for (step_number = 0; step_number < 4; step_number = step_number + 1) begin
                case (step_number)
                    0: begin
                        Reset = 1'b0;
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
                    $display("PASS: pattern=%0d step=%0d Clk=%b, all 76 bits match.",
                             pattern_number, step_number, Clk);
                end
                else begin
                    failed = failed + 1;
                    $display("FAIL: pattern=%0d step=%0d actual=%h expected=%h",
                             pattern_number, step_number, actual_outputs, expected_outputs);
                    $display("ALU=%h SD=%h RD=%b RF_LE=%b RW=%b E=%b Size=%b SE=%b MemToReg=%b",
                             ALU_out, SD_out, RD_out, RF_LE_out, RW_out,
                             E_out, Size_out, SE_out, MemToReg_out);
                end
            end
        end

        // Assert reset between rising edges, then check its priority and release.
        for (step_number = 0; step_number < 7; step_number = step_number + 1) begin
            case (step_number)
                0: begin
                    input_pattern = ~76'b0;
                    #1;
                    Clk = 1'b1;
                    expected_outputs = ~76'b0;
                end
                1: begin
                    Reset = 1'b1;
                    input_pattern = 76'b0;
                end
                2: begin
                    Clk = 1'b0;
                end
                3: begin
                    input_pattern = ~76'b0;
                    #1;
                    Clk = 1'b1;
                    expected_outputs = 76'b0;
                end
                4: begin
                    Reset = 1'b0;
                end
                5: begin
                    Clk = 1'b0;
                end
                6: begin
                    Clk = 1'b1;
                    expected_outputs = ~76'b0;
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

        $display("RESULT: passed=%0d failed=%0d total=%0d", passed, failed, passed + failed);
        if (failed != 0) begin
            $stop;
        end
        $finish;
    end
endmodule
