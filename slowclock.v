`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:59:31 04/03/2012 
// Design Name: 
// Module Name:    slowclock 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module slowclock (clk_in, clk_out);
input clk_in; output clk_out;
reg clk_out;
reg [25 : 0] period_count;
always @ (posedge clk_in)
	if (period_count!= 250000 - 1)
		begin
			period_count<= period_count + 1;
			clk_out <= 0;
		end
	else
		begin
			period_count <= 0;
			clk_out <= 1;
		end
endmodule