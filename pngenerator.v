`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:41:13 04/22/2012 
// Design Name: 
// Module Name:    pngenerator 
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
module PNGenerator(clk, reset, randomnum);

input clk;
input reset;
output reg [8:0] randomnum;

reg [7:0] randtemp;

always @(posedge clk)
begin
	if(reset)
		randtemp <= 8'b00110111;
	else if (randtemp == 8'b00000000)
		randtemp <= 8'b00110111;
	else begin
		randtemp [6:0] <= randtemp [7:1];
		randtemp [7] <= randtemp[6]^randtemp[7]^randtemp [0];
	end
	randomnum <= 9'b100000000+{1'b0,randtemp};
end	
	
	
endmodule
