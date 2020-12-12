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

module observer(
    clk,
    reset,
    obs_insn_i,
    obs_address_i,
    obs_jal_o,
    obs_jr_o,
    obs_address_o
    );

// Port declaration
    input clk;
    input reset;
    input [31:0] obs_insn_i;
    input [31:0] obs_address_i;

    output obs_jal_o;
    output obs_jr_o;
    output [31:0] obs_address_o;

// Wires
    wire clk;
    wire reset;
    wire [31:0] obs_insn_i;
    wire [31:0] obs_address_i;

// Registers
   reg obs_jal_o = 1'b0;
    wire obs_jr_o;
    reg [31:0] obs_address_o = 32'h00000000;

// Intern wires
    wire [5:0] opcode;
    assign opcode = obs_insn_i[31:26];
    wire [4:0] jump_reg;
    assign jump_reg = obs_insn_i[15:11];

// Intern registers
    reg jal_first = 1'b0;
    reg jal_detect = 1'b0;
	 reg jal_detect2 = 1'b0;
	 reg jal_detect3 = 1'b0;
	 reg jal_detect4 = 1'b0;
	 reg jal_rise = 1'b0;
	 reg jr_detect = 1'b0;
	 reg jr_rise = 1'b0;
	 
		  
//
//always @ (posedge clk)
//begin
//    // Reset
//    if (reset)
//    begin
//		//	obs_jal_o <= 1'b0;
//			obs_jr_o <= 1'b0;
//		//	obs_address_o <= 32'h00000000;
//			jal_first <= 1'b0;
//			//jal_detect <= 1'b0; 
//    end
//
//    // Jump detection
//    if (opcode == 6'h1) //l.jal
//		begin
//			jal_first <= 1'b1;
//			//jal_detect <= 1'b1;
//			obs_jr_o <= 1'b0;
//		end
//    else if (opcode == 6'h11 && jump_reg == 5'h9 && jal_first) //l.jr to r9
//		begin
//			//jal_detect <= 1'b0;
//		//	obs_jal_o <= 1'b0;
//			obs_jr_o <= 1'b1;
//		//	obs_address_o <= obs_address_i;
//		end
//    else
//		begin
//		//	jal_detect <= 1'b0;
//			obs_jr_o <= 1'b0;
//    end
//end




always @ (posedge clk)

begin
  if (reset)
    begin
		
			jal_detect <= 1'b0; 
			jal_rise<= 1'b0;
    end
	 
	if ((opcode == 6'h1|| opcode ==6'h12) && jal_rise==1'b0) //l.jal
		begin
		//jal_detect <= 1'b1;
		jal_rise <= 1'b1;
		end
	else if ((opcode != 6'h1 && opcode !=6'h12) && jal_rise==1'b1)
		begin
			jal_rise <= 1'b0;
			jal_detect <= 1'b1;
		end
	
	else if ((opcode != 6'h1 && opcode !=6'h12)|| jal_rise==1'b0  )
		begin
			jal_detect <= 1'b0;
			
		end
end

always @ (posedge clk)
begin
  if (reset)
    begin
		jal_detect2 <= 1'b0;
		 
    end
	 
	if (jal_detect==1'b1) 
		begin
		jal_detect2 <= 1'b1;
		end
	else 
		begin
			jal_detect2 <= 1'b0;
		end
end
always @ (posedge clk)
begin
  if (reset)
    begin
		jal_detect3 <= 1'b0;
		 
    end
	 
	if (jal_detect2==1'b1) 
		begin
		jal_detect3 <= 1'b1;
		end
	else 
		begin
			jal_detect3 <= 1'b0;
		end
end
always @ (posedge clk)
begin
  if (reset)
    begin
		jal_detect4 <= 1'b0;
		 
    end
	 
	if (jal_detect3==1'b1) 
		begin
		jal_detect4 <= 1'b1;
		end
	else 
		begin
			jal_detect4 <= 1'b0;
		end
end

/////JR detection


always @ (posedge clk)
begin

	if (reset)
		begin 
		jr_detect<= 1'b0;
		jr_rise<= 1'b0;
		end
	
	if (opcode == 6'h11 && jump_reg == 5'h9 && jr_rise==1'b0)
		begin
		jr_detect<= 1'b1;
		jr_rise<= 1'b1;
		end
	else if ( opcode != 6'h11)
		begin
		jr_rise<= 1'b0;
		jr_detect<= 1'b0;
		end

	else 
		begin 
		jr_detect<= 1'b0;


		end
end
		

///////////////////

always @ (posedge clk)
begin

	if (reset)
		begin 
			obs_jal_o <= 1'b0;
		//	obs_jr_o <= 1'b0;
			obs_address_o <= 32'h00000000;
		end
	
	if (jr_rise==1'b1 && jr_detect==1'b1) 
		begin
		obs_address_o <= obs_address_i;
		//obs_jr_o <= 1'b1;
		obs_jal_o <= 1'b0;
		end
	else  if (jal_detect4==1'b1)
		begin
		obs_address_o <= obs_address_i;
		//obs_jr_o <= 1'b0;
		obs_jal_o <= 1'b1;
		end
	else
		begin
		//obs_jr_o <= 1'b0;
		obs_jal_o <= 1'b0;
	//obs_address_o <= obs_address_i;	
		end
		
end
assign obs_jr_o = jr_detect;

endmodule
