`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:11:05 10/21/2012 
// Design Name: 
// Module Name:    DNACrosser 
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
//This module crosses successful brains
//////////////////////////////////////////////////////////////////////////////////
module DNACrosser(networkState,finished,randomNum,clk,ramBusDataOut,ramBusDataIn,ramBusAddr,ramLatch,ramReady,ramInstruction);


//Network Configuration Parameters
parameter INPUT_COUNT=1;					//number of inputes the network has
parameter OUTPUT_COUNT=1;					//number of outputs the network has
parameter NEURON_COUNT=2;					//number of neurons in the network
parameter CONNECTIONS=2;					//number of inputs each neuron recieves
parameter NETWORKS_PER_POPULATION=16;	//number of networks in each population

parameter LOW_MUTATION_PROBABILITY=2;	//chance of mutation for low mutation offspring
parameter HIGH_MUTATION_PROBABILITY=10;//chance of mutation for high mutation offspring

//Special variables
input [1:0]networkState;
output reg finished=0;
input [8:0]randomNum;

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
assign ramLatch = (networkState==3) ? ramLatchTemp : 1'bz;
assign ramInstruction = (networkState==3) ? ramInstructionTemp : 1'bz;
assign ramBusAddr = (networkState==3) ? ramBusAddrTemp : 23'bzzzzzzzzzzzzzzzzzzzzzzz;
assign ramBusDataIn = (networkState==3) ? ramBusDataInTemp : 16'bzzzzzzzzzzzzzzzz;

//Random Number Mapping
wire [6:0]random100;
wire [15:0]randomGene;
assign random100={randomNum}%128;									 	//random number between 0 and 127
assign randomGene={randomNum}%(OUTPUT_COUNT+NEURON_COUNT+1);	// Might be wrong //must be a power of 2 //

//Breeding variables
reg [1:0]mother=0;
reg [1:0]father=1;
reg [3:0]offspring=4;
reg [15:0]DNATemp2;
reg [15:0]DNATemp3;
reg [22:0]geneCounter;

//mutationState
parameter LOW=0;
parameter HIGH=1;
reg mutationLevel=LOW;

//crossMachine
parameter READ2=0;
parameter READ3=1;
parameter WRITE4=2;
parameter STOPCROSS=3;
reg [1:0]crossState=READ2;

//cross Brains
always @(posedge clk) begin
	if (networkState==3) begin
		if(ramReady) begin
			ramLatchTemp<=1;
			case (crossState)
				READ2: begin
					ramBusAddrTemp<=mother*(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS))+geneCounter;
					ramInstructionTemp<=READ;
				end
				READ3: begin
					ramBusAddrTemp<=father*(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS))+geneCounter;
					ramInstructionTemp<=READ;
				end
				WRITE4:begin
					ramBusAddrTemp<=offspring*(OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS))+geneCounter;
					ramInstructionTemp<=WRITE;
					case (mutationLevel) 
						LOW: begin
							if (random100<((127-(127*LOW_MUTATION_PROBABILITY))/2)) begin
								ramBusDataInTemp<=DNATemp2;
							end else begin
								if (random100<(127-(127*LOW_MUTATION_PROBABILITY))) begin
									ramBusDataInTemp<=DNATemp3;
								end else begin //approximatly 2% chance of mutation
									ramBusDataInTemp<=randomGene;		
								end
							end
						end
						HIGH: begin
							if (random100<((127-(127*HIGH_MUTATION_PROBABILITY))/2)) begin
								ramBusDataInTemp<=DNATemp2;
							end else begin
								if (random100<(127-(127*HIGH_MUTATION_PROBABILITY))) begin
									ramBusDataInTemp<=DNATemp3;
								end else begin //approximatly 20% chance of mutation
									ramBusDataInTemp<=randomGene;		
								end
							end
						end
					endcase
					if (geneCounter > (OUTPUT_COUNT+(NEURON_COUNT*CONNECTIONS)-1)) begin
						geneCounter<=0;
						offspring<=offspring+1;
						case (offspring)
							4: begin
								mother<=0;
								father<=2;	
								crossState<=READ2;
								mutationLevel<=LOW;
							end
							5: begin
								mother<=0;
								father<=3;		
								crossState<=READ2;
								mutationLevel<=LOW;
							end
							6: begin
								mother<=1;
								father<=2;		
								crossState<=READ2;
								mutationLevel<=LOW;
							end
							7: begin
								mother<=1;
								father<=3;		
								crossState<=READ2;
								mutationLevel<=LOW;
							end
							8: begin
								mother<=2;
								father<=3;
								crossState<=READ2;
								mutationLevel<=LOW;
							end						
							9: begin
								mother<=0;
								father<=1;	
								crossState<=READ2;
								mutationLevel<=HIGH;
							end
							10: begin
								mother<=0;
								father<=2;		
								crossState<=READ2;
								mutationLevel<=HIGH;
							end
							11: begin
								mother<=0;
								father<=3;		
								crossState<=READ2;
								mutationLevel<=HIGH;
							end
							12: begin
								mother<=1;
								father<=2;		
								crossState<=READ2;
								mutationLevel<=HIGH;
							end
							13: begin
								mother<=1;
								father<=3;
								crossState<=READ2;
								mutationLevel<=HIGH;
							end
							14: begin
								mother<=2;
								father<=3;
								crossState<=READ2;
								mutationLevel<=HIGH;
							end				
							15: begin
								crossState<=STOPCROSS;
								finished<=1;
							end
						endcase
					end else begin
						geneCounter<=geneCounter+1;
						crossState<=READ2;
					end
				end
			endcase
		end else begin
			ramLatchTemp<=0;
		end
	end else begin
		mother<=0;
		father<=1;
		offspring<=4;
		geneCounter<=0;	
		mutationLevel<=LOW;	
		crossState<=READ2;
	end
end

always @(posedge ramReady) begin
	case (crossState)
		READ2: begin
			DNATemp2<=ramBusDataOut;
			crossState<=READ3;
		end
		READ3: begin
			DNATemp3<=ramBusDataOut;
			crossState<=WRITE4;
		end
	endcase
end

endmodule 
