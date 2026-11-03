`timescale 1ns/1ps

module mem_wb_tb;
    reg Clk;
    reg Reset;
    wire [31:0] PW_in;
    wire [4:0] RW_in;
    wire RF_LE_in;
    wire [31:0] PW_out;
    wire [4:0] RW_out;
    wire RF_LE_out;

    // Test-vector mapping only: [37:6] PW, [5:1] RW, [0] RF_LE.
    reg [37:0] input_pattern;
    reg [37:0] initial_pattern;
    reg [37:0] expected_outputs;
    wire [37:0] actual_outputs;
    integer pattern_number;
    integer step_number;
    integer passed;
    integer failed;

    assign PW_in = input_pattern[37:6];
    assign RW_in = input_pattern[5:1];
    assign RF_LE_in = input_pattern[0];
    assign actual_outputs = {PW_out, RW_out, RF_LE_out};

    MEMWB pipeline_register (
        .Clk(Clk),
        .Reset(Reset),
        .PW_in(PW_in),
        .RW_in(RW_in),
        .RF_LE_in(RF_LE_in),
        .PW_out(PW_out),
        .RW_out(RW_out),
        .RF_LE_out(RF_LE_out)
    );

    initial begin
        passed = 0;
        failed = 0;
        Clk = 1'b0;
        Reset = 1'b1;
        input_pattern = ~38'b0;
        expected_outputs = 38'b0;

        #1;
        Clk = 1'b1;
        #1;                         // Wait for nonblocking assignments.
        if (actual_outputs === expected_outputs) begin
            passed = passed + 1;
            $display("PASS: initial reset clears all 38 bits.");
        end
        else begin
            failed = failed + 1;
            $display("FAIL: initial reset actual=%h expected=%h", actual_outputs, expected_outputs);
        end
        Clk = 1'b0;
        #1;

        // Four base patterns and one pattern for each individual stored bit.
        // Data must also be captured when RF_LE is zero.
        for (pattern_number = 0; pattern_number < 42; pattern_number = pattern_number + 1) begin
            case (pattern_number)
                0: initial_pattern = 38'b0;
                1: initial_pattern = ~38'b0;
                2: initial_pattern = {19{2'b10}};
                3: initial_pattern = {19{2'b01}};
                default: initial_pattern = 38'b1 << (pattern_number - 4);
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
                    $display("PASS: pattern=%0d step=%0d Clk=%b, all 38 bits match.",
                             pattern_number, step_number, Clk);
                end
                else begin
                    failed = failed + 1;
                    $display("FAIL: pattern=%0d step=%0d actual=%h expected=%h",
                             pattern_number, step_number, actual_outputs, expected_outputs);
                end
            end
        end

        // Check synchronous assertion, priority, synchronous release and recovery.
        for (step_number = 0; step_number < 7; step_number = step_number + 1) begin
            case (step_number)
                0: begin
                    input_pattern = ~38'b0;
                    #1;
                    Clk = 1'b1;
                    expected_outputs = ~38'b0;
                end
                1: begin
                    Reset = 1'b1;
                    input_pattern = 38'b0;
                end
                2: begin
                    Clk = 1'b0;
                end
                3: begin
                    input_pattern = ~38'b0;
                    #1;
                    Clk = 1'b1;
                    expected_outputs = 38'b0;
                end
                4: begin
                    Reset = 1'b0;
                end
                5: begin
                    Clk = 1'b0;
                end
                6: begin
                    Clk = 1'b1;
                    expected_outputs = ~38'b0;
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

// Separate top: real EXMEM -> testbench Writeback MUX -> real MEMWB.
// DataMemory.DO is represented by two fixed read values, not a RAM implementation.
module mem_wb_path_tb;
    reg Clk;
    reg Reset;
    reg [31:0] ALU_EX;
    reg [4:0] RD_EX;
    reg RF_LE_EX;
    reg MemToReg_EX;

    wire [31:0] ALU_MEM;
    wire [4:0] RD_MEM;
    wire RF_LE_MEM;
    wire MemToReg_MEM;
    reg [31:0] memory_data;
    reg [31:0] PW_MEM;
    wire [31:0] PW_WB;
    wire [4:0] RW_WB;
    wire RF_LE_WB;

    reg [31:0] expected_selected_data;
    reg [31:0] previous_selected_data;
    reg [31:0] expected_PW_WB;
    reg [4:0] expected_RW_WB;
    reg expected_RF_LE_WB;
    reg [255:0] test_name;
    integer transaction_number;
    integer step_number;
    integer passed;
    integer failed;

    EXMEM memory_stage (
        .Clk(Clk),
        .Reset(Reset),
        .ALU_in(ALU_EX),
        .SD_in(32'b0),
        .RD_in(RD_EX),
        .RF_LE_in(RF_LE_EX),
        .RW_in(1'b0),
        .E_in(1'b0),
        .Size_in(2'b10),
        .SE_in(1'b0),
        .MemToReg_in(MemToReg_EX),
        .ALU_out(ALU_MEM),
        .SD_out(),
        .RD_out(RD_MEM),
        .RF_LE_out(RF_LE_MEM),
        .RW_out(),
        .E_out(),
        .Size_out(),
        .SE_out(),
        .MemToReg_out(MemToReg_MEM)
    );

    // Byte ordering, size handling, writes and sign extension are not tested here.
    always @(*) begin
        case (ALU_MEM)
            32'h00000020: memory_data = 32'hA5A55A5A;
            32'h00000010: memory_data = 32'hFFFFFF80;
            default: memory_data = 32'hDEADBEEF;
        endcase
    end

    // Diagram: MemToReg=0 selects memory; MemToReg=1 selects ALU/PC+8.
    // This model is deliberately outside MEMWB, just like the diagram's MUX.
    always @(*) begin
        if (MemToReg_MEM) begin
            PW_MEM = ALU_MEM;
        end
        else begin
            PW_MEM = memory_data;
        end
    end

    MEMWB writeback_stage (
        .Clk(Clk),
        .Reset(Reset),
        .PW_in(PW_MEM),
        .RW_in(RD_MEM),          // 5-bit destination, not EXMEM's 1-bit RW control
        .RF_LE_in(RF_LE_MEM),
        .PW_out(PW_WB),
        .RW_out(RW_WB),
        .RF_LE_out(RF_LE_WB)
    );

    initial begin
        passed = 0;
        failed = 0;
        Clk = 1'b0;
        Reset = 1'b1;
        ALU_EX = 32'b0;
        RD_EX = 5'b0;
        RF_LE_EX = 1'b0;
        MemToReg_EX = 1'b0;
        expected_PW_WB = 32'b0;
        expected_RW_WB = 5'b0;
        expected_RF_LE_WB = 1'b0;
        // After EXMEM reset, MemToReg=0 and address=0 select the model's default
        // memory value. It may enter WB after reset even though RF_LE remains 0.
        previous_selected_data = 32'hDEADBEEF;

        #1;
        Clk = 1'b1;
        #1;
        if ((PW_WB === 32'b0) && (RW_WB === 5'b0) && (RF_LE_WB === 1'b0)) begin
            passed = passed + 1;
            $display("PASS: writeback path reset.");
        end
        else begin
            failed = failed + 1;
            $display("FAIL: writeback path reset.");
        end

        // Each transaction uses two rising edges. The first loads EXMEM;
        // MEMWB sees that transaction only on the second rising edge.
        for (transaction_number = 0; transaction_number < 6; transaction_number = transaction_number + 1) begin
            Clk = 1'b0;
            Reset = 1'b0;
            case (transaction_number)
                0: begin
                    test_name = "ALU result to r5";
                    ALU_EX = 32'h12345678;
                    RD_EX = 5'd5;
                    RF_LE_EX = 1'b1;
                    MemToReg_EX = 1'b1;
                    expected_selected_data = 32'h12345678;
                end
                1: begin
                    test_name = "Memory read to r2";
                    ALU_EX = 32'h00000020;
                    RD_EX = 5'd2;
                    RF_LE_EX = 1'b1;
                    MemToReg_EX = 1'b0;
                    expected_selected_data = 32'hA5A55A5A;
                end
                2: begin
                    test_name = "Selected PC+8 link to r31";
                    ALU_EX = 32'd108;
                    RD_EX = 5'd31;
                    RF_LE_EX = 1'b1;
                    MemToReg_EX = 1'b1;
                    expected_selected_data = 32'd108;
                end
                3: begin
                    test_name = "RF_LE=0 still captures data";
                    ALU_EX = 32'h00000040;
                    RD_EX = 5'd3;
                    RF_LE_EX = 1'b0;
                    MemToReg_EX = 1'b1;
                    expected_selected_data = 32'h00000040;
                end
                4: begin
                    test_name = "Memory output with high bits set";
                    ALU_EX = 32'h00000010;
                    RD_EX = 5'd7;
                    RF_LE_EX = 1'b1;
                    MemToReg_EX = 1'b0;
                    expected_selected_data = 32'hFFFFFF80;
                end
                5: begin
                    test_name = "Zero ALU result and destination";
                    ALU_EX = 32'b0;
                    RD_EX = 5'd0;
                    RF_LE_EX = 1'b1;
                    MemToReg_EX = 1'b1;
                    expected_selected_data = 32'b0;
                end
            endcase

            for (step_number = 0; step_number < 4; step_number = step_number + 1) begin
                case (step_number)
                    0: begin
                    end
                    1: begin
                        Clk = 1'b1;
                        expected_PW_WB = previous_selected_data;
                    end
                    2: begin
                        Clk = 1'b0;
                    end
                    3: begin
                        Clk = 1'b1;
                        expected_PW_WB = expected_selected_data;
                        expected_RW_WB = RD_EX;
                        expected_RF_LE_WB = RF_LE_EX;
                    end
                endcase

                #1;
                if ((PW_WB === expected_PW_WB) &&
                    (RW_WB === expected_RW_WB) &&
                    (RF_LE_WB === expected_RF_LE_WB) &&
                    ((step_number == 0) ||
                     ((PW_MEM === expected_selected_data) &&
                      (RD_MEM === RD_EX) &&
                      (RF_LE_MEM === RF_LE_EX) &&
                      (MemToReg_MEM === MemToReg_EX)))) begin
                    passed = passed + 1;
                    $display("PASS: transaction=%0d %0s step=%0d PW_MEM=%h PW_WB=%h RW_WB=%0d RF_LE_WB=%b",
                             transaction_number, test_name, step_number,
                             PW_MEM, PW_WB, RW_WB, RF_LE_WB);
                end
                else begin
                    failed = failed + 1;
                    $display("FAIL: transaction=%0d step=%0d PW_WB=%h expected=%h RW_WB=%0d expected_RW=%0d RF_LE_WB=%b expected_RF_LE=%b",
                             transaction_number, step_number, PW_WB, expected_PW_WB,
                             RW_WB, expected_RW_WB, RF_LE_WB, expected_RF_LE_WB);
                end
            end
            previous_selected_data = expected_selected_data;
        end

        $display("PATH_RESULT: passed=%0d failed=%0d total=%0d", passed, failed, passed + failed);
        if (failed != 0) begin
            $stop;
        end
        $finish;
    end
endmodule
