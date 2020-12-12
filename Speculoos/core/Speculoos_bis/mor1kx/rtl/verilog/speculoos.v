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

module speculoos(
    clk,
    reset,
    waddr,
    r20_i,
    address_i,
    insn_i,
    stack_violation,
    interrupt,
    fsm_state
    );

// Port declaration
input clk;
input reset;
input [31:0] insn_i;
input [31:0] address_i;
input [31:0] r20_i;
input [4:0] waddr;

output stack_violation;
output interrupt;
output [4:0] fsm_state;

// Top module wires
wire clk;
wire reset;
wire [31:0] insn_i;
wire [31:0] address_i;
wire [31:0] r20_i;

wire stack_violation;
wire interrupt;
//wire interrupt1;

wire [2:0] fsm_state1;

// Top module registers

// Internal wires
wire obs_jal_o;
wire obs_jr_o;
wire [31:0] obs_address_o;
//assign interrupt=1'b0;
monitor monitor(
    // Inputs
    .clk                 (clk),
    .reset               (reset),
    .insn_i		 (insn_i),
    .r20_i		 (r20_i),
    .monitor_address_i   (address_i),
    .waddr		 (waddr),
    // Outputs
    .stack_violation     (stack_violation),
    .interrupt           (interrupt),
    .fsm_state           (fsm_state1) );

//observer observer(
//    // Inputs
//    .clk                 (clk),
//    .reset               (reset),
//    .obs_insn_i		 (insn_i),
//    .obs_address_i       (address_i),
//
//    // Outputs
//    .obs_jal_o           (obs_jal_o),
//    .obs_jr_o            (obs_jr_o),
//    .obs_address_o       (obs_address_o) );

endmodule
