`timescale 1ns / 1ps

//异步读取数据，同步写入
module DMEM(                    
    input dm_clk,               
    input dm_ena,               
    input dm_r,                 //读取时拉高
    input dm_w,                 //写入时拉高
    input sb_flag,             
    input sh_flag,              
    input sw_flag,             
    input lb_flag,              
    input lh_flag,
    input lbu_flag,     
    input lhu_flag,         
    input lw_flag,           
    input [6:0] dm_addr,        //要读/写的地址
    input [31:0] dm_data_in,   
    output [31:0] dm_data_out  
    );

reg [31:0] dmem [31:0];//DMEM区域

always @(negedge dm_clk) begin
    //使能端开启、写指令有效且读指令无效时，才向寄存器中写入数据
    if(dm_ena && dm_w &&!dm_r) begin
        if(sb_flag)         //如果是SB指令，不需要对地址再做处理
            dmem[dm_addr][7:0] <= dm_data_in[7:0];
        else if(sh_flag)    //如果是SH指令，需要对地址除以二
            dmem[dm_addr >> 1][15:0] <= dm_data_in[15:0];
        else if(sw_flag)    //剩下的就是SW指令，需要对地址除以四
            dmem[dm_addr >> 2] <= dm_data_in;
    end
end

//使能端开启、读指令有效且写指令无效时，才将对应地址的数据送出，否则置为高阻抗
assign dm_data_out = (dm_ena && dm_r && !dm_w) ? 
                     (lb_flag ? { {24{dmem[dm_addr][7]}} , dmem[dm_addr][7:0] } : 
                     (lbu_flag ? { 24'h0 , dmem[dm_addr][7:0] } :
                     (lh_flag ? { {16{dmem[dm_addr >> 1][15]}} , dmem[dm_addr >> 1][15:0] } :
                     (lhu_flag ? { 16'h0 , dmem[dm_addr >> 1][15:0] } :
                     (lw_flag ? dmem[dm_addr >> 2]: 32'bz))))) : 32'bz;

endmodule
