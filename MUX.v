`timescale 1ns / 1ps
module MUX(
    input [2:0] chosen,     
    input [31:0] line0,     
    input [31:0] line1,    
    input [31:0] line2,   
    input [31:0] line3,     
    input [31:0] line4,    
    input [31:0] line5,    
    input [31:0] line6,    
    input [31:0] line7,   
    output [31:0] MUX_out   
    );

assign MUX_out = (chosen == 3'b000 ? line0 :
                 (chosen == 3'b001 ? line1 :
                 (chosen == 3'b010 ? line2 : 
                 (chosen == 3'b011 ? line3 : 
                 (chosen == 3'b100 ? line4 : 
                 (chosen == 3'b101 ? line5 :
                 (chosen == 3'b110 ? line6 :
                 (chosen == 3'b111 ? line7 : 32'bz))))))));

endmodule
