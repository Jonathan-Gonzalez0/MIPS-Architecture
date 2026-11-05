`timescale 1ns/1ps

// Pending: ANDI/ORI/XORI need zero extension, which SOH does not provide.
// JALR uses explicit rd, following the notes and the user's chosen interpretation.
// Document difference: Fase II describes r31 as implicit for this instruction.
// Jump, RegDst, SRA and SRB are used in ID, outside the NOP MUX.
// The other 13 outputs form the 21 control bits sent through that MUX to ID/EX.
// RegDst: 00=rt, 01=rd, 10=r31, 11=r0; MemToReg: 0=memory, 1=ALU/PC+8.
// OS1: 0=rs, 1=sa; OS2: 00=rt, 01=sign-extended I, 10=I<<16.
// WriteCond: 00=always, 01=rt!=0, 10=rt==0, 11=BranchTaken.
// Size: 00=byte, 01=halfword, 10=word; OutSel: 0=ALU, 1=PC+8.
// SE: 0=unsigned, 1=signed; SRA/SRB mark source-register use.
module ControlUnit (
    input wire [31:0] I,

    output reg Jump,
    output reg [1:0] RegDst,
    output reg OS1,
    output reg [1:0] OS2,
    output reg [3:0] OP,
    output reg [2:0] BranchType,
    output reg [1:0] WriteCond,
    output reg RF_LE,
    output reg MemToReg,
    output reg RW,
    output reg E,
    output reg [1:0] Size,
    output reg SE,
    output reg L,
    output reg OutSel,
    output reg SRA,
    output reg SRB
);

    reg instruction_supported;

    always @(*) begin
        // Assigning every output here prevents latches and also defines NOP.
        Jump = 1'b0;
        RegDst = 2'b00;
        OS1 = 1'b0;
        OS2 = 2'b00;
        OP = 4'b0000;
        BranchType = 3'b000;
        WriteCond = 2'b00;
        RF_LE = 1'b0;
        MemToReg = 1'b0;
        RW = 1'b0;
        E = 1'b0;
        Size = 2'b00;
        SE = 1'b0;
        L = 1'b0;
        OutSel = 1'b0;
        SRA = 1'b0;
        SRB = 1'b0;
        instruction_supported = 1'b1;

        if (I == 32'b0) begin
            // NOP: keep all control signals at their default values.
        end
        else begin
            case (I[31:26])
                6'b000000: begin
                    case (I[5:0])
                        // ADD rd, rs, rt
                        6'b100000: begin
                                OP = 4'b0000; 
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRA = 1'b1;
                                SRB = 1'b1;
                        end

                        // AND rd, rs, rt
                        6'b100100: begin
                                OP = 4'b0010;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRA = 1'b1;
                                SRB = 1'b1;
                        end

                        // OR rd, rs, rt
                        6'b100101: begin
                                OP = 4'b0011;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRA = 1'b1;
                                SRB = 1'b1;
                        end

                        // XOR rd, rs, rt
                        6'b100110: begin
                                OP = 4'b0100;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRA = 1'b1;
                                SRB = 1'b1;
                        end

                        // NOR rd, rs, rt
                        6'b100111: begin
                                OP = 4'b0101;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRA = 1'b1;
                                SRB = 1'b1;
                        end

                        // SLT rd, rs, rt (signed comparison)
                        6'b101010: begin
                                OP = 4'b0110;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRA = 1'b1;
                                SRB = 1'b1;
                            end
                        // MOVN rd, rs, rt
                        6'b001011: begin
                                OP = 4'b0111;
                                WriteCond = 2'b01; // Write when rt's value is nonzero
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRA = 1'b1;
                                SRB = 1'b1;
                        end

                        // SLL rd, rt, sa
                        6'b000000: begin
                                OS1 = 1'b1;
                                OP = 4'b1001;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRB = 1'b1;
                        end

                        // SRL rd, rt, sa
                        6'b000010: begin
                                OS1 = 1'b1;
                                OP = 4'b1010;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRB = 1'b1;
                        end

                        // SRLV rd, rt, rs
                        6'b000110: begin
                                OP = 4'b1010;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRA = 1'b1;
                                SRB = 1'b1;
                        end

                        // SRAV rd, rt, rs
                        6'b000111: begin
                                OP = 4'b1011;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                SRA = 1'b1;
                                SRB = 1'b1;
                        end

                        // JALR rd, rs: notes pages 41-42 specify the link destination.
                        6'b001001: begin
                                Jump = 1'b1;
                                OP = 4'b1111;
                                RegDst = 2'b01;
                                RF_LE = 1'b1;
                                MemToReg = 1'b1;
                                OutSel = 1'b1;
                                SRA = 1'b1;
                        end

                        // SUB rd, rs, rt
                        6'b100010: begin
                            OP = 4'b0001;
                            RegDst = 2'b01;
                            RF_LE = 1'b1;
                            MemToReg = 1'b1;
                            SRA = 1'b1;
                            SRB = 1'b1;
                        end

                        // SRA rd, rt, sa (instruction, not the hazard flag SRA)
                        6'b000011: begin
                            OP = 4'b1011;
                            OS1 = 1'b1;
                            RegDst = 2'b01;
                            RF_LE = 1'b1;
                            MemToReg = 1'b1;
                            SRB = 1'b1;        // Only rt is a source register.
                        end

                        // SLLV rd, rt, rs
                        6'b000100: begin
                            // Its unused sa=4 should be zero; it is ignored here.
                            OP = 4'b1001;       // B << A[4:0]
                            RegDst = 2'b01;
                            RF_LE = 1'b1;
                            MemToReg = 1'b1;
                            SRA = 1'b1;
                            SRB = 1'b1;
                        end

                        // MOVZ rd, rs, rt
                        6'b001010: begin
                            OP = 4'b0111;       // Pass A (rs), not A - B.
                            RegDst = 2'b01;
                            WriteCond = 2'b10; // Write only when rt's VALUE is 0.
                            RF_LE = 1'b1;      // Write Condition gates this in EX.
                            MemToReg = 1'b1;
                            SRA = 1'b1;
                            SRB = 1'b1;
                        end

                        // JR rs
                        6'b001000: begin
                            Jump = 1'b1;       // Target comes from TAG in ID.
                            OP = 4'b1111;
                            SRA = 1'b1;
                        end

                        default: instruction_supported = 1'b0;
                    endcase
                end

                // ADDI rt, rs, imm16
                6'b001000: begin
                    OP = 4'b0000;
                    OS2 = 2'b01;
                    RegDst = 2'b00;
                    RF_LE = 1'b1;
                    MemToReg = 1'b1;
                    SRA = 1'b1;
                end

                // SLTI rt, rs, imm16: both operands are signed.
                6'b001010: begin
                    OP = 4'b0110;
                    OS2 = 2'b01;
                    RF_LE = 1'b1;
                    MemToReg = 1'b1;
                    SRA = 1'b1;
                end

                // ANDI / ORI / XORI require {16'b0, imm16}.
                // SOH has no such selector. Keep all controls at zero.
                6'b001100: begin
                    OS2 = 2'b01;
                    OP = 4'b0010;
                    RF_LE = 1'b1;
                    MemToReg = 1'b1;
                    SRA = 1'b1;
                end

                //ORI
                6'b001101: begin
                    OS2 = 2'b01;
                    OP = 4'b0011;
                    RF_LE = 1'b1;
                    MemToReg = 1'b1;
                    SRA = 1'b1;
                end

                //XORI
                6'b001110: begin
                    OS2 = 2'b01;
                    OP = 4'b0100;
                    RF_LE = 1'b1;
                    MemToReg = 1'b1;
                    SRA = 1'b1;
                end
                // LUI rt, imm16
                6'b001111: begin
                    OP = 4'b1000;
                    OS2 = 2'b10;
                    RegDst = 2'b00;
                    RF_LE = 1'b1;
                    MemToReg = 1'b1;
                end

                // Loads and stores: ALU calculates rs + signed displacement.
                // LB rt, imm16(rs)
                6'b100000: begin
                    OP = 4'b0000;
                    OS2 = 2'b01;
                    RF_LE = 1'b1;
                    Size = 2'b00;
                    SE = 1'b1;
                    L = 1'b1;
                    SRA = 1'b1;
                end

                // LHU rt, imm16(rs)
                6'b100101: begin
                    OP = 4'b0000;
                    OS2 = 2'b01;
                    RF_LE = 1'b1;
                    Size = 2'b01;
                    SE = 1'b0;
                    L = 1'b1;
                    SRA = 1'b1;
                end

                // LW rt, imm16(rs)
                6'b100011: begin
                    OP = 4'b0000;
                    OS2 = 2'b01;
                    RF_LE = 1'b1;
                    Size = 2'b10;
                    SE = 1'b0;
                    L = 1'b1;
                    SRA = 1'b1;
                end

                // SB rt, imm16(rs)
                6'b101000: begin
                    OP = 4'b0000;
                    OS2 = 2'b01;
                    RW = 1'b1;
                    E = 1'b1;
                    Size = 2'b00;
                    SRA = 1'b1;
                    SRB = 1'b1;
                end

                // SH rt, imm16(rs)
                6'b101001: begin
                    OP = 4'b0000;
                    OS2 = 2'b01;
                    RW = 1'b1;
                    E = 1'b1;
                    Size = 2'b01;
                    SRA = 1'b1;
                    SRB = 1'b1;
                end

                // LBU rt, imm16(rs)
                6'b100100: begin
                    OP = 4'b0000;
                    OS2 = 2'b01;
                    RegDst = 2'b00;
                    RF_LE = 1'b1;
                    MemToReg = 1'b0;
                    Size = 2'b00;
                    SE = 1'b0;
                    L = 1'b1;
                    SRA = 1'b1;
                end

                // LH rt, imm16(rs)
                6'b100001: begin
                    OP = 4'b0000;
                    OS2 = 2'b01;
                    RegDst = 2'b00;
                    RF_LE = 1'b1;
                    MemToReg = 1'b0;
                    Size = 2'b01;
                    SE = 1'b1;
                    L = 1'b1;
                    SRA = 1'b1;
                end

                // SW rt, imm16(rs)
                6'b101011: begin
                    OP = 4'b0000;
                    OS2 = 2'b01;
                    RW = 1'b1;
                    E = 1'b1;
                    Size = 2'b10;
                    SRA = 1'b1;
                    SRB = 1'b1;
                end

                // REGIMM: I[20:16] is a secondary opcode, not source rt.
                6'b000001: begin
                    case (I[20:16])
                        // BLTZ rs, offset
                        5'b00000: begin
                            OP = 4'b0111;
                            BranchType = 3'b101;
                            SRA = 1'b1;
                        end

                        // BGEZ rs, offset
                        5'b00001: begin
                            OP = 4'b0111;
                            BranchType = 3'b010;
                            SRA = 1'b1;
                        end

                        // BLTZAL rs, offset
                        5'b10000: begin
                            OP = 4'b0111;
                            BranchType = 3'b101;
                            SRA = 1'b1;
                            RegDst = 2'b10;
                            RF_LE = 1'b1;
                            MemToReg = 1'b1;
                            WriteCond = 2'b11; // Link only when BranchTaken
                            OutSel = 1'b1;
                        end

                        // BGEZAL rs, offset; BAL offset when rs = r0.
                        5'b10001: begin
                            OP = 4'b0111;
                            RegDst = 2'b10;
                            RF_LE = 1'b1;
                            MemToReg = 1'b1;
                            OutSel = 1'b1;

                            if (I[25:21] == 5'b00000) begin
                                // BAL: always jump in ID and always save link.
                                Jump = 1'b1;
                                WriteCond = 2'b00;
                            end
                            else begin
                                // BGEZAL: EX resolves branch and link condition.
                                BranchType = 3'b010; // NOT LE (rs >= 0)
                                WriteCond = 2'b11;
                                SRA = 1'b1;
                            end
                        end

                        default: instruction_supported = 1'b0;
                    endcase
                end

                // BEQ rs, rt, offset; B offset when rs = rt = r0.
                6'b000100: begin
                    if ((I[25:21] == 5'b00000) &&
                        (I[20:16] == 5'b00000)) begin
                        // B: unconditional, resolved in ID like other jumps.
                        Jump = 1'b1;
                    end
                    else begin
                        OP = 4'b0001;
                        BranchType = 3'b001;
                        SRA = 1'b1;
                        SRB = 1'b1;
                    end
                end

                // BGTZ rs, offset: the rt field must be zero.
                6'b000111: begin
                    if (I[20:16] == 5'b00000) begin
                        OP = 4'b0111;       // Test rs, not rs - displacement.
                        BranchType = 3'b011;
                        SRA = 1'b1;
                    end
                    else begin
                        instruction_supported = 1'b0;
                    end
                end

                // BLEZ rs, offset: rt is an unused zero field.
                6'b000110: begin
                    if (I[20:16] == 5'b00000) begin
                        OP = 4'b0111;
                        BranchType = 3'b100;
                        SRA = 1'b1;
                    end
                    else instruction_supported = 1'b0;
                end

                // BNE rs, rt, offset: compare register values, not the offset.
                6'b000101: begin
                    OP = 4'b0001;
                    BranchType = 3'b110;
                    SRA = 1'b1;
                    SRB = 1'b1;
                end

                // J target: TAG supplies the address in ID.
                6'b000010: begin
                    Jump = 1'b1;
                end

                // JAL target
                6'b000011: begin
                    Jump = 1'b1;
                    RegDst = 2'b10;
                    RF_LE = 1'b1;
                    MemToReg = 1'b1;
                    OutSel = 1'b1;
                end

                default: instruction_supported = 1'b0;
            endcase
        end

        // synthesis translate_off
        if (!instruction_supported) begin
            if ((I[31:26] == 6'b001100) || (I[31:26] == 6'b001101) ||
                (I[31:26] == 6'b001110)) begin
                $display("ALERT: ANDI/ORI/XORI unsupported: SOH cannot zero-extend imm16. I=%h", I);
            end
            else begin
                $display("ALERT: instruction outside implemented subset: I=%h opcode=%b function=%b",
                         I, I[31:26], I[5:0]);
            end
        end
        if ((I[31:26] == 6'b000000) && (I[5:0] == 6'b000100) &&
            (I[10:6] != 5'b00000)) begin
            $display("ALERT: SLLV has nonzero unused sa=%0d in I=%h; ignored for the Phase III demo. Review the PDF encoding.",
                     I[10:6], I);
        end
        // synthesis translate_on
    end
endmodule
