`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:14:46 10/20/2012 
// Design Name: 
// Module Name:    NetworkControl 
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
module NetworkControl(clk,networkState,initializeFinished,sortFinished,crossFinished,networkFinished,generationCounter);

	parameter NETWORKS_PER_POPULATION=16;	//number of networks in each population

	//Network Control State Machine
	parameter INITIALIZE=0;
	parameter RUN=1;
	parameter SORT=2;
	parameter CROSS=3;
	
	input clk;
	output reg [1:0]networkState=INITIALIZE;
	input initializeFinished;
	input sortFinished;
	input crossFinished;
	input networkFinished;
	//output reg nextNetwork;
	output reg [7:0]generationCounter=0;
	
	//reg [63:0]cycleCounter=0;
	//output reg [4:0]activeNetwork=0;
	
	always @(posedge clk) begin
		case (networkState)
			INITIALIZE: begin
				if (initializeFinished) begin
					networkState<=RUN;
				end
			end
			RUN: begin
				if (networkFinished) begin
					networkState<=SORT;
				end
			end
			SORT: begin
				if (sortFinished) begin
					networkState<=CROSS;  //re-add this one
					//delete these two lines
					//networkState<=RUN;
					//generationCounter<=generationCounter+1;
					///
				end
			end
			CROSS: begin
				if (crossFinished) begin
					networkState<=RUN;
					generationCounter<=generationCounter+1;
				end
			end
		endcase
	end
	
endmodule

