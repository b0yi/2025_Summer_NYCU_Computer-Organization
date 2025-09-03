//Student ID: A133506
`timescale 1ns/1ps
`include "ALU_1bit.v"
module ALU(
	input                   rst_n,         // negative reset            (input)
	input	     [32-1:0]	src1,          // 32 bits source 1          (input)
	input	     [32-1:0]	src2,          // 32 bits source 2          (input)
	input 	     [ 4-1:0] 	ALU_control,   // 4 bits ALU control input  (input)
	output reg   [32-1:0]	result,        // 32 bits result            (output)
	output reg              zero,          // 1 bit when the output is 0, zero must be set (output)
	output reg              cout,          // 1 bit carry out           (output)
	output reg              overflow       // 1 bit overflow            (output)
	);

wire less = 0;
wire [31:0] carry_out, alu_res;
wire A31, B31;
wire [4:0] shift_amount = src2[4:0]; 
reg [31:0] shift_result;

assign A31 = (ALU_control[3]) ? ~src1[31] : src1[31];
assign B31 = (ALU_control[2]) ? ~src2[31] : src2[31];

ALU_1bit bit0(src1[0], src2[0], A31 ^ B31 ^ carry_out[30], ALU_control[3], ALU_control[2], ALU_control[2], ALU_control[1:0], alu_res[0], carry_out[0]);
ALU_1bit bit31to1[31:1](src1[31:1], src2[31:1], less, ALU_control[3], ALU_control[2], carry_out[30:0], ALU_control[1:0], alu_res[31:1], carry_out[31:1]);


always @(*) begin
    case (ALU_control)
        4'b1000: shift_result = src2 << src1[4:0];  // sll 
        4'b1001: shift_result = src2 >> src1[4:0];  // srl   
        4'b1010: shift_result = src2 << src1[4:0];  // sllv 
        4'b1011: shift_result = src2 >> src1[4:0];  // srlv 
    endcase
end

always@ (*) begin
    cout = 1'b0;
    overflow = 1'b0;
    if (ALU_control == 4'b1000 || ALU_control == 4'b1001 || 
        ALU_control == 4'b1010 || ALU_control == 4'b1011) begin
        result = shift_result;
    end else begin
        //origin ALU
        result = alu_res;
        
        if (ALU_control[1:0] == 2'b10) begin    
            cout = carry_out[31];
            overflow = carry_out[31] ^ carry_out[30];
        end    
    end
	zero = (result == 32'b0)? 1'b1 : 1'b0;
end
endmodule