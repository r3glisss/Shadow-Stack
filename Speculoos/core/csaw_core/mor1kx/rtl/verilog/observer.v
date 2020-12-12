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
// Module Name: Observer
// Project Name: CSAW_ESC_2016_Speculoos
// Target Devices: De0_nano
// Description: Observer
// 
// Dependencies: master=>speculoos.v slave=>monitor.v
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

    reg obs_jal_o = 1'b0;
    wire obs_jr_o;

// Registers
    reg [31:0] obs_address_o = 32'h0;

// Intern wires
    wire [5:0] opcode;
    assign opcode = obs_insn_i[31:26];
    wire [4:0] I_jal;
    assign I_jal = obs_insn_i[25:21];
    wire [4:0] rA;
    assign rA = obs_insn_i[20:16];
    wire [4:0] rB;
    assign rB = obs_insn_i[15:11];
    wire [4:0] rD;
    assign rD = obs_insn_i[25:21];
    wire [15:0] I_jr;
    assign I_jr = obs_insn_i[15:0];

// Intern registers
    reg jal_first = 1'b0;

    reg jal_rise = 1'b0;
    reg jal_detect = 1'b0;
    reg jal_detect2 = 1'b0;
    //reg jal_detect3 = 1'b0;

    reg jr_rise = 1'b0;
    reg jr_detect = 1'b0;
    reg jr_confirm = 1'b0;

// jal detection
always @ (posedge clk)
begin
	if (reset)
	begin
		jal_detect <= 1'b0; 
		jal_rise<= 1'b0;
	end

	if (opcode == 6'h1  && I_jal == 5'h0 && rA == 5'h0 && rB == 5'h0 && jal_rise == 1'b0) // l.jal (function) detection (voir photo)
	begin
		jal_rise <= 1'b1;
	end
	else if (opcode == 6'h5 && rA == 5'h0 && rB == 5'h0 && jal_rise == 1'b1) // (voir photo) 
 	begin
		jal_rise <= 1'b0;
		jal_detect <= 1'b1;
	end
	else if ((opcode != 6'h5 && rA != 5'h0 && rB != 5'h0) && jal_rise == 1'b1)
	begin
		jal_rise <= 1'b0;
	end
	else if (jal_rise == 1'b0)
	begin
		jal_detect <= 1'b0;
	end
end

// jr detection
always @ (posedge clk)
begin

	if (reset)
	begin 
		jr_detect <= 1'b0;
		jr_rise <= 1'b0;
	end
	
	if ((opcode == 6'h21 && rD == 5'h2 && rA == 5'h1 && I_jr == 16'b1111111111111000 && jr_rise == 1'b0) || (opcode == 6'h27 && rD == 5'h1 && rA == 5'h1 && I_jr == 16'hC)) // l.lwz r2, -8(r1) or l.addi r1, r1, 12 detection
	begin
		jr_rise <= 1'b1;
	end 
	else if (opcode == 6'h21 && rD == 5'h9 && rA == 5'h1 && I_jr == 16'b1111111111111100 && jr_rise == 1'b1) // l.lwz r9,-4(r1) detection
	begin
		jr_rise <= 1'b0;
		jr_detect <= 1'b1;
	end
	else if ((opcode != 6'h21 || rD != 5'h9 || rA != 5'h1 || I_jr != 16'b1111111111111100) && jr_rise == 1'b1)
	begin
		jr_rise <= 1'b0;
	end
	else if (opcode == 6'h11 && rB == 5'h9 && jr_detect == 1'b1) // l.jr r9 detection
	begin
		jr_detect <= 1'b0;
		jr_confirm <= 1'b1;
	end
	else if ((opcode != 6'h11 || rB != 5'h9) && jr_detect == 1'b1)
	begin
		jr_detect <= 1'b0;
	end
	else if (jr_detect == 1'b0)
	begin 
		jr_confirm <= 1'b0;
	end


/*
	if (opcode == 6'h21 && rD == 5'h9 && rA == 5'h1 && I_jr == 16'b1111111111111100 && jr_rise == 1'b0) // l.lwz r9,-4(r1) detection
	begin
		jr_rise <= 1'b1;
	end
	else if (opcode == 6'h11 && rB == 5'h9 && jr_rise == 1'b1) // l.jr r9 detection
	begin
		jr_rise <= 1'b0;
		jr_detect <= 1'b1;
	end
	else if (opcode != 6'h11 && rB != 5'h9 && jr_rise == 1'b1)
	begin
		jr_rise <= 1'b0;
	end
	else if (opcode == 6'h21 && rD == 5'h1 && rA == 5'h1 && I_jr == 16'b1111111111111000 && jr_detect == 1'b1) //l.lwz r1,-8(r1) detection
	begin
		jr_detect <= 1'b0;
		jr_confirm <= 1'b1;
	end
	else if (opcode != 6'h21 && rD == 5'h1 && rA != 5'h1 && I_jr != 16'b1111111111111000 && jr_detect == 1'b1)
	begin
		jr_detect <= 1'b0;
	end
	else if (jr_detect == 1'b0)
	begin 
		jr_confirm <= 1'b0;
	end */
end

// jal 1 clock delay
always @ (posedge clk)
begin
	if (reset)
	begin
		jal_detect2 <= 1'b0;		 
	end
	 
	if (jal_detect==1'b1 && jal_first==1'b0) 
	begin
		jal_first <= 1'b1;
	end
	else if (jal_detect==1'b1 && jal_first==1'b1) 
	begin
		jal_detect2 <= 1'b1;
	end	
	else 
	begin
		jal_detect2 <= 1'b0;
	end
end

// jal final delay
always @ (posedge clk)
begin
	if (reset)
	begin
		obs_jal_o <= 1'b0;
	end
	 
	if (jal_detect2==1'b1) 
	begin
		obs_jal_o <= 1'b1;
	end
	else 
	begin
		obs_jal_o <= 1'b0;
	end
end

/*
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
*/

assign obs_jr_o = jr_confirm;

endmodule
