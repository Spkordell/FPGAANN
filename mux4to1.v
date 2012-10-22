`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:04:16 04/03/2012 
// Design Name: 
// Module Name:    mux4to1 
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
module mux4to1( input [3:0] A, B, C, D, input [1:0] sel, output [3:0] Y);
	assign Y = (sel==0)?A : (sel==1)?B : (sel==2)?C : D;
endmodule
