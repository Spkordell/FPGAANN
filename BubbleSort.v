`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:58:22 10/21/2012 
// Design Name: 
// Module Name:    BubbleSort 
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
//Sorts networks by their fitness
//////////////////////////////////////////////////////////////////////////////////
module BubbleSort(networkState,finished,fitness,activeNetwork,clk,ramBusDataOut,ramBusDataIn,ramBusAddr,ramLatch,ramReady,ramInstruction);

//Network Configuration Parameters
parameter INPUT_COUNT=2;					//number of inputes the network has
parameter OUTPUT_COUNT=1;					//number of outputs the network has
parameter NEURON_COUNT=5;					//number of neurons in the network
parameter CONNECTIONS=2;					//number of inputs each neuron recieves
parameter NETWORKS_PER_POPULATION=16;	//number of networks in each population

//special inputs
input [1:0]networkState;
output reg finished=0;
input [15:0]fitness;
input[3:0]activeNetwork;

//Memory Control Interface
input clk;
inout [15:0]ramBusDataIn;
input [15:0]ramBusDataOut;
inout [23:1]ramBusAddr;
inout ramLatch;
input ramReady;
inout ramInstruction;
parameter READ=0;
parameter WRITE=1;

reg ramLatchTemp;
reg [23:1]ramBusAddrTemp=0;
reg ramInstructionTemp;
reg [15:0]ramBusDataInTemp;
assign ramLatch = (networkState==2) ? ramLatchTemp : 1'bz;
assign ramInstruction = (networkState==2) ? ramInstructionTemp : 1'bz;
assign ramBusAddr = (networkState==2) ? ramBusAddrTemp : 23'bzzzzzzzzzzzzzzzzzzzzzzz;
assign ramBusDataIn = (networkState==2) ? ramBusDataInTemp : 16'bzzzzzzzzzzzzzzzz;
	 
//Network sort variables
reg [15:0]networkFitness[NETWORKS_PER_POPULATION-1:0];
reg [15:0]DNATemp0[OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS)-1:0];
reg [15:0]DNATemp1[OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS)-1:0];
reg [15:0]geneCounter;
reg [4:0]nc1=0;
reg [4:0]nc2=0;

genvar v;
generate
	for(v=0;v<OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS);v=v+1) begin:initializeTemps
		initial DNATemp0[v]=0;
		initial DNATemp1[v]=0;
	end
endgenerate

//sort machine
parameter CHECK=0;
parameter READ0=1;
parameter READ1=2;
parameter WRITE0=3;
parameter WRITE1=4;
parameter STOP=5;
reg [2:0]sortState=CHECK;

//perform sort
always @(posedge clk) begin
	if (networkState==2) begin
		if (sortState==CHECK) begin
			if (networkFitness[nc1]<networkFitness[nc1+1]) begin		
				networkFitness[nc1+1]<=networkFitness[nc1];  	
				networkFitness[nc1]<=networkFitness[nc1+1];		
				sortState<=READ0;		
				ramBusAddrTemp<=(nc1)*(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS));
				geneCounter<=0;
			end
			if (nc1<(NETWORKS_PER_POPULATION-1)) begin
				nc1<=nc1+1;
			end else begin
				if (nc2<NETWORKS_PER_POPULATION) begin
					nc2<=nc2+1;
					nc1<=0;
				end else begin
					sortState<=STOP;
					finished<=1;
				end
			end
		end else begin
			if (ramReady) begin
				if (geneCounter<(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS))-1) begin
					ramBusAddrTemp<=ramBusAddrTemp+1;
					geneCounter<=geneCounter+1;
					if (sortState==READ0 || sortState==READ1) begin 
						ramInstructionTemp<=READ;
					end
					if (sortState==WRITE0) begin
						ramBusDataInTemp<=DNATemp1[geneCounter];
						ramInstructionTemp<=WRITE;
					end
					if (sortState==WRITE1) begin
						ramBusDataInTemp<=DNATemp0[geneCounter];
						ramInstructionTemp<=WRITE;
					end
					ramLatchTemp<=1;
				end else begin
					case (sortState)
						READ0: begin
							ramBusAddrTemp<=ramBusAddrTemp+1;
							geneCounter<=0;
							sortState<=READ1;
						end
						READ1: begin
							ramBusAddrTemp<=(nc1-1)*(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS));
							geneCounter<=0;
							sortState<=WRITE0;
						end
						WRITE0: begin
							ramBusAddrTemp<=ramBusAddrTemp+1;
							geneCounter<=0;
							sortState<=WRITE1;
						end
						WRITE1: begin
							sortState<=CHECK;
						end
					endcase
				end
			end else begin
				ramLatchTemp<=0;
			end
		end
	end else begin
		nc1<=0;
		nc2<=0;	
		sortState<=CHECK;
		finished<=0;
		ramBusAddrTemp<=0;
		networkFitness[activeNetwork]<=fitness;
	end
end

always @(posedge ramReady) begin
	case (sortState)
		READ0: DNATemp0[geneCounter]<=ramBusDataOut;
		READ1: DNATemp1[geneCounter]<=ramBusDataOut;
	endcase
end

endmodule 