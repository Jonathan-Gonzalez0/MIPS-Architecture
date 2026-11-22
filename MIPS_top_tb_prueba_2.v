`timescale 1ns/1ps

// Phase III: real PASG + instruction ROM + control-unit pipeline.
// Run from the MIPS-Architecture repository root.
module MIPS_top_tb_prueba_2;
    reg Clk;
    reg Reset;
    reg S;
    reg Show_Controls = 1'b0;
    
    MIPS_top mips_top (
      .Clk(Clk),
      .Reset(Reset)
      );
      
    reg[8*6-1:0] Instruction_Name;
    wire[31:0] PC_IF = mips_top.program_counter; //PC viene del input del PLR
    
    reg[8*6-1:0] Instruction_Name_ID;
    wire[31:0] PC_ID = mips_top.PASG.Q0; 
    wire[31:0] INS_ID = mips_top.PASG.I;

    wire signed [31:0] r1  = mips_top.RF.MUX_A.Q1;
    wire signed [31:0] r2  = mips_top.RF.MUX_A.Q2;
    wire signed [31:0] r3  = mips_top.RF.MUX_A.Q3;
    wire signed [31:0] r4 = mips_top.RF.MUX_A.Q4;
    wire signed [31:0] r5  = mips_top.RF.MUX_A.Q5;
    wire signed [31:0] r7  = mips_top.RF.MUX_A.Q7;
    wire signed [31:0] r8  = mips_top.RF.MUX_A.Q8;
    wire signed [31:0] r10 = mips_top.RF.MUX_A.Q10;
    wire signed [31:0] r12  = mips_top.RF.MUX_A.Q12;
    wire signed [31:0] r31  = mips_top.RF.MUX_A.Q31;

    reg[8*6-1:0] Instruction_Name_EX;

    reg[8*6-1:0] Instruction_Name_MEM;

    reg[8*6-1:0] Instruction_Name_WB;

  initial begin
    $readmemb(
      "Instruction Memory/prueba_2.txt",
      mips_top.IM.Mem,
      0, 203
    );

    $readmemb(
      "Data_Memory/prueba_2.txt",
      mips_top.DM.Mem,
      0, 203
    );
    fork
      $timeformat(-9, 0, "ns", 0);
      #0 Clk = 1'b0;
      #0 Reset = 1'b1;
      #0 S = 1'b0;

      #3 Reset = 1'b0;
      
    #224 $display("t = %0t, %b %b %b %b",$time, 
    mips_top.DM.Mem[204],mips_top.DM.Mem[205],mips_top.DM.Mem[206],mips_top.DM.Mem[207]);
    #224.1 $display("           %b %b %b %b",
    mips_top.DM.Mem[208],mips_top.DM.Mem[209],mips_top.DM.Mem[210],mips_top.DM.Mem[211]);
    #224.2 $display("           %b %b %b %b", 
    mips_top.DM.Mem[212],mips_top.DM.Mem[213],mips_top.DM.Mem[214],mips_top.DM.Mem[215]);
    #224.3 $display("           %b %b %b %b",
    mips_top.DM.Mem[216],mips_top.DM.Mem[217],mips_top.DM.Mem[218],mips_top.DM.Mem[219]);
    #224.4 $display("           %b %b %b %b", 
    mips_top.DM.Mem[220],mips_top.DM.Mem[221],mips_top.DM.Mem[222],mips_top.DM.Mem[223]);
    #224.5 $display("           %b %b %b %b", 
    mips_top.DM.Mem[224],mips_top.DM.Mem[225],mips_top.DM.Mem[226],mips_top.DM.Mem[227]);
    #224.6 $display("           %b %b %b %b", 
    mips_top.DM.Mem[228],mips_top.DM.Mem[229],mips_top.DM.Mem[230],mips_top.DM.Mem[231]);
    #224.7 $display("           %b %b %b %b",
    mips_top.DM.Mem[232],mips_top.DM.Mem[233],mips_top.DM.Mem[234],mips_top.DM.Mem[235]);
    #224.8 $display("           %b %b %b %b", 
    mips_top.DM.Mem[236],mips_top.DM.Mem[237],mips_top.DM.Mem[238],mips_top.DM.Mem[239]);
    #224.9 $display("           %b %b %b %b", 
    mips_top.DM.Mem[240],mips_top.DM.Mem[241],mips_top.DM.Mem[242],mips_top.DM.Mem[243]);
    #224.95 $display("           %b %b %b %b",
    mips_top.DM.Mem[244],mips_top.DM.Mem[245],mips_top.DM.Mem[246],mips_top.DM.Mem[247]);

    #232
      $finish;
    join 
  end
  
  always #2 Clk = ~Clk;

  always @(*) begin
    if(mips_top.Instruction_Memory == 32'd0)
      Instruction_Name = "NOP";
    else
    case (mips_top.Instruction_Memory[31:26])
      6'b000000:
      begin
        case (mips_top.Instruction_Memory[5:0])
            6'b000000: Instruction_Name = "SLL";
            6'b000011: Instruction_Name = "SRA";
            6'b000010: Instruction_Name = "SRL";
            6'b000100: Instruction_Name = "SLLV";
            6'b000111: Instruction_Name = "SRAV";
            6'b000110: Instruction_Name = "SRLV";
            6'b100000: Instruction_Name = "ADD";
            6'b100010: Instruction_Name = "SUB";
            6'b100100: Instruction_Name = "AND";
            6'b100101: Instruction_Name = "OR";
            6'b100110: Instruction_Name = "XOR";
            6'b100111: Instruction_Name = "NOR";
            6'b101010: Instruction_Name = "SLT";
            6'b001011: Instruction_Name = "MOVN";
            6'b001010: Instruction_Name = "MOVZ";
            6'b001001: Instruction_Name = "JALR";
            6'b001000: Instruction_Name = "JR";
          endcase
        end
      6'b001000: Instruction_Name = "ADDI";
      6'b001100: Instruction_Name = "ANDI";
      6'b001101: Instruction_Name = "ORI";
      6'b001110: Instruction_Name = "XORI";
      6'b001010: Instruction_Name = "SLTI";
      6'b001111: Instruction_Name = "LUI";
      6'b100011: Instruction_Name = "LW";
      6'b100001: Instruction_Name = "LH";
      6'b100101: Instruction_Name = "LHU";
      6'b100000: Instruction_Name = "LB";
      6'b100100: Instruction_Name = "LBU";
      6'b101011: Instruction_Name = "SW";
      6'b101001: Instruction_Name = "SH";
      6'b101000: Instruction_Name = "SB";
      6'b000100: begin
        if (mips_top.Instruction_Memory[20:16] == 0 && mips_top.Instruction_Memory[25:21] == 0)
          Instruction_Name = "B";
        else
          Instruction_Name = "BEQ";
      end
      6'b000001: begin
        case(mips_top.Instruction_Memory[20:16])
          5'b10001:begin
            if(mips_top.Instruction_Memory[25:21] == 0)
              Instruction_Name = "BAL";
            else
              Instruction_Name = "BGEZAL";
          end 
          5'b00001: Instruction_Name = "BGEZ";
          5'b00000: Instruction_Name = "BLTZ";
          5'b10000: Instruction_Name = "BLTZAL";
        endcase
      end
      6'b000111: if(mips_top.Instruction_Memory[20:16] == 5'b00000) Instruction_Name = "BGTZ";
      6'b000110: if(mips_top.Instruction_Memory[20:16] == 5'b00000) Instruction_Name = "BLEZ";
      6'b000101: Instruction_Name = "BNE";
      6'b000010: Instruction_Name = "J";
      6'b000011: Instruction_Name = "JAL";
      default: Instruction_Name = "NOP";
      endcase
  end

    always @(*) begin
    if(INS_ID == 32'd0)
      Instruction_Name_ID = "NOP";
    else
    case (INS_ID[31:26])
      6'b000000:
      begin
        case (INS_ID[5:0])
            6'b000000: Instruction_Name_ID = "SLL";
            6'b000011: Instruction_Name_ID = "SRA";
            6'b000010: Instruction_Name_ID = "SRL";
            6'b000100: Instruction_Name_ID = "SLLV";
            6'b000111: Instruction_Name_ID = "SRAV";
            6'b000110: Instruction_Name_ID = "SRLV";
            6'b100000: Instruction_Name_ID = "ADD";
            6'b100010: Instruction_Name_ID = "SUB";
            6'b100100: Instruction_Name_ID = "AND";
            6'b100101: Instruction_Name_ID = "OR";
            6'b100110: Instruction_Name_ID = "XOR";
            6'b100111: Instruction_Name_ID = "NOR";
            6'b101010: Instruction_Name_ID = "SLT";
            6'b001011: Instruction_Name_ID = "MOVN";
            6'b001010: Instruction_Name_ID = "MOVZ";
            6'b001001: Instruction_Name_ID = "JALR";
            6'b001000: Instruction_Name_ID = "JR";
          endcase
        end
      6'b001000: Instruction_Name_ID = "ADDI";
      6'b001100: Instruction_Name_ID = "ANDI";
      6'b001101: Instruction_Name_ID = "ORI";
      6'b001110: Instruction_Name_ID = "XORI";
      6'b001010: Instruction_Name_ID = "SLTI";
      6'b001111: Instruction_Name_ID = "LUI";
      6'b100011: Instruction_Name_ID = "LW";
      6'b100001: Instruction_Name_ID = "LH";
      6'b100101: Instruction_Name_ID = "LHU";
      6'b100000: Instruction_Name_ID = "LB";
      6'b100100: Instruction_Name_ID = "LBU";
      6'b101011: Instruction_Name_ID = "SW";
      6'b101001: Instruction_Name_ID = "SH";
      6'b101000: Instruction_Name_ID = "SB";
      6'b000100: begin
        if (INS_ID[20:16] == 0 && INS_ID[25:21] == 0)
          Instruction_Name_ID = "B";
        else
          Instruction_Name_ID = "BEQ";
      end
      6'b000001: begin
        case(INS_ID[20:16])
          5'b10001:begin
            if(INS_ID[25:21] == 0)
              Instruction_Name_ID = "BAL";
            else
              Instruction_Name_ID = "BGEZAL";
          end 
          5'b00001: Instruction_Name_ID = "BGEZ";
          5'b00000: Instruction_Name_ID = "BLTZ";
          5'b10000: Instruction_Name_ID = "BLTZAL";
        endcase
      end
      6'b000111: if(INS_ID[20:16] == 5'b00000) Instruction_Name_ID = "BGTZ";
      6'b000110: if(INS_ID[20:16] == 5'b00000) Instruction_Name_ID = "BLEZ";
      6'b000101: Instruction_Name_ID = "BNE";
      6'b000010: Instruction_Name_ID = "J";
      6'b000011: Instruction_Name_ID = "JAL";
      default: Instruction_Name_ID = "NOP";
      endcase
  end

  initial begin
    #2
    $monitor("t=%0t PC=%0d r1=%0d r2=%0d r3=%0d r4=%0d r5=%0d r7=%0d r8=%0d r10=%0d R12=%0d r31=%0d",
             $time, PC_IF, r1, r2, r3, r4, r5, r7, r8, r10, r12, r31);
  end

  always @(posedge Clk) begin
    if(Reset)
      begin
        Instruction_Name_EX = "NOP";
        Instruction_Name_MEM = "NOP";
        Instruction_Name_WB = "NOP";
      end
    else if(S)begin
      Instruction_Name_EX <= "Bubble";
      Instruction_Name_MEM <= Instruction_Name_EX;
      Instruction_Name_WB <= Instruction_Name_MEM;
    end    else
      begin
        Instruction_Name_EX <= Instruction_Name_ID;
        Instruction_Name_MEM <= Instruction_Name_EX;
        Instruction_Name_WB <= Instruction_Name_MEM;
      end
      if(Show_Controls) begin
        $strobe("Etapa IF: Ins = %0s, PC = %0d, t = %0t",Instruction_Name, PC_IF, $time);
        $strobe("Etapa ID: Ins = %0s, Jump = %b, RegDest = %b, OS1 = %b, OS2 = %b, OP = %b, BranchType = %b, WriteCond = %b, RF_LE = %b, MemToReg = %b, RW = %b, E = %b, Size = %b, SE = %b, L = %b, OutSel = %b, SRA = %b, SRB = %b",Instruction_Name_ID, mips_top.Jump_ID, mips_top.RegDst_ID, mips_top.OS1_ID, mips_top.OS2_ID, mips_top.OP_ID, mips_top.BranchType_ID, mips_top.WriteCond_ID, mips_top.RF_LE_ID,mips_top.MemToReg_ID, mips_top.RW_ID, mips_top.E_ID, mips_top.Size_ID, mips_top.SE_ID, mips_top.L_ID, mips_top.OutSel_ID, mips_top.SRA_ID, mips_top.SRB_ID);
        $strobe("Etapa EX: Ins = %0s, OS1 = %b, OS2 = %b, OP = %b, BranchType = %b, WriteCond = %b, RF_LE = %b, MemToReg = %b, RW = %b, E = %b, Size = %b, SE = %b, L = %b, OutSel = %b", Instruction_Name_EX, mips_top.OS1_ex, mips_top.OS2_ex, mips_top.OP_ex, mips_top.BranchType_ex, mips_top.WriteCond_ex, mips_top.RF_LE_ex,mips_top.MemToReg_ex, mips_top.RW_ex, mips_top.E_ex, mips_top.Size_ex, mips_top.SE_ex, mips_top.L_ex, mips_top.OutSel_ex);
        $strobe("Etapa MEM: Ins = %0s, RF_LE = %b, MemToReg = %b, RW = %b, E = %b, Size = %b, SE = %b",Instruction_Name_MEM, mips_top.RF_LE_mem, mips_top.MemToReg_mem, mips_top.RW_mem, mips_top.E_mem, mips_top.Size_mem, mips_top.SE_mem);
        $strobe("Etapa WB: Ins = %0s, RF_LE = %b",Instruction_Name_WB, mips_top.RF_LE_wb);
        $strobe("");
      end
  end

endmodule
