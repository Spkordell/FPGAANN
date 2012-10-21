`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:14:20 10/20/2012 
// Design Name: 
// Module Name:    Neuron 
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
//The Neuron module for the neural network
//////////////////////////////////////////////////////////////////////////////////
module Neuron(enable,in,out);
	parameter CONNECTIONS=2;					//number of inputs each neuron recieves
	parameter THRESHHOLD=CONNECTIONS/2;		//static threshold value
	input enable;
	input [CONNECTIONS-1:0]in;
	output out;
	assign out = enable ? ((in[0]+in[1] >= THRESHHOLD) ? 1'b0 : 1'b1) : 1'b0;//just added
endmodule
