`timescale 1ns / 1ps
module ALU(                      
    input  [31:0] A,            
    input  [31:0] B,           
    input  [3:0] ALUC,          
    output [31:0] alu_data_out, 
    output zero,                 
    output carry,               
    output negative         
    );
/* 定义各指令对应的操作 */
parameter ADDU = 4'b0000;
parameter ADD  = 4'b0010;
parameter SUBU = 4'b0001;
parameter SUB  = 4'b0011;
parameter AND  = 4'b0100;
parameter OR   = 4'b0101;
parameter XOR  = 4'b0110;
parameter NOR  = 4'b0111;
parameter LUI1 = 4'b1000;
parameter LUI2 = 4'b1001; 
parameter SLT  = 4'b1011;
parameter SLTU = 4'b1010;
parameter SRA  = 4'b1100;
parameter SLL  = 4'b1110;  
parameter SLA  = 4'b1111;
parameter SRL  = 4'b1101;
/* 定义一些内部用的变量 */
reg [32:0] result;                  //存储结果，设置成33位是为了标志位的判断
wire signed [31:0] signedA,signedB; //由于A和B传进来是无符号的，因此我们需要定义两个有符号wire型变量来存储A和B在有符号解释下的值
assign signedA = A;
assign signedB = B;

always @(*)
begin
    case(ALUC)
        ADDU:       begin result <= A + B;                          end 
        ADD:        begin result <= signedA + signedB;              end
        SUBU:       begin result <= A - B;                          end
        SUB:        begin result <= signedA - signedB;              end
        AND:        begin result <= A & B;                          end
        OR:         begin result <= A | B;                          end
        XOR:        begin result <= A ^ B;                          end
        NOR:        begin result <= ~(A | B);                       end
        LUI1,LUI2:  begin result <= { B[15:0] , 16'b0 };            end
        SLT:        begin result <= signedA - signedB;              end
        SLTU:       begin result <= A - B;                          end
        SRA:        begin result <= signedB >>> signedA;            end
        SLL,SLA:    begin result <= B << A;                         end
        SRL:        begin result <= B >> A;                         end
    endcase
end 

assign alu_data_out = result[31:0];
assign zero = (result == 32'b0) ? 1 : 0;
assign carry = result[32]; 
assign negative =  (ALUC == SLT || ALUC == SUB ? (signedA < signedB) : ((ALUC == SLTU) ? (A < B) : 1'b0));//因为其他计算用不到negtive位，所以可以这么写
assign overflow = result[32];

endmodule
