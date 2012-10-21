`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:31:38 10/20/2012 
// Design Name: 
// Module Name:    RamTest 
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
module TopMod(clk,nin,nout,MemDB,MemAdr,RamCE,MemOE,MemWE,RamAdv,RamClk,RamLB,RamUB,FlashCE);

parameter READ=0;
parameter WRITE=1;

input clk;

input [0:0]nin;
output [0:0]nout;

inout  [15:0]MemDB;
output [23:1]MemAdr;
output RamCE;
output MemOE;
output MemWE;
output RamAdv;
output RamClk;
output RamLB;
output RamUB;
output FlashCE;

//Some network settings
reg randomizeEnabled=1;

//Ram lines
wire ramInstruction;
wire ramLatch;
wire [15:0]ramBusDataOut;
wire [15:0]ramBusDataIn;
wire [23:1]ramBusAddr;
wire ramReady;

reg [63:0]timeToRun=25000000;

//Netowrk Control Lines
wire networkState;
wire initializeFinished;
wire sortFinished;
wire crossFinished;
wire networkFinished;

//Information Lines
wire [3:0]activeNetwork;
wire [7:0]generationCounter;

//Misc. Connection Lines
wire [7:0]randomnum;

RAMControl RC(clk,ramInstruction,ramLatch,ramBusDataOut,ramBusDataIn,ramBusAddr,MemAdr,MemDB,RamCE,MemOE,MemWE,RamAdv,RamClk,RamLB,RamUB,FlashCE,ramReady);
Network NN(timeToRun,networkState,activeNetwork,networkFinished,nin,nout,clk,ramBusDataOut,ramBusAddr,ramLatch,ramReady,ramInstruction);
NetworkControl NC(clk,networkState,initializeFinished,sortFinished,crossFinished,networkFinished,generationCounter);
DNAInitializer INIT(randomizeEnabled,networkState,initializeFinished,randomnum,clk,ramBusDataIn,ramBusAddr,ramLatch,ramReady,ramInstruction);
PNGenerator RAND(clk, 0, randomnum);


/*

always @(posedge clk) begin
	if (ramReady) begin
		ramInstruction<=WRITE;
		ramBusDataIn<=ramBusDataIn+1;
		ramBusAddr<=ramBusAddr+1;
		ramLatch<=1;
	end
end

always @(negedge clk) begin
	ramLatch<=0;
end
*/

endmodule
