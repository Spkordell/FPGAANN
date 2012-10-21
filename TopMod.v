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
module TopMod(clk,MemDB,MemAdr,RamCE,MemOE,MemWE,RamAdv,RamClk,RamLB,RamUB,FlashCE);

parameter READ=0;
parameter WRITE=1;

input clk;
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

reg ramInstruction;
reg ramLatch;
wire [15:0]ramBusDataOut;
reg [15:0]ramBusDataIn=0;
reg [23:1]ramBusAddr=0;
wire ramReady;

RAMControl RC(clk,ramInstruction,ramLatch,ramBusDataOut,ramBusDataIn,ramBusAddr,MemAdr,MemDB,RamCE,MemOE,MemWE,RamAdv,RamClk,RamLB,RamUB,FlashCE,ramReady);

Network NN(timeToRun,networkState,activeNetwork,networkFinished,nin,nout,clk,ramBusDataOut,ramBusAddr,ramLatch,ramReady,ramInstruction);

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
