`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:37:16 10/20/2012 
// Design Name: 
// Module Name:    Network 
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
//Experimental Top Module, likely to be replaced with a more permenent design later
//////////////////////////////////////////////////////////////////////////////////
module Network(timeToRun,networkState,activeNetwork,networkFinished,nin,nout,clk,ramBusDataOut,ramBusAddr,ramLatch,ramReady,ramInstruction);
//loads and runs network

//network configuration parameters
parameter INPUT_COUNT=1;					//number of inputes the network has
parameter OUTPUT_COUNT=1;					//number of outputs the network has
parameter NEURON_COUNT=2;					//number of neurons in the network
parameter CONNECTIONS=2;					//number of inputs each neuron recieves
parameter NETWORKS_PER_POPULATION=16;	//number of networks in each population

parameter TOTAL_GENES=OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS);

input [63:0]timeToRun;

//network inputs and outputs
input [INPUT_COUNT-1:0]nin;
output [OUTPUT_COUNT-1:0]nout;

//network control pins
input [1:0]networkState;
output reg [3:0]activeNetwork=0;
output reg networkFinished=0;

//memory control
input clk;
input [15:0]ramBusDataOut;
output reg [23:1]ramBusAddr=0;
output reg ramLatch;
input ramReady;
output reg ramInstruction;
parameter READ=0;
parameter WRITE=1;

//Network connection variables
reg [15:0]DNA[OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS)-1:0];
wire [(NEURON_COUNT*CONNECTIONS)-1:0]Iconnection;
wire [NEURON_COUNT+INPUT_COUNT-1:0]Oconnection;

//DNA loader variables
reg [22:0]DNACounter=0;
reg [63:0]cycleCounter=0;

reg enableNeurons=0;

//-------------------------NETWORK CONSTRUCTION BEGIN------------------------------
genvar a;
generate
	for(a=0;a<INPUT_COUNT;a=a+1) begin:OcconnectionGeneration
		assign Oconnection[a]=nin[a];
	end
endgenerate

genvar b;
generate
	for(b=0;b<(NEURON_COUNT*CONNECTIONS);b=b+1) begin:IconnectionGenerate
		assign Iconnection[b] = Oconnection[DNA[b]];
	end
endgenerate

genvar c;
generate
	for (c=0;c<OUTPUT_COUNT;c=c+1) begin:outputGenerate
		assign nout[c] = Oconnection[DNA[c+(NEURON_COUNT*CONNECTIONS)]];
	end
endgenerate

genvar d;
generate
	for (d=0;d<(NEURON_COUNT*CONNECTIONS);d=d+CONNECTIONS) begin:neuronGenerate
		Neuron U(enableNeurons,{Iconnection[d],Iconnection[d+(CONNECTIONS-1)]},Oconnection[INPUT_COUNT+(d/2)]);
	end
endgenerate
//-------------------------NETWORK CONSTRUCTION END--------------------------------

//-----------------------------DNA LOADER BEGIN------------------------------------
always @(posedge clk) begin
	if (networkState==1) begin
		if (cycleCounter>=timeToRun) begin
			if (activeNetwork>=(NETWORKS_PER_POPULATION-1)) begin
				networkFinished<=1;
				activeNetwork<=0;
				enableNeurons<=0;
			end else begin
				networkFinished<=0;
				DNACounter<=0;
				cycleCounter<=0;
				activeNetwork<=activeNetwork+1;
			end
		end else begin
			cycleCounter<=cycleCounter+1;
		end
		if (ramReady) begin
			if (DNACounter<=(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS))-1) begin		
				ramBusAddr<=ramBusAddr+1;		
				DNACounter<=DNACounter+1;
				enableNeurons<=0;
				ramInstruction<=READ;
				ramLatch<=1;
			end else begin
				enableNeurons<=1;		
			end
		end else begin
			ramLatch<=0;
		end
	end else begin
		DNACounter<=0;
		ramBusAddr<=0;
		networkFinished<=0;
		activeNetwork<=0;
		cycleCounter<=0;
	end
end
//------------------------------DNA LOADER END-------------------------------------

always @(posedge ramReady) begin
	DNA[DNACounter]<=ramBusDataOut;
end

endmodule 
