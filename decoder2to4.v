`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:06:15 04/03/2012 
// Design Name: 
// Module Name:    decoder2to4 
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
module decoder2to4 (input [1:0] en, output reg [3:0] an);
always@(en)
begin
	case (en)
	0: an=4'b1110;
	1: an=4'b1101;
	2: an=4'b1011;
	3: an=4'b0111;
	endcase
end
endmodule
