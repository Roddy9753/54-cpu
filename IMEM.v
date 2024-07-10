`timescale 1ns / 1ps

module IMEM(
    input [10:0] im_addr_in,     //指令码地址
    output [31:0] im_instr_out   //32位指令码
    ); 
    
//实例化IP核
dist_mem_gen_0 imem(   
    .a(im_addr_in),  
    .spo(im_instr_out)
    );
    
endmodule
