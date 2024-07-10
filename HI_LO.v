`timescale 1ns / 1ps

module HI_LO(
    input HI_LO_clk,        
    input HI_LO_ena,       
    input HI_LO_rst,       
    input [31:0] HI_in,     
    input [31:0] LO_in,   
    input HI_w,             //是否是向HI中写入数
    input LO_w,             //是否是向LO中写入数
    output [31:0] HI_out, 
    output [31:0] LO_out   
    );

reg [31:0] HI = 32'd0;     
reg [31:0] LO = 32'd0;      

assign HI_out = HI_LO_ena ? HI : 32'bz;
assign LO_out = HI_LO_ena ? LO : 32'bz;

always @(posedge HI_LO_rst or negedge HI_LO_clk) begin 
    if (HI_LO_ena && HI_LO_rst) begin
        HI <= 32'd0;
        LO <= 32'd0;
    end
    else if(HI_LO_ena)
    begin
        if(HI_w)
            HI <= HI_in;
        if(LO_w)
            LO <= LO_in;
    end
end

endmodule
