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

module monitor(
clk,
reset,
insn_i,
monitor_address_i,
r20_i,
waddr,
stack_violation,
interrupt,
fsm_state
    );

input clk;
input reset;
//input monitor_jal_i;
//input monitor_jr_i;

input [31:0] insn_i;
input [31:0] r20_i;
//input [31:0] address_i;

input [31:0] monitor_address_i;
input [4:0] waddr;

output stack_violation;
output interrupt;
output [2:0] fsm_state;

// Top module wires
wire clk;
wire reset;
wire monitor_jal_i;
wire monitor_jr_i;
wire [31:0] monitor_address_i;
wire [31:0] r20_i;
wire [4:0] waddr;

wire [31:0] insn_i;
wire [31:0] address_i;

wire stack_violation;
wire interrupt;
wire [2:0] fsm_state;

// Top module registers
reg interrupt_en;

// Internal wires
wire [31:0] data_fsmToStack;
wire [31:0] data_stackToFsm;
wire stack_push_pop;
wire stack_en;

always @ (posedge clk) begin
	if(r20_i == 32'hAAAAAAAA) begin
		interrupt_en <= 1'b1;
	end else begin
		interrupt_en <= 1'b0;
	end
end


stack stack(
    // Inputs
    .clk(clk),
    .en(stack_en),
    .reset(reset),
    .data_in(data_fsmToStack),
    .push_pop(stack_push_pop),

    // Outputs
    .data_out(data_stackToFsm),
    .stack_violation(stack_violation) );

fsm fsm(
    // Inputs
    .clk(clk),
    .reset(reset),
    .interrupt_en(interrupt_en),
//  .obs_jal(monitor_jal_i),
//  .obs_jr(monitor_jr_i),
    .obs_insn_i(insn_i),
//  .obs_address_i(address_i),
    .obs_address(monitor_address_i),
    .st_data_in(data_stackToFsm),
    .waddr(waddr),

    // Outputs
    .st_data_out(data_fsmToStack),
    .st_push_pop(stack_push_pop),
    .st_en(stack_en),
    .interrupt(interrupt),
    .current_state(fsm_state) );

endmodule
