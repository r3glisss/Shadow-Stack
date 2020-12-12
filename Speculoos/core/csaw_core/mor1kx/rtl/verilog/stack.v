`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Grenoble INP - Esisar
// Engineer: Team Esisar
// 	Bresch Cyril <cyrbresch@gmail.com>
//	Michelet Adrien <a.michelet-gignoux@hotmail.fr>
//	Amato Laurent <amato.laurent@gmail.com>
//	Meyer Thomas <thomasm0301@gmail.com>
// 
// Create Date: 27.10.2016 
// Design Name: Speculoos
// Module Name: stack
// Project Name: CSAW_ESC_2016_Speculoos
// Target Devices: De0_nano
// Description: stack
// 
// Dependencies: master=>monitor.v
// 
// Revision 1.0 - 07.11.206 - Final release
// Revision 0.01 - 27.10.2016 - File Created 
// 
//////////////////////////////////////////////////////////////////////////////////

module stack(
    clk,
    en,
    reset,
    data_in,
    push_pop,
    data_out,
    stack_violation,
    stack_empty
    );
    
// Input declarations
    input clk;
    input en;
    input [31:0] data_in;
    input push_pop; // 1 Push , 0 Pop
    input reset;
    
// Output declarations
    output [31:0] data_out;
    output stack_violation;
    output stack_empty;
    
// Wires
    wire clk;
    wire en;
    wire push_pop;
    wire [31:0] data_in;
    wire reset;

// Registers
    reg [31:0] data_out;
    reg stack_violation;
    reg [31:0] segment [0:127];
    reg stack_empty;
    reg full;
    integer SP;
    integer i;
    
// Stack initialization
initial begin

    SP <= 127;
    stack_empty <= 1;
    full <= 0;
    data_out <= 32'b0;
    stack_violation <= 0;
    
    for(i=0; i<128; i=i+1) 
    begin
	segment[i] <= 32'b0;
    end     
end    
    
always @ (posedge clk)
begin
    // Reset
    if(reset) 
    begin
        SP <= 127;
	stack_empty <= 1;
        full <= 0;
        data_out <= 32'b0;
        stack_violation <= 0;
        for(i=0; i<128; i=i+1) 
        begin
            segment[i] <= 32'b0;
        end
    end
    
    if(full == 1)
    begin
        stack_violation <= 1;
    end
    else
    begin 
        stack_violation <= 0;
    end
    
    case (SP)
        127:
        begin
             full <= 0;
	     stack_empty <= 1;    
        end
        
        0:
        begin   
             full <= 1;
             stack_empty <= 0;
        end
        
        default:
        begin
            full <= 0;
            stack_empty <= 0;
        end 
    endcase
    
    if(en && push_pop == 1 && full ==0)
    begin
        segment[SP] <= data_in;                    
        if(!SP == 0) 
        begin
		SP <= SP -1;
        end                         
    end
           
    if (en && push_pop == 0 && stack_empty == 0)
    begin
        data_out <= segment[SP+1];
        SP <= SP + 1;
    end   
end
    
endmodule
