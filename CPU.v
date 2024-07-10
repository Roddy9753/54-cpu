`timescale 1ns / 1ps

module cpu(
    input clk,               
    input ena,               
    input rst,                
    input [31:0] instr_in,      
    input [31:0] dm_data,     
    output dm_ena,           
    output dm_w,             
    output dm_r,            
    output [31:0] pc_out,      
    output [31:0] dm_addr,      
    output [31:0] dm_data_w,   
    output sb_flag,          
    output sh_flag,            
    output sw_flag,          
    output lb_flag,            
    output lh_flag,        
    output lbu_flag,          
    output lhu_flag,          
    output lw_flag        
    );

/* 54��ָ���Ӧ����� */
parameter ADD   = 6'd0;
parameter ADDU  = 6'd1;
parameter SUB   = 6'd2;
parameter SUBU  = 6'd3;
parameter AND   = 6'd4;
parameter OR    = 6'd5;
parameter XOR   = 6'd6;
parameter NOR   = 6'd7;
parameter SLT   = 6'd8;
parameter SLTU  = 6'd9;
parameter SLL   = 6'd10;
parameter SRL   = 6'd11;
parameter SRA   = 6'd12;
parameter SLLV  = 6'd13;
parameter SRLV  = 6'd14;
parameter SRAV  = 6'd15;
parameter JR    = 6'd16;
parameter ADDI  = 6'd17;
parameter ADDIU = 6'd18;
parameter ANDI  = 6'd19;
parameter ORI   = 6'd20;
parameter XORI  = 6'd21;
parameter LW    = 6'd22;
parameter SW    = 6'd23;
parameter BEQ   = 6'd24;
parameter BNE   = 6'd25;
parameter SLTI  = 6'd26;
parameter SLTIU = 6'd27;
parameter LUI   = 6'd28;
parameter J     = 6'd29;
parameter JAL   = 6'd30;

parameter CLZ     = 6'd31;
parameter JALR    = 6'd32;
parameter MTHI    = 6'd33;
parameter MTLO    = 6'd34;
parameter MFHI    = 6'd35;
parameter MFLO    = 6'd36;
parameter SB      = 6'd37;
parameter SH      = 6'd38;
parameter LB      = 6'd39;
parameter LH      = 6'd40;
parameter LBU     = 6'd41;
parameter LHU     = 6'd42;
parameter ERET    = 6'd43;
parameter BREAK   = 6'd44;
parameter SYSCALL = 6'd45;
parameter TEQ     = 6'd46;
parameter MFC0    = 6'd47;
parameter MTC0    = 6'd48;
parameter MULT     = 6'd49;
parameter MULTU   = 6'd50;
parameter DIV     = 6'd51;
parameter DIVU    = 6'd52;
parameter BGEZ    = 6'd53;

//�ڲ�����
// Decoder
wire [53:0] op_flags;            //����ָ��ı�־��Ϣ
wire [4:0] RsC;                 //Rs��Ӧ�ļĴ����ĵ�ַ
wire [4:0] RtC;                 //Rt��Ӧ�ļĴ����ĵ�ַ
wire [4:0] RdC;                 //Rd��Ӧ�ļĴ����ĵ�ַ
wire [4:0] shamt;               //λ��ƫ������SLL��SRL��SRA�ã�
wire [15:0] immediate;          //��������I��ָ���ã�
wire [25:0] address;            //��ת��ַ��J��ָ���ã�

// Control
wire reg_w;                     //RegFile�Ĵ������Ƿ��д��
wire [4:0] cause;               //�ж����
wire [10:0] mux;                //10����·ѡ������״̬
wire [2:0]  mux6_1;             //6·ѡ������ѡ���ź�
wire [2:0]  mux7_1;             //7·ѡ������ѡ���ź�
wire [4:0] ext_ena;             //EXT��չ�Ƿ�����5��״̬�ֱ��ӦEXT1��EXT5��EXT16��EXT16(S)��EXT18(S),����EXT[0]��ӦEXT1
wire cat_ena;                   //�Ƿ���Ҫƴ��

// ALU
wire [31:0] a, b;                       //ALU��A��B���������
wire [3:0]  aluc;                       //ALUC��λ����ָ��
wire [31:0] alu_data_out;               //ALU���������
wire zero, carry, negative, overflow;   //�ĸ���־λ

// RegFile
wire [31:0] Rd_data_in;     //Ҫ��Ĵ�����д���ֵ
wire [31:0] Rs_data_out;    //Rs��Ӧ�ļĴ��������ֵ
wire [31:0] Rt_data_out;    //Rt��Ӧ�ļĴ��������ֵ

//PC
wire [31:0] pc_addr_in;     //��������PC�Ĵ�����ָ���ַ��Ҳ������һ��Ҫִ�е�ָ��
wire [31:0] pc_addr_out;    //���δ�PC�Ĵ����д�����ָ���ַ��Ҳ���ǵ�ǰ��Ҫִ�е�ָ��

// HI_LO
wire HI_w;                  //ʹ���źţ��Ƿ�����HI��д����
wire LO_w;                  //ʹ���źţ��Ƿ�����LO��д����
wire [31:0] HI_out;         //��HI��������
wire [31:0] LO_out;         //��LO��������

// DIV
wire sign_flag;             //�Ƿ����з��ų˳���
wire [31:0] DIV_A;          //����ı�����
wire [31:0] DIV_B;          //����ĳ���
wire [31:0] DIV_R;          //����
wire [31:0] DIV_Q;          //��

/* MULģ���� */
wire [31:0] MUL_A;          //����ĳ���A
wire [31:0] MUL_B;          //����ĳ���B
wire [31:0] MUL_HI;         //��32λ���
wire [31:0] MUL_LO;         //��32λ���

// CP0ģ��
wire [31:0] cp0_out;        //CP0���������
wire [31:0] epc_out;        //CP0�ͳ���PC��ַ�����ڸ���PC

// CLZ
wire [31:0] CLZ_out;        //CLZ�����������

// ���Ӹ�ģ��
// ���š�������չ����·
wire [31:0] ext1_out;
wire [31:0] ext5_out;
wire [31:0] ext16_out;
wire signed [31:0] ext16_out_signed;
wire signed [31:0] ext18_out_signed;

assign ext1_out         = (op_flags[SLT]  || op_flags[SLTU]) ? negative : 
                          (op_flags[SLTI] || op_flags[SLTIU]) ? carry : 32'hz;
assign ext5_out         = (op_flags[SLL]  || op_flags[SRL]   || op_flags[SRA]) ? shamt : 32'hz;
assign ext16_out        = (op_flags[ANDI] || op_flags[ORI]   || op_flags[XORI] || op_flags[LUI]) ? { 16'h0 , immediate[15:0] } : 32'hz;
assign ext16_out_signed = (op_flags[ADDI] || op_flags[ADDIU] || op_flags[LW]   || op_flags[SW] || 
                           op_flags[SLTI] || op_flags[SLTIU] || op_flags[SB]   || op_flags[SH] ||
                           op_flags[LB]   || op_flags[LH]    || op_flags[LBU]  || op_flags[LHU]) ?  { {16{immediate[15]}} , immediate[15:0] } : 32'hz;
assign ext18_out_signed = (op_flags[BEQ]  || op_flags[BNE]   || op_flags[BGEZ]) ? {{14{immediate[15]}}, immediate[15:0], 2'b0} : 32'hz;

// ||ƴ������· 
wire [31:0] cat_out;
assign cat_out = cat_ena ? {pc_out[31:28], address[25:0], 2'h0} : 32'hz;

// NPC��·
wire [31:0] npc;
wire [31:0] add_out_61;    //�ӷ�������Ӧ6ѡ1ͨ·
wire [31:0] add_out_71;    //�ӷ�������Ӧ7ѡ1ͨ·
assign npc = pc_addr_out + 4;

// ��·ѡ������·
wire [31:0] mux1_out;
wire [31:0] mux2_out;
wire [31:0] mux3_out;
wire [31:0] mux4_out;
wire [31:0] mux5_out;
wire [31:0] mux6_out;
wire [31:0] mux7_out;
wire [31:0] mux8_out;
wire [31:0] mux9_out;
wire [31:0] mux10_out;
wire [31:0] mux6_1_out;
wire [31:0] mux7_1_out;
assign mux1_out  = mux[1]  ? Rt_data_out : Rs_data_out;
assign mux2_out  = mux[2]  ? ext16_out_signed : ext16_out;
assign mux3_out  = mux[3]  ? ext5_out : Rs_data_out;
assign mux4_out  = mux[4]  ? mux2_out : Rt_data_out;
assign mux5_out  = mux[5]  ? mux9_out : Rs_data_out;
assign mux6_out  = mux[6]  ? mux10_out: Rs_data_out;
assign mux7_out  = mux[7]  ? LO_out   : HI_out;
assign mux8_out  = mux[8]  ? alu_data_out : ext1_out;
assign mux9_out  = mux[9]  ? DIV_R : MUL_HI;
assign mux10_out = mux[10] ? DIV_Q : MUL_LO;

// PC��·
assign pc_addr_in = mux6_1_out;
assign add_out_61 = ext18_out_signed + npc;
assign add_out_71 = pc_addr_out + 4;

// ALU ���߿�
assign a = mux3_out;
assign b = op_flags[BGEZ] ? 32'd0 : mux4_out;

// IMEM�ӿ� 
assign pc_out = pc_addr_out;

// DMEM�ӿ� 
assign dm_ena    = (dm_r || dm_w) ? 1'b1 : 1'b0;
assign dm_addr   = alu_data_out;
assign dm_data_w = Rt_data_out;
assign sb_flag   = op_flags[SB];
assign sh_flag   = op_flags[SH];
assign sw_flag   = op_flags[SW];
assign lb_flag   = op_flags[LB];
assign lh_flag   = op_flags[LH];
assign lbu_flag  = op_flags[LBU];
assign lhu_flag  = op_flags[LHU];
assign lw_flag   = op_flags[LW];

// �Ĵ�������· 
assign Rd_data_in = mux7_1_out;

// DIV MUL ��� 
assign sign_flag = op_flags[MULT] || op_flags[DIV] ? 1'b1 : 1'b0;
assign MUL_A = op_flags[MULT] || op_flags[MULTU] ? Rs_data_out : 32'hz;
assign MUL_B = op_flags[MULT] || op_flags[MULTU] ? Rt_data_out : 32'hz;
assign DIV_A = op_flags[DIV] || op_flags[DIVU]  ? Rs_data_out : 32'hz;
assign DIV_B = op_flags[DIV] || op_flags[DIVU] ? Rt_data_out : 32'hz;

// ʵ���������� 
Decoder my_Decoder(
    .instr_in(instr_in),   
    .op_flags(op_flags),    
    .RsC(RsC),               
    .RtC(RtC),                
    .RdC(RdC),              
    .shamt(shamt),             
    .immediate(immediate),     
    .address(address)          
    );

/* ʵ���������� */
Controler my_Controler(              
    .op_flags(op_flags),     
    .zero_flag(zero),          
    .sign_flag(negative),     
    .reg_w(reg_w),            
    .aluc(aluc),              
    .dm_r(dm_r),             
    .dm_w(dm_w),            
    .HI_w(HI_w),             
    .LO_w(LO_w),         
    .cause(cause),           
    .ext_ena(ext_ena),      
    .cat_ena(cat_ena),      
    .mux(mux),              
    .mux6_1(mux6_1),         
    .mux7_1(mux7_1)          
    );

/* ʵ����ALU */
ALU my_ALU(                      
    .A(a),                   
    .B(b),                    
    .ALUC(aluc),               
    .alu_data_out(alu_data_out),
    .zero(zero),               
    .carry(carry),          
    .negative(negative)       
    );

/* ʵ�����Ĵ����� */
regfile cpu_ref(               
    .reg_clk(clk),          
    .reg_ena(ena),              
    .rst(rst),                
    .reg_w(reg_w),             
    .RdC(RdC),                  
    .RtC(RtC),                 
    .RsC(RsC),               
    .Rd_data_in(Rd_data_in),    
    .Rs_data_out(Rs_data_out),
    .Rt_data_out(Rt_data_out)  
    );

/* ʵ����PC�Ĵ��� */
PC my_PC(                   
    .pc_clk(clk),            
    .pc_ena(ena),              
    .rst(rst),                 
    .pc_addr_in(pc_addr_in),   
    .pc_addr_out(pc_addr_out)  
    );

/* ʵ����HI_LO�Ĵ��� */
HI_LO my_HI_LO(
    .HI_LO_clk(clk),          
    .HI_LO_ena(ena),          
    .HI_LO_rst(rst),          
    .HI_in(mux5_out),         
    .LO_in(mux6_out),            
    .HI_w(HI_w),              
    .LO_w(LO_w),               
    .HI_out(HI_out),        
    .LO_out(LO_out)      
    );

MUX my_MUX6_1(
    .chosen(mux6_1),        
    .line0(Rs_data_out),    
    .line1(npc),          
    .line2(add_out_61),   
    .line3(32'h00400004),   
    .line4(epc_out),       
    .line5(cat_out),        
    .line6(32'bz),       
    .line7(32'bz),        
    .MUX_out(mux6_1_out)   
    );

MUX my_MUX7_1(
    .chosen(mux7_1),      
    .line0(dm_data),     
    .line1(mux7_out),      
    .line2(CLZ_out),       
    .line3(mux8_out),      
    .line4(MUL_LO),      
    .line5(add_out_71),     
    .line6(cp0_out),        
    .line7(32'bz),         
    .MUX_out(mux7_1_out)   
    );

DIV my_DIV(
    .sign_flag(sign_flag),  
    .A(DIV_A),              
    .B(DIV_B),             
    .R(DIV_R),              
    .Q(DIV_Q)              
    );

MUL my_MUL(
    .sign_flag(sign_flag), 
    .A(MUL_A),              
    .B(MUL_B),             
    .HI(MUL_HI),           
    .LO(MUL_LO)            
    );

CP0 my_CP0(
    .cp0_clk(clk),         
    .cp0_rst(rst),          
    .cp0_ena(ena),         
    .MFC0(op_flags[MFC0]),   
    .MTC0(op_flags[MTC0]),   
    .ERET(op_flags[ERET]), 
    .PC(pc_addr_out),      
    .addr(mux1_out),        
    .cause(cause),          
    .data_in(Rt_data_out),  
    .CP0_out(cp0_out),     
    .EPC_out(epc_out)       
    );

CLZ my_CLZ(
    .CLZ_in(Rs_data_out),   
    .CLZ_out(CLZ_out)       
    );

endmodule
