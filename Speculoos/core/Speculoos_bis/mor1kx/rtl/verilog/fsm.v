//////////////////////////////////////////////////////////////////////////////////
// Company: Grenoble INP - Esisar
// Engineer: Team Esisar
// 	Bresch Cyril <cyrbresch@gmail.com>
//	Michelet Adrien <a.michelet-gignoux@hotmail.fr>
//	Amato Laurent <amato.laurent@gmail.com>
//	Meyer Thomas <thomasm0301@gmail.com>
// 
// Create Date: 27.10.2016 
// Design Name: SpeculoosV2
// Module Name: speculoos
// Project Name: CSAW_ESC_2016_Speculoos
// Target Devices: De0_nano
// Description: speculoos
// 
// Dependencies: master=>mor1kx_cpu_cappuccino.v slave=>(monitor.v observer.v)
// 
// Revision 1.0 - 07.11.206 - Final release
// Revision 0.01 - 27.10.2016 - File Created 
// 
//////////////////////////////////////////////////////////////////////////////////

// Module FSM
module fsm (
clk,			// Horloge
reset,			// Reset
interrupt_en,
obs_insn_i,
obs_address,		// Link Register R9
waddr, 			// To detect Write Access R9
st_data_in,		// @ to stack
st_data_out,		// @ from stack
st_push_pop,		// Push / Pop to stack
st_en,			// Enable stack
interrupt,		// Interrupt to security register
current_state
);

// Input declarations
input [31:0] obs_address; 
input [31:0] obs_insn_i; 
input clk, reset, interrupt_en;
input [31:0] st_data_in;
input [4:0] waddr;

// Output declarations
output st_push_pop;
output st_en;
output interrupt;
output [31:0] st_data_out;
output [2:0] current_state;

// Wires
wire [31:0] obs_insn_i;
wire [31:0] obs_address;
//wire obs_jal, obs_jr;
wire clk, reset, interrupt_en;
wire [31:0] st_data_in;
wire [4:0] waddr;

// Registers
reg st_push_pop;
reg st_en = 1'b0;
reg interrupt = 1'b0;
reg [31:0] st_data_out;
wire [2:0] current_state;

// Internal constants
parameter SIZE = 3;
parameter IDLE = 3'b000, R9WRITE = 3'b001, PUSH = 3'b010, POP = 3'b011, WAIT = 3'b100, CHECK = 3'b101, WAIT2 = 3'b111,WAIT3 = 3'b110;

// Internal variables
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state; //test
reg [31:0] addressToCheck;
// Intern wires
wire [5:0] opcode;
assign opcode = obs_insn_i[31:26];
wire [4:0] jump_reg;
assign jump_reg = obs_insn_i[15:11];
assign current_state = state;



//----------Combo Function-----------------
 function [SIZE-1:0] fsm_function;
 input  [SIZE-1:0]  state ;	
 input  [5:0] opcode;
 input  [4:0] jump_reg;
 input  [4:0] waddr;
 

case(state)
		IDLE : 	
			if((opcode == 6'h11)&&(jump_reg == 5'h9)) 
				begin 				// JR go to WAIT falling edge before to pop
				fsm_function  = WAIT; 
				end 
			else if (opcode == 6'h1)  
				begin				// JALdetected go to R9 Write Access Detection
				fsm_function  = WAIT3;
				end
			else if (opcode ==6'h12)

				begin				// JALdetected go to R9 Write Access Detection
				fsm_function  = WAIT3;
				end
			else 	begin				// IDLE -> IDLE
				fsm_function  = IDLE; 
				end

		WAIT3 :  //Wait one cycle to avoid false R9 detection 				
				fsm_function  = R9WRITE; 
			
		R9WRITE : //Wait for R9 write Access
			if(waddr == 5'h9) 
				begin
				fsm_function = PUSH;
				end
			else
				begin
				fsm_function = R9WRITE;
				end

		PUSH :  //PUSH R9 in internal STACK
				if(opcode == 6'h11 && jump_reg == 5'h9) // We can detect a JR while Pushing R9
					begin 				// JR detected IDLE -> POP
					fsm_function  = POP; 
					end 
				else if(opcode != 6'h1 && opcode != 6'h12) // Go to idle 
					begin 			
					fsm_function  = IDLE; 
					end 
				else 	begin

					fsm_function  = WAIT2; 		// go to a wait state in case opcde is still JALL to avoid double detection
					end


		WAIT : // wait falling edge of opcode to pop the Stack
			if (opcode != 6'h11 ) begin 			
				fsm_function  = POP; 
			end else begin							
				fsm_function  = WAIT; 
			end 



		POP : 
			 if (opcode == 6'h1) 
				begin				// JALdetected go to R9 cacthcing//IDLE -> PUSH
				fsm_function  = R9WRITE;
				end		
			else if (opcode ==6'h12)

				begin				// JALdetected go to R9 cacthcing//IDLE -> PUSH
				fsm_function  = R9WRITE;
				end	 
			else 	begin							
				fsm_function  = CHECK;  	//go to check the data coherency between both stacks
				end
		       
// WAIT -> CHECK
		WAIT2 : // wait opcode change before to go to idle


			if (opcode != 6'h1 && opcode != 6'h12 ) 
				begin 			
				fsm_function  = IDLE; 
				end 
			else begin							
				fsm_function  = WAIT2; 
				end  		
		CHECK :
			 if (opcode == 6'h1) 
				begin				// JALdetected go to R9 cacthcing//IDLE -> PUSH
				fsm_function  = R9WRITE;
				end		
			else if (opcode ==6'h12)

				begin				// JALdetected go to R9 cacthcing//IDLE -> PUSH
				fsm_function  = R9WRITE;
				end	 
			else 	begin							
				fsm_function  = IDLE; 
				end
				
		
		default : fsm_function  = IDLE;
	endcase
  endfunction
always @ (state or opcode or jump_reg or waddr)
begin
 next_state = fsm_function(state, opcode, jump_reg,waddr);
end


always @ (state)
begin
 
case(state)
			IDLE : begin 
				st_data_out <= 32'b0;
				interrupt <= 1'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
				
				end
			PUSH : begin 
				interrupt <= 1'b0;
				st_en <= 1'b1;				// Stack
				st_push_pop <= 1'b1;			// Push Mode 
				st_data_out <= obs_address;		// @ read in the observer
				end

			R9WRITE : begin 
				st_data_out <= 32'b0;
				interrupt <= 1'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
				end

			POP : 	begin 
				st_en <= 1'b1;				// Stack
				st_push_pop <= 1'b0;			// Pop mode, getting the address at the next cycle
				st_data_out <= 32'b0;	
				interrupt <= 1'b0;
				addressToCheck <= obs_address;
				end
			WAIT : 	begin
				st_data_out <= 32'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
				interrupt <= 1'b0;
				end
			WAIT2 : begin
				st_data_out <= 32'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
				interrupt <= 1'b0;
				st_data_out <= 32'b0;
				end
			WAIT3 : begin
				st_data_out <= 32'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
				interrupt <= 1'b0;
				end
			CHECK : begin 
				interrupt <= |(obs_address ^ st_data_in);
				st_en <= 1'b0;
				st_push_pop <= 1'b0;
				st_data_out <= 32'b0;
				
				end
		endcase



end




// Sequential logic
always @ (posedge clk)
begin : FSM_Seq
	if(reset) begin
		state <= IDLE;
	end else begin
		state <= next_state;
	end
end


/*
// Output logic
always @ (posedge clk)
begin : FSM_Output_Logic
	if(reset) begin
		st_data_out <= 32'b0;	
		interrupt <= 1'b0;		
		st_push_pop <= 1'b0;	
		st_en <= 1'b0;			
		addressToCheck <= 32'b0;
	end else begin
		//interrupt <= !(|(obs_address ^ 32'hffffffff));
		current_state <= state;
		case(state)
			IDLE : begin 
				st_data_out <= 32'b0;
				interrupt <= 1'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
			end
			PUSH : begin 
				interrupt <= 1'b0;
				st_en <= 1'b1;				
				st_push_pop <= 1'b1;		
				st_data_out <= obs_address;	
			end
			POP : begin 
				st_en <= 1'b1;			
				st_push_pop <= 1'b0;	
				st_data_out <= 32'b0;	
				interrupt <= 1'b0;
				addressToCheck <= obs_address;
			end
			WAIT : begin
				st_data_out <= 32'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
			end
			WAIT2 : begin
				st_data_out <= 32'b0;
				st_push_pop <= 1'b0;
				st_en <= 1'b0;
			end
			CHECK : begin 
				interrupt <=  |(obs_address ^ st_data_in);
				st_en <= 1'b0;
			end
		endcase
	end
end*/

endmodule
