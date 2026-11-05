`timescale 1ns/1ps

// Starter test: read four instructions from the professor's file and decode them.
// Run this file from the MIPS-Architecture repository root.
module rom_control_start_tb;
    reg [8:0] A;
    wire [31:0] I;
    wire Jump, OS1, RF_LE, MemToReg, RW, E, SE, L, OutSel, SRA, SRB;
    wire [1:0] RegDst, OS2, WriteCond, Size;
    wire [2:0] BranchType;
    wire [3:0] OP;
    integer passed, failed;

    InstructionMemory memory (.A(A), .I(I));

    // The ROM output drives the control unit's instruction input directly.
    ControlUnit control (
        .I(I), .Jump(Jump), .RegDst(RegDst), .OS1(OS1), .OS2(OS2),
        .OP(OP), .BranchType(BranchType), .WriteCond(WriteCond),
        .RF_LE(RF_LE), .MemToReg(MemToReg), .RW(RW), .E(E),
        .Size(Size), .SE(SE), .L(L), .OutSel(OutSel), .SRA(SRA), .SRB(SRB)
    );

    task check_instruction;
        input [8:0] address;
        input [31:0] expected_instruction;
        input [3:0] expected_OP;
        input [1:0] expected_RegDst;
        input [1:0] expected_OS2;
        input expected_MemToReg;
        input [1:0] expected_Size;
        input expected_SE;
        input expected_L;
        input expected_SRB;
        begin
            A = address;
            #2; // Both the ROM and decoder are combinational.
            $display("A=%0d I=%h OP=%b RegDst=%b OS2=%b RF_LE=%b MemToReg=%b Size=%b SE=%b L=%b SRA=%b SRB=%b",
                     A, I, OP, RegDst, OS2, RF_LE, MemToReg, Size, SE, L, SRA, SRB);

            // All four selected instructions write a register and read rs.
            // None jumps, stores to memory, or conditionally writes a register.
            if ((I === expected_instruction) && (OP === expected_OP) &&
                (RegDst === expected_RegDst) && (OS2 === expected_OS2) &&
                (MemToReg === expected_MemToReg) && (Size === expected_Size) &&
                (SE === expected_SE) && (L === expected_L) && (SRB === expected_SRB) &&
                (RF_LE === 1'b1) && (SRA === 1'b1) && (Jump === 1'b0) &&
                (OS1 === 1'b0) && (BranchType === 3'b000) &&
                (WriteCond === 2'b00) && (RW === 1'b0) && (E === 1'b0) &&
                (OutSel === 1'b0)) begin
                passed = passed + 1;
                $display("PASS: fetched instruction and control signals match.\n");
            end else begin
                failed = failed + 1;
                $display("FAIL: check the instruction word and decoder controls.\n");
            end
        end
    endtask

    initial begin
        A = 9'd0;
        passed = 0;
        failed = 0;
        $readmemb("Instruction Memory/test_instructions_memory.txt", memory.Mem, 0, 99);

        //                  address, word,       OP,    RegDst, OS2, MemToReg, Size, SE, L, SRB
        $display("ADDI r5,r0,0");
        check_instruction(9'd0,  32'h20050000, 4'b0000, 2'b00, 2'b01, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0);
        $display("SUB r3,r0,r3");
        check_instruction(9'd4,  32'h00031822, 4'b0001, 2'b01, 2'b00, 1'b1, 2'b00, 1'b0, 1'b0, 1'b1);
        $display("LBU r2,0(r1)");
        check_instruction(9'd8,  32'h90220000, 4'b0000, 2'b00, 2'b01, 1'b0, 2'b00, 1'b0, 1'b1, 1'b0);
        $display("LH r2,0(r1)");
        check_instruction(9'd12, 32'h84220000, 4'b0000, 2'b00, 2'b01, 1'b0, 2'b01, 1'b1, 1'b1, 1'b0);

        $display("ROM -> Control Unit: %0d passed, %0d failed.", passed, failed);
        if (failed != 0) $stop;
        $finish;
    end
endmodule
