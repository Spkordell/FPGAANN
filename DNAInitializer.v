`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:54:32 10/20/2012 
// Design Name: 
// Module Name:    DNAInitializer 
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
module DNAInitializer(randomizeEnabled,networkState,finished,randomNum,clk,ramBusDataIn,ramBusAddr,ramLatch,ramReady,ramInstruction);

//this module randomly generates the initial DNA for the network

//Network configuration parameters
parameter INPUT_COUNT=1;					//number of inputes the network has
parameter OUTPUT_COUNT=1;					//number of outputs the network has
parameter NEURON_COUNT=2;					//number of neurons in the network
parameter CONNECTIONS=2;					//number of inputs each neuron recieves
parameter NETWORKS_PER_POPULATION=16;	//number of networks in each population

//Miscellanious Inputs
input randomizeEnabled;
input [1:0]networkState;
output reg finished=0;
input [8:0]randomNum;

//Memory Control
input clk;
output reg [15:0]ramBusDataIn;
output reg [23:1]ramBusAddr=0;
output reg ramLatch;
input ramReady;
output reg ramInstruction;
parameter READ=0;
parameter WRITE=1;

//randomization mapping
wire [15:0]randomGene;

assign randomGene={randomNum}%(OUTPUT_COUNT+NEURON_COUNT+1); // Might be wrong //OUTPUT_COUNT+NEURON_COUNT+1 must be a power of 2

//Write random gene values to Ram
always @(posedge clk) begin	
	if (networkState==0) begin
		if (randomizeEnabled) begin
			if (ramReady) begin
				if (ramBusAddr<((OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS))*NETWORKS_PER_POPULATION)) begin	
					finished<=0;
					ramInstruction<=WRITE;
					ramBusDataIn<=randomGene;
					ramBusAddr<=ramBusAddr+1;
					ramLatch<=1;					
				end else begin
					finished<=1;
				end
			end
		end
	end
end

always @(negedge clk) begin
	ramLatch<=0;
end

endmodule 
