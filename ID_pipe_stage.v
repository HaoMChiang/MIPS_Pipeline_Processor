`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2020 10:37:51 AM
// Design Name: 
// Module Name: ID_pipe_stage
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


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,                
    input  [4:0] mem_wb_write_reg_addr,     
    input  [31:0] mem_wb_write_back_data,   
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    wire [31:0] shift_left_two;
    wire result_equal_test;
    wire branch;                        
    wire hazard_output;
    wire mem_to_reg_control, mem_read_control, mem_write_control, alu_src_control, reg_write_control, reg_dest;
    wire [1:0] alu_op_control;
    
    wire [4:0] instr1 ,instr2;
    assign instr1 = instr[25:21];
    assign instr2 = instr[20:16];
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage.
    register_file id_reg (
        .clk(clk),
        .reset(reset),
        .reg_write_en(mem_wb_reg_write),
        .reg_write_dest(mem_wb_write_reg_addr),
        .reg_write_data(mem_wb_write_back_data),
        .reg_read_addr_1(instr1), 
        .reg_read_addr_2(instr2),  
        .reg_read_data_1(reg1),  
        .reg_read_data_2(reg2));
        
     mux2 #(.WIDTH(5)) dest_mux (
        .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dest),                     
        .y(destination_reg));
        
     sign_extend sign_ex_inst (
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value));
     
     control control_id (
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(reg_dest),
        .mem_to_reg(mem_to_reg_control),
        .alu_op(alu_op_control),
        .mem_read(mem_read_control),
        .mem_write(mem_write_control),
        .alu_src(alu_src_control),
        .reg_write(reg_write_control),
        .branch(branch),
        .jump(jump));
     
     mux2 #(.WIDTH(1)) hazard_mux_memToReg (
        .a(mem_to_reg_control),
        .b(1'b0),
        .sel(hazard_output),
        .y(mem_to_reg));
        
     mux2 #(.WIDTH(2)) hazard_mux_aluOP (
        .a(alu_op_control),
        .b(2'b00),
        .sel(hazard_output),
        .y(alu_op));
        
     mux2 #(.WIDTH(1)) hazard_mux_memRead (
        .a(mem_read_control),
        .b(1'b0),
        .sel(hazard_output),
        .y(mem_read));
        
     mux2 #(.WIDTH(1)) hazard_mux_aluSrc (
        .a(alu_src_control),
        .b(1'b0),
        .sel(hazard_output),
        .y(alu_src));
        
     mux2 #(.WIDTH(1)) hazard_mux_memWrite (
        .a(mem_write_control),
        .b(1'b0),
        .sel(hazard_output),
        .y(mem_write));
        
     mux2 #(.WIDTH(1)) hazard_mux_regWrite (
        .a(reg_write_control),
        .b(1'b0),
        .sel(hazard_output),
        .y(reg_write));
        
     assign shift_left_two = imm_value << 2;
     assign branch_address = pc_plus4 + shift_left_two[9:0];			
     assign jump_address = instr[25:0] << 2;                            
     assign result_equal_test = ((reg1 ^ reg2) == 32'd0) ? 1'b1 : 1'b0;
     assign branch_taken = branch & result_equal_test;
     assign hazard_output = Control_Hazard | (~Data_Hazard);
           
endmodule
