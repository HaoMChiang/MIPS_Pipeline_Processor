`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2020 11:30:41 AM
// Design Name: 
// Module Name: EX_pipe_stage
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


module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    wire [3:0] alu_control_output;
    wire [31:0] id_ex_reg1_output;
    wire [31:0] imm_reg2_output;
    // Write your code here
    
    ALUControl aluControl (
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(alu_control_output));
        
    mux4 #(.WIDTH(32)) id_ex_reg1_mux (
       .a(reg1),
       .b(mem_wb_write_back_result),
       .c(ex_mem_alu_result),
       .d(0),												
       .sel(Forward_A),
       .y(id_ex_reg1_output));
       
    mux4 #(.WIDTH(32)) id_ex_reg2_mux (
       .a(reg2),
       .b(mem_wb_write_back_result),
       .c(ex_mem_alu_result),
       .d(0),												
       .sel(Forward_B),
       .y(alu_in2_out));

    mux2 #(.WIDTH(32)) imm_reg2_mux (
        .a(alu_in2_out),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),                     
        .y(imm_reg2_output));
    
    ALU ALU (
        .a(id_ex_reg1_output),
        .b(imm_reg2_output),
        .alu_control(alu_control_output),
        .zero(),												
        .alu_result(alu_result));
    
       
endmodule
