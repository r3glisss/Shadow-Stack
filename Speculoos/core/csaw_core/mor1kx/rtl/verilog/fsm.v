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
// Module Name: monitor
// Project Name: CSAW_ESC_2016_Speculoos
// Target Devices: De0_nano
// Description: monitor
// 
// Dependencies: master=>speculoos.v slave=>(stack.v fsm.v)
// 
// Revision 1.0 - 07.11.206 - Final release
// Revision 0.01 - 27.10.2016 - File Created 
// 
//////////////////////////////////////////////////////////////////////////////////
module fsm (
clk,			// clock
reset,			// reset
obs_jal,		// l.jal detect
obs_jr,			// l.jr detect
obs_address,		// link register  
st_data_in,		// @ to stack
st_data_out,		// @ from stack
st_push_pop,		// push / pop to stack
st_en,			// enable stack
interrupt,		// interrupt
current_state,		// fsm state
stack_empty		// stack empty
);

// Input declarations
input [31:0] obs_address; 
input obs_jal, obs_jr;
input clk, reset;
input [31:0] st_data_in;
input stack_empty;

// Output declarations
output st_push_pop;
output st_en;
output interrupt;
output [31:0] st_data_out;
output [4:0] current_state;

// Wires
wire [31:0] obs_address;
wire obs_jal, obs_jr;
wire clk, reset;
wire [31:0] st_data_in;
wire stack_empty;

// Registers
reg st_push_pop;
reg st_en = 1'b0;
reg interrupt = 1'b0;
reg [31:0] st_data_out;
reg [4:0] current_state;

// Internal constants
parameter SIZE = 5;
parameter IDLE = 5'b00001, PUSH = 5'b00010, POP = 5'b00100, WAIT = 5'b01000, CHECK = 5'b10000;

// Internal variables
reg [SIZE-1:0] state;
wire [SIZE-1:0] next_state; 

assign next_state = fsm_function(state, obs_jal, obs_jr);

//----------Combo Function----------//
function [SIZE-1:0] fsm_function;
	input  [SIZE-1:0]  state ;	
	input    obs_jal ;
	input    obs_jr ;
	case(state)
		IDLE : 
			if(obs_jal == 1'b1) begin		
				fsm_function  = PUSH;				// IDLE -> PUSH
			end else if(obs_jr == 1'b1 && !stack_empty) begin 	
				fsm_function  = POP;				// IDLE -> POP
			end else begin						
				fsm_function  = IDLE;				// IDLE -> IDLE
			end
			
		PUSH : 
			if (obs_jr == 1'b1 ) begin 
				fsm_function  = POP; 				// PUSH -> POP
			end else begin  
				fsm_function  = IDLE;				// PUSH -> IDLE
			end	
		POP : fsm_function  = WAIT;					// POP -> WAIT
      		WAIT : fsm_function  = CHECK;					// WAIT -> CHECK
		CHECK :
			if(obs_jal == 1'b1) begin				
				fsm_function  = PUSH;				// CHECK -> PUSH
			end else if(obs_jr == 1'b1) begin	
				fsm_function  = POP;				// CHECK -> POP
			end else begin					
				fsm_function  = IDLE;				// CHECK -> IDLE
			end
		
		default : fsm_function  = IDLE;
	endcase
  endfunction


//----------Sequential Logic----------//
always @ (posedge clk)
begin : FSM_Seq
	if(reset) begin
		state <= IDLE;
	end else if (interrupt == 0)begin
		state <= next_state;
	end
end

//----------Output Logic----------//
always @ (posedge clk)
begin : FSM_Output_Logic
	if(reset) begin
		st_data_out <= 32'b0;		
		interrupt <= 1'b0;		
		st_push_pop <= 1'b0;	
		st_en <= 1'b0;			
	end else begin
		current_state <= state;
		case(state)
			IDLE : begin 
				st_data_out <= 32'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
			end
			PUSH : begin 
				st_en <= 1'b1;			
				st_push_pop <= 1'b1;		
				st_data_out <= obs_address;	
			end
			POP : begin 
				st_en <= 1'b1;			
				st_push_pop <= 1'b0;		
				st_data_out <= 32'b0;	
			end
			WAIT : begin
				st_data_out <= 32'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
			end
			CHECK : begin 
				interrupt <=  (|(obs_address ^ st_data_in)); 
			end
		endcase
	end
end

endmodule
