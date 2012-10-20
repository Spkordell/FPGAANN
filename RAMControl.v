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
module RAMControl(clk,Instruction,latch,ramBusDataOut,ramBusDataIn,ramBusAddr,MemAdr,MemDB,RamCE,MemOE,MemWE,RamAdv,RamClk,RamLB,RamUB,FlashCE,Ready);

input clk;
input Instruction;
input latch;
input [15:0]ramBusDataIn;
output reg [15:0]ramBusDataOut;
input [23:1]ramBusAddr;

inout  [15:0]MemDB;
output reg [23:1]MemAdr;
output reg RamCE;
output reg MemOE;
output reg MemWE;
output RamAdv;
output RamClk;
output RamLB;
output RamUB;
output FlashCE;

output reg Ready;

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

parameter READ=0;
parameter WRITE=1;
parameter RESET=2;
parameter READWAIT0=3;
parameter READWAIT1=4;
parameter READWAIT2=5;
parameter READWAIT3=6;
parameter WRITEWAIT0=7;
parameter WRITEWAIT1=8;
parameter WRITEWAIT2=9;
parameter WRITEWAIT3=10;
reg [3:0]ramState=RESET;

always @(posedge clk) begin
	case (ramState)
		RESET: begin
			RamCE<=1;
			MemOE<=1;
			MemWE<=1;
			MemDBOE<=0;
			MemAdr<=ramBusAddr;
			if (latch) begin
				Ready<=0;
				if (Instruction==READ) begin
					ramState<=READ;
				end else begin
					ramState<=WRITE;		
					MemDBOut<=ramBusDataIn;
				end
			end
		end 	
		READ: begin
			MemDBOE<=0;
			RamCE<=0;
			MemOE<=0;
			MemWE<=1;
			ramState<=READWAIT0;
		end
		WRITE: begin
			MemDBOE<=1;
			RamCE<=0;
			MemWE<=0;
			ramState<=WRITEWAIT0;
		end
		READWAIT0: ramState<=READWAIT1;
		READWAIT1: ramState<=READWAIT2;
		READWAIT2: ramState<=READWAIT3;
		READWAIT3: begin
			ramState<=RESET;
			Ready<=1;
			ramBusDataOut<=MemDB;			
		end
		WRITEWAIT0: ramState<=WRITEWAIT1;
		WRITEWAIT1: ramState<=WRITEWAIT2;
		WRITEWAIT2: ramState<=WRITEWAIT3;	
		WRITEWAIT3: begin
			ramState<=RESET;
			Ready<=1;
		end		
	endcase
end
endmodule
