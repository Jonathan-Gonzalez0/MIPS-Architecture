`timescale 1ns/1ps

// Experimental copy of phase3_control_path.v: same connections and registers.
// Only CU and SOH module types change. RF, memory and fetch remain boundaries.
module PhaseIIIZeroExtendPath (
    input wire Clk,
    input wire Reset,
    input wire S,
    input wire [31:0] I_ID,
    input wire [31:0] PC_ID,
    input wire [31:0] TA_ID,
    input wire [31:0] PA_ID,
    input wire [31:0] PB_ID,
    input wire [31:0] DataMemory_DO,
    output wire Jump_ID,
    output wire BranchTaken_EX,
    output wire Redirect_IF,
    output wire [31:0] Target_IF,
    output wire [31:0] Memory_Address,
    output wire [31:0] Memory_DI,
    output wire Memory_RW,
    output wire Memory_E,
    output wire [1:0] Memory_Size,
    output wire Memory_SE,
    output wire [31:0] PW_WB,
    output wire [4:0] RW_WB,
    output wire RF_LE_WB
);

    wire [1:0] RegDst_ID;
    wire SRA_ID;
    wire SRB_ID;
    wire [4:0] RD_ID;
    wire [31:0] PC8_ID;
    wire OS1_ID;
    wire [1:0] OS2_ID;
    wire [3:0] OP_ID;
    wire [2:0] BranchType_ID;
    wire [1:0] WriteCond_ID;
    wire RF_LE_ID;
    wire MemToReg_ID;
    wire RW_ID;
    wire E_ID;
    wire [1:0] Size_ID;
    wire SE_ID;
    wire L_ID;
    wire OutSel_ID;
    wire OS1_N;
    wire [1:0] OS2_N;
    wire [3:0] OP_N;
    wire [2:0] BranchType_N;
    wire [1:0] WriteCond_N;
    wire RF_LE_N;
    wire MemToReg_N;
    wire RW_N;
    wire E_N;
    wire [1:0] Size_N;
    wire SE_N;
    wire L_N;
    wire OutSel_N;
    wire [31:0] PC8_EX;
    wire [31:0] TA_EX;
    wire [31:0] PA_EX;
    wire [31:0] PB_EX;
    wire [4:0] SA_EX;
    wire [15:0] I_EX;
    wire [4:0] RD_EX;
    wire OS1_EX;
    wire [1:0] OS2_EX;
    wire [3:0] OP_EX;
    wire [2:0] BranchType_EX;
    wire [1:0] WriteCond_EX;
    wire RF_LE_EX;
    wire MemToReg_EX;
    wire RW_EX;
    wire E_EX;
    wire [1:0] Size_EX;
    wire SE_EX;
    wire L_EX;
    wire OutSel_EX;
    wire [31:0] ALU_MEM;
    wire [31:0] SD_MEM;
    wire [4:0] RD_MEM;
    wire RF_LE_MEM;
    wire RW_MEM;
    wire E_MEM;
    wire [1:0] Size_MEM;
    wire SE_MEM;
    wire MemToReg_MEM;
    wire [31:0] OA_EX;
    wire [31:0] OB_EX;
    wire [31:0] ALU_Result_EX;
    wire LE_EX;
    wire EQ_EX;
    wire GT_EX;
    wire WriteAllowed_EX;
    wire RF_LE_effective_EX;
    wire [31:0] Result_EX;
    wire [31:0] PW_MEM;

    assign PC8_ID = PC_ID + 32'd8;

    ControlUnitZeroExtendExperimental control (
        .I(I_ID),
        .Jump(Jump_ID),
        .RegDst(RegDst_ID),
        .OS1(OS1_ID),
        .OS2(OS2_ID),
        .OP(OP_ID),
        .BranchType(BranchType_ID),
        .WriteCond(WriteCond_ID),
        .RF_LE(RF_LE_ID),
        .MemToReg(MemToReg_ID),
        .RW(RW_ID),
        .E(E_ID),
        .Size(Size_ID),
        .SE(SE_ID),
        .L(L_ID),
        .OutSel(OutSel_ID),
        .SRA(SRA_ID),
        .SRB(SRB_ID)
    );

    PhaseIIIRegDstMux destination (
        .RT(I_ID[20:16]),
        .RD(I_ID[15:11]),
        .RegDst(RegDst_ID),
        .Out(RD_ID)
    );

    NOPMux bubble_mux (
        .S(S),
        .OS1_in(OS1_ID),
        .OS2_in(OS2_ID),
        .OP_in(OP_ID),
        .BranchType_in(BranchType_ID),
        .WriteCond_in(WriteCond_ID),
        .RF_LE_in(RF_LE_ID),
        .MemToReg_in(MemToReg_ID),
        .RW_in(RW_ID),
        .E_in(E_ID),
        .Size_in(Size_ID),
        .SE_in(SE_ID),
        .L_in(L_ID),
        .OutSel_in(OutSel_ID),
        .OS1_out(OS1_N),
        .OS2_out(OS2_N),
        .OP_out(OP_N),
        .BranchType_out(BranchType_N),
        .WriteCond_out(WriteCond_N),
        .RF_LE_out(RF_LE_N),
        .MemToReg_out(MemToReg_N),
        .RW_out(RW_N),
        .E_out(E_N),
        .Size_out(Size_N),
        .SE_out(SE_N),
        .L_out(L_N),
        .OutSel_out(OutSel_N)
    );

    IDEX id_ex (
        .Clk(Clk),
        .Reset(Reset),
        .PC8_in(PC8_ID),
        .TA_in(TA_ID),
        .PA_in(PA_ID),
        .PB_in(PB_ID),
        .SA_in(I_ID[10:6]),
        .I_in(I_ID[15:0]),
        .RD_in(RD_ID),
        .OS1_in(OS1_N),
        .OS2_in(OS2_N),
        .OP_in(OP_N),
        .BranchType_in(BranchType_N),
        .WriteCond_in(WriteCond_N),
        .RF_LE_in(RF_LE_N),
        .MemToReg_in(MemToReg_N),
        .RW_in(RW_N),
        .E_in(E_N),
        .Size_in(Size_N),
        .SE_in(SE_N),
        .L_in(L_N),
        .OutSel_in(OutSel_N),
        .PC8_out(PC8_EX),
        .TA_out(TA_EX),
        .PA_out(PA_EX),
        .PB_out(PB_EX),
        .SA_out(SA_EX),
        .I_out(I_EX),
        .RD_out(RD_EX),
        .OS1_out(OS1_EX),
        .OS2_out(OS2_EX),
        .OP_out(OP_EX),
        .BranchType_out(BranchType_EX),
        .WriteCond_out(WriteCond_EX),
        .RF_LE_out(RF_LE_EX),
        .MemToReg_out(MemToReg_EX),
        .RW_out(RW_EX),
        .E_out(E_EX),
        .Size_out(Size_EX),
        .SE_out(SE_EX),
        .L_out(L_EX),
        .OutSel_out(OutSel_EX)
    );

    // Original FOH, SOH and ALU modules: OB also feeds the Write Condition NZ test.
    foh first_operand (
        .RA(PA_EX),
        .SA(SA_EX),
        .OS1(OS1_EX),
        .OA(OA_EX)
    );
    SOHZeroExtendExperimental second_operand (
        .RB(PB_EX),
        .I(I_EX),
        .OS2(OS2_EX),
        .OB(OB_EX)
    );
    alu calculator (
        .A(OA_EX),
        .B(OB_EX),
        .OP(OP_EX),
        .LE(LE_EX),
        .EQ(EQ_EX),
        .GT(GT_EX),
        .Out(ALU_Result_EX)
    );

    PhaseIIIBranchControl branch_control (
        .LE(LE_EX),
        .EQ(EQ_EX),
        .GT(GT_EX),
        .BranchType(BranchType_EX),
        .BranchTaken(BranchTaken_EX)
    );
    PhaseIIIWriteCondition write_condition (
        .B(OB_EX),
        .WriteCond(WriteCond_EX),
        .BranchTaken(BranchTaken_EX),
        .Allowed(WriteAllowed_EX)
    );
    assign RF_LE_effective_EX = RF_LE_EX && WriteAllowed_EX;

    PhaseIIIMux32 output_mux (
        .A(ALU_Result_EX),
        .B(PC8_EX),
        .S(OutSel_EX),
        .Out(Result_EX)
    );

    assign Redirect_IF = Jump_ID || BranchTaken_EX;
    PhaseIIIMux32 target_mux (
        .A(TA_ID),
        .B(TA_EX),
        .S(BranchTaken_EX),
        .Out(Target_IF)
    );

    EXMEM ex_mem (
        .Clk(Clk),
        .Reset(Reset),
        .ALU_in(Result_EX),
        .SD_in(PB_EX),
        .RD_in(RD_EX),
        .RF_LE_in(RF_LE_effective_EX),
        .RW_in(RW_EX),
        .E_in(E_EX),
        .Size_in(Size_EX),
        .SE_in(SE_EX),
        .MemToReg_in(MemToReg_EX),
        .ALU_out(ALU_MEM),
        .SD_out(SD_MEM),
        .RD_out(RD_MEM),
        .RF_LE_out(RF_LE_MEM),
        .RW_out(RW_MEM),
        .E_out(E_MEM),
        .Size_out(Size_MEM),
        .SE_out(SE_MEM),
        .MemToReg_out(MemToReg_MEM)
    );

    assign Memory_Address = ALU_MEM;
    assign Memory_DI = SD_MEM;
    assign Memory_RW = RW_MEM;
    assign Memory_E = E_MEM;
    assign Memory_Size = Size_MEM;
    assign Memory_SE = SE_MEM;

    PhaseIIIMux32 writeback_mux (
        .A(DataMemory_DO),
        .B(ALU_MEM),
        .S(MemToReg_MEM),
        .Out(PW_MEM)
    );

    MEMWB mem_wb (
        .Clk(Clk),
        .Reset(Reset),
        .PW_in(PW_MEM),
        .RW_in(RD_MEM),
        .RF_LE_in(RF_LE_MEM),
        .PW_out(PW_WB),
        .RW_out(RW_WB),
        .RF_LE_out(RF_LE_WB)
    );
endmodule
