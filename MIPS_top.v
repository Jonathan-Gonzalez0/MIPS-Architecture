module MIPS_top(
  input wire Clk,
  input wire Reset,
  input wire S
);
  wire[31:0] Instruction_Memory;
  wire[31:0] program_counter;
  wire[31:0] Instruction;
  wire[31:0] target_address;
  wire Jump_ID;
  wire [1:0] RegDst_ID;
  wire OS1_ID;
  wire[1:0] OS2_ID;
  wire[3:0] OP_ID;
  wire[2:0] BranchType_ID;
  wire[1:0] WriteCond_ID;
  wire RF_LE_ID;
  wire MemToReg_ID;
  wire RW_ID;
  wire E_ID;
  wire[1:0] Size_ID;
  wire SE_ID;
  wire L_ID;
  wire OutSel_ID;
  wire SRA_ID;
  wire SRB_ID;

  PASG_System PASG(
    .Reset(Reset),
    .LE(1'b1),
    .Clk(Clk),
    .J(1'b0),
    .Clr(1'b0),
    .TAI(32'b0),
    .RS(32'b0),
    .Ins(Instruction_Memory),
    .PC(program_counter),
    .I(Instruction),
    .TAO(target_address)
  );

  InstructionMemory IM(
    .A(program_counter[8:0]),
    .I(Instruction_Memory)
  );

  ControlUnit CU(
    //Input
    .I(Instruction),

    //Output
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

  wire S_mux;
  wire OS1_mux;
  wire[1:0] OS2_mux;
  wire[3:0] OP_mux;
  wire[2:0] BranchType_mux;
  wire[1:0] WriteCond_mux;
  wire RF_LE_mux;
  wire MemToReg_mux;
  wire RW_mux;
  wire E_mux;
  wire[1:0] Size_mux;
  wire SE_mux;
  wire L_mux;
  wire OutSel_mux;
  wire SRA_mux;
  wire SRB_mux;

  NOPMux NM(
  //Input Mux
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

    //Output Mux
    .OS1_out(OS1_mux),
    .OS2_out(OS2_mux),
    .OP_out(OP_mux),
    .BranchType_out(BranchType_mux),
    .WriteCond_out(WriteCond_mux),
    .RF_LE_out(RF_LE_mux),
    .MemToReg_out(MemToReg_mux),
    .RW_out(RW_mux),
    .E_out(E_mux),
    .Size_out(Size_mux),
    .SE_out(SE_mux),
    .L_out(L_mux),
    .OutSel_out(OutSel_mux)
  );

  wire OS1_ex;
  wire[1:0] OS2_ex;
  wire[3:0] OP_ex;
  wire[2:0] BranchType_ex;
  wire[1:0] WriteCond_ex;
  wire RF_LE_ex;
  wire MemToReg_ex;
  wire RW_ex;
  wire E_ex;
  wire[1:0] Size_ex;
  wire SE_ex;
  wire L_ex;
  wire OutSel_ex;
  wire SRA_ex;
  wire SRB_ex;

  IDEX id_ex(
    .Clk(Clk),
    .Reset(Reset),
    
    .PC8_in(32'b0),
    .TA_in(32'b0),
    .PA_in(32'b0),
    .PB_in(32'b0),
    .SA_in(5'b0),
    .I_in(16'b0),
    .RD_in(5'b0),

    .OS1_in(OS1_mux),
    .OS2_in(OS2_mux),
    .OP_in(OP_mux),
    .BranchType_in(BranchType_mux),
    .WriteCond_in(WriteCond_mux),
    .RF_LE_in(RF_LE_mux),
    .MemToReg_in(MemToReg_mux),
    .RW_in(RW_mux),
    .E_in(E_mux),
    .Size_in(Size_mux),
    .SE_in(SE_mux),
    .L_in(L_mux),
    .OutSel_in(OutSel_mux),

    .PC8_out(),
    .TA_out(),
    .PA_out(),
    .PB_out(),
    .SA_out(),
    .I_out(),
    .RD_out(),

    .OS1_out(OS1_ex),
    .OS2_out(OS2_ex),
    .OP_out(OP_ex),
    .BranchType_out(BranchType_ex),
    .WriteCond_out(WriteCond_ex),
    .RF_LE_out(RF_LE_ex),
    .MemToReg_out(MemToReg_ex),
    .RW_out(RW_ex),
    .E_out(E_ex),
    .Size_out(Size_ex),
    .SE_out(SE_ex),
    .L_out(L_ex),
    .OutSel_out(OutSel_ex)
  );

  wire RF_LE_mem;
  wire MemToReg_mem;
  wire RW_mem;
  wire E_mem;
  wire[1:0] Size_mem;
  wire SE_mem;

  EXMEM ex_mem(
    .Clk(Clk),
    .Reset(Reset),

    .ALU_in(32'b0),
    .SD_in(32'b0),
    .RD_in(5'b0),

    .RF_LE_in(RF_LE_ex),
    .RW_in(RW_ex),
    .E_in(E_ex),
    .Size_in(Size_ex),
    .SE_in(SE_ex),
    .MemToReg_in(MemToReg_ex),

    .ALU_out(),
    .SD_out(),
    .RD_out(),

    .RF_LE_out(RF_LE_mem),
    .RW_out(RW_mem),
    .E_out(E_mem),
    .Size_out(Size_mem),
    .SE_out(SE_mem),
    .MemToReg_out(MemToReg_mem)
  );

  wire RF_LE_wb;

  MEMWB mem_wb(
    .Clk(Clk),
    .Reset(Reset),
    .PW_in(32'b0),
    .RW_in(5'b0),

    .RF_LE_in(RF_LE_mem),

    .PW_out(),
    .RW_out(),
    .RF_LE_out(RF_LE_wb)
  );


endmodule