`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:01:38 04/03/2012 
// Design Name: 
// Module Name:    my_counter 
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
module my_counter( clk, Q );
input clk;
output [1:0] Q;
reg [1:0] temp;
	always @(posedge clk)
		begin
		temp = temp + 1;
		end
	assign Q = temp;
endmodule
