`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2020 10:16:28 AM
// Design Name: 
// Module Name: IF_pipe_stage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
// write your code here
    wire [9:0] j_mux_out;
    wire [9:0] br_mux_out;
    reg [9:0] pc_reg;
    
    mux2 #(.WIDTH(10)) brach_mux (
        .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(br_mux_out)
	);
        
    mux2 #(.WIDTH(10)) jump_mux (
        .a(br_mux_out),
        .b(jump_address),
        .sel(jump),
        .y(j_mux_out)
	);
    
    always @ (posedge clk) begin
        if (reset) begin
            pc_reg <=10'd0000000000;
        end else if(en == 0) begin
            pc_reg <= pc_reg;
        end 
        else begin
            pc_reg <= j_mux_out;
        end
    end
       
    assign pc_plus4 = pc_reg + 10'd4;
    instruction_mem IMEM(.read_addr(pc_reg), .data(instr));
    
endmodule
