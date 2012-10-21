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
output [15:0]ramDataBusIn;
input [15:0]ramBusDataOut;
inout [23:1]ramBusAddr;
inout ramLatch;
input ramReady;
inout ramInstruction;
parameter READ=0;
parameter WRITE=1;

reg ramLatchTemp;
reg [23:1]ramBusAddrTemp=0;
assign ramLatch = (networkState==1) ? ramLatchTemp : 1'bz;
assign ramInstruction = (networkState==1) ? READ : 1'bz;
assign ramBusAddr = (networkState==1) ? ramBusAddrTemp : 23'bzzzzzzzzzzzzzzzzzzzzzzz;
	 
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
				MemAdr<=(nc1)*(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS));
				ramState<=READ;
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
			case (ramState)
				READ: begin
					MemDBOE<=0;
					RamCE <= 0;
					MemOE <= 0;
					RamLB <= 0;
					RamUB <= 0;	
					ramState<=READWAIT0;
				end
				WRITE: begin
					MemDBOE<=1;
					if (sortState==WRITE0) begin
						MemDBOut<=DNATemp1[geneCounter];
					end
					if (sortState==WRITE1) begin
						MemDBOut<=DNATemp0[geneCounter];
					end
					RamCE<=0;
					MemWE<=0;
					RamLB<=0;
					RamUB<=0;
					ramState<=WRITEWAIT0;
				end
				RESET: begin
					FlashCE <= 1'b1;
					RamCE<=1'b1;
					MemOE<=1'b1;
					MemWE<=1'b1;
					RamLB<=1'b1;
					RamUB<=1'b1;
					RamAdv<=1'b0;
					RamClk<=1'b0;
					if (geneCounter<(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS))-1) begin
						MemAdr<=MemAdr+1;
						geneCounter<=geneCounter+1;
						if (sortState==READ0 || sortState==READ1) begin 
							ramState<=READ;
						end
						if (sortState==WRITE0 || sortState==WRITE1) begin 
							ramState<=WRITE;
						end
					end else begin
						case (sortState)
							READ0: begin
								MemAdr<=MemAdr+1;
								geneCounter<=0;
								sortState<=READ1;
								ramState<=READ;
							end
							READ1: begin
								MemAdr<=(nc1-1)*(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS));
								geneCounter<=0;
								sortState<=WRITE0;
								ramState<=WRITE;
							end
							WRITE0: begin
								MemAdr<=MemAdr+1;
								geneCounter<=0;
								sortState<=WRITE1;
								ramState<=WRITE;
							end
							WRITE1: begin
								sortState<=CHECK;
							end
						endcase
					end
				end
				WRITEWAIT0: begin
					ramState<=RESET;
				end
				READWAIT0: begin
					ramState<=READWAIT1;
				end
				READWAIT1: begin
					ramState<=READWAIT2;
				end
				READWAIT2: begin
					case (sortState)
						READ0: DNATemp0[geneCounter]<=MemDBIn;
						READ1: DNATemp1[geneCounter]<=MemDBIn;
					endcase
					ramState<=RESET;
				end
			endcase
		end
	end else begin
		nc1<=0;
		nc2<=0;	
		sortState<=CHECK;
		finished<=0;
		MemAdr<=0;
		MemOE<=1;
		MemWE<=1;
		RamAdv<=0;
		RamCE<=1;
		RamClk<=0;
		RamLB<=1;
		RamUB<=1;
		FlashCE<=1;
		MemDBOE<=0;
		networkFitness[activeNetwork]<=fitness;
	end
end

endmodule 