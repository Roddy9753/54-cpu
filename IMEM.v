`timescale 1ns / 1ps

module IMEM(
    input [10:0] im_addr_in,     //ָ�����ַ
    output [31:0] im_instr_out   //32λָ����
    ); 
    
//ʵ����IP��
dist_mem_gen_0 imem(   
    .a(im_addr_in),  
    .spo(im_instr_out)
    );
    
endmodule
