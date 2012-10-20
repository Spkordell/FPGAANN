`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:30:53 10/20/2012 
// Design Name: 
// Module Name:    RAMControl 
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
//This module is meant to communicate with the onboard RAM chip in asynchronous Mode
//////////////////////////////////////////////////////////////////////////////////
module RAMControl(testData,LED,MemAdr,MemDB,RamCE,MemOE,MemWE,RamAdv,RamClk,RamLB,RamUB,FlashCE);

input testData[15:0];

output LED;

assign LED=1;

inout  [15:0] MemDB;
output [23:1]MemAdr;
output regRamCE;
output reg MemOE;
output reg MemWE;
output RamAdv;
output RamClk;
output RamLB;
output RamUB;
output FlashCE;

//make inout port available
wire [15:0] MemDBIn;
reg [15:0] MemDBOut=0;
reg	MemDBOE=0;
assign MemDB = MemDBOE ? MemDBOut : 16'hzzzz;
assign MemDBIn = MemDB;

//Set Constant Ports
assign RamAdv=0;
assign RamClk=0;
assign RamLB=0;
assign RamUB=0;
assign FlashCE=1;


endmodule
