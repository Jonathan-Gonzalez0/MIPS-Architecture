module MIPS_top(
  input wire Clk,
  input wire Reset,
  );
  
  // Inside Signals
  wire[31:0] Instruction_Memory;
  wire[31:0] program_counter;
  wire[31:0] Instruction;
  wire[31:0] target_address;
  wire[31:0] TAI;

  //DHDU Signals
  wire FWD_A_S_ID;
  wire FWD_B_S_ID;
  wire LE_PASG;
  wire S;
  
  // Control Signals
  wire J;
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

  wire[31:0] PA_RF_FWD_ID; //RF to FWD 
  wire[31:0] PB_RF_FWD_ID;

  wire[31:0] FWD_A_Output;
  wire[31:0] FWD_B_Output;

  OR_Jump_Branch OR_J_B(
    //  Input OR for Branch and Jump
    .A (Branch_Control_ex),
    .B (Jump_ID),

    // Output OR for Branch and Jump
    .Out(J)
  );

  J_Branch_Mux J_B_M(
    // Input
    .S(Branch_Control_ex),
    .A(TA_ex),
    .B(target_address),

    // Output
    .O(TAI)
  );

  PASG_System PASG(
    //Input de las Señales
    .Reset(Reset),
    .LE(LE_PASG),
    .Clk(Clk),
    .J(J),
    .Clr(1'b0),
    .RS(FWD_A_Output),
    .Ins(Instruction_Memory),

    //Output de las señales
    .PC(program_counter),
    .I(Instruction),
    .TAO(target_address)
  );

  InstructionMemory IM(
    .A(program_counter[8:0]),
    .I(Instruction_Memory)
  );

  register_file RF(
    //Inputs
    .Clk(Clk),
    .LE(RF_LE_wb),
    .RW(RW_wb),
    .RA(Instruction[25:21]),
    .RB(Instruction[20:16]),
    .PW(PW_wb),

    //Outputs
    .PA(PA_RF_FWD_ID),
    .PB(PB_RF_FWD_ID)
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

  DHDU dhdu(

    // Input Signals
    .ID_RA(Instruction[25:21]),
    .ID_RB(Instruction[20:16]),
    .SRA(SRA_ID),
    .SRB(SRB_ID),
    .EX_RD(RD_EX),
    .MEM_RD(RD_mem),
    .WB_RD(RD_wb),
    .EX_RF_LE(RF_LE_ex),
    .MEM_RF_LE(RF_LE_mem),
    .WB_RF_LE(RF_LE_wb),
    .EX_L(L_ex),

    // Output Signals
    .A(FWD_A_S_ID),
    .B(FWD_B_S_ID),
    .LE(LE_PASG),
    .NOP(S)
  );

  Write_Register WR(
    .rt(Instruction[20:16]),
    .rd(Instruction[15:11]),
    .r31(5'd31),
    .r0(5'd0)
  );

  FWD_A fwd_A(
    // Input Signals
    .RF(PA_RF_FWD_ID),
    .R_EX(Output_MUX_ex),
    .R_MEM(PW_in),
    .R_WB(PW_Out),
    .S(FWD_A_S_ID),

    // Output Signals
    .Out(FWD_A_Output)
  );

  FWD_B fwd_B(
    // Input Signals
    .RF(PB_RF_FWD_ID),
    .R_EX(Output_MUX_ex),
    .R_MEM(PW_in),
    .R_WB(PW_Out),
    .S(FWD_B_S_ID),

    // Output Signals
    .Out(FWD_B_Output)
  );

  Adder_8 add8(
    .PC(PASG.Q0)
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
  
  // Output Signals
  wire[4:0] RD_EX;
  wire[31:0] PA_ex;
  wire[4:0] SA_ex;
  wire[31:0] PB_ex;
  wire LE_ex;
  wire EQ_ex;
  wire GT_ex;
  wire[31:0] ALU_out_ex;
  wire[31:0] Output_MUX_ex;
  wire NZ_ex;
  wire Not_NZ_ex;
  wire BranchTaken_ex;
  wire Enable_A_ex;
  wire RF_LE_AND_ex;

  //Control Signals
  wire Branch_Control_ex;
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

  wire[31:0] TA_ex;

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

    // Output Signals
    .PC8_out(),
    .TA_out(TA_ex),
    .PA_out(PA_ex),
    .PB_out(PB_ex),
    .SA_out(SA_ex),
    .I_out(),
    .RD_out(RD_EX),

    // Control Signals
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

  // Output Signals
  wire[4:0] RD_mem;

  // Control Signals
  wire RF_LE_mem;
  wire MemToReg_mem;
  wire RW_mem;
  wire E_mem;
  wire[1:0] Size_mem;
  wire SE_mem;

  alu_system ALU(
    // Input Signals
    .RA(PA_ex),
    .SA(SA_ex),
    .OS1(OS1_ex),
    .RB(PB_ex),
    .I(Instruction[15:0]),
    .OS2(OS2_ex),
    .OP(OP_ex),


    //  Output Signals
    .LE(LE_ex),
    .EQ(EQ_ex),
    .GT(GT_ex),
    .Out(ALU_out_ex)
  );

  B_not_equal_zero BnotZ(
    // Input signals
    .OB(alu_system.B),

    // Output signals
    .NZ(NZ_ex)
  );

  Not_NZ NNZ(

    // Input Signal
    .NZ(NZ_ex),

    // Output Signal
    .not_NZ(Not_NZ)
  );

  Branch_Control_Unit BCU(
    // Input
    .LE(LE_ex),
    .EQ(EQ_ex),
    .GT(GT_ex),
    .BranchType(BranchType_ex),

    // Output 
    .BranchTaken(BranchTaken_ex)
  );

  Write_Condition_Mux WCM(
    // Input
    .one(1'b1),
    .not_zero(NZ_ex),
    .zero(Not_NZ_ex),
    .BranchTaken(BranchTaken_ex),

    // Output
    .Out(Enable_A_ex)
  );

  Enable_AND EAND(
    // Input
    .A(Enable_A_ex),
    .B(RF_LE_ex),

    // Output
    .Out(RF_LE_AND_ex)
  );

  EXMEM ex_mem(
    .Clk(Clk),
    .Reset(Reset),

    .ALU_in(Output_MUX_ex),
    .SD_in(32'b0),
    .RD_in(5'b0),

    .RF_LE_in(RF_LE_AND_ex),
    .RW_in(RW_ex),
    .E_in(E_ex),
    .Size_in(Size_ex),
    .SE_in(SE_ex),
    .MemToReg_in(MemToReg_ex),

    .ALU_out(),
    .SD_out(),
    .RD_out(RD_mem),

    .RF_LE_out(RF_LE_mem),
    .RW_out(RW_mem),
    .E_out(E_mem),
    .Size_out(Size_mem),
    .SE_out(SE_mem),
    .MemToReg_out(MemToReg_mem)
  );
  // Output signals
  wire[4:0] RD_wb;
  wire[31:0] PW_in;
  wire[31:0] PW_Out;

  //Control Signals
  wire RF_LE_wb;

  wire[4:0] RW_wb;
  wire[31:0] PW_wb;

  MEMWB mem_wb(
    .Clk(Clk),
    .Reset(Reset),
    .PW_in(PW_in),
    .RW_in(5'b0),

    .RF_LE_in(RF_LE_mem),

    .PW_out(PW_Out),
    .RW_out(RW_wb),
    .RF_LE_out(RF_LE_wb)
  );


endmodule