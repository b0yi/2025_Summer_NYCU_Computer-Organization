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
	
wire [31:0] alu_result;
wire [31:0] carry;
wire [1:0] operation;
wire Ainvert, Binvert, cin_initial;
wire set;

assign operation = ALU_control[1:0];
assign Ainvert = ALU_control[3];
assign Binvert = ALU_control[2];
assign cin_initial = Binvert;  // A - B = A + (~B +1)
assign set = src1[31] ^ (~src2[31]) ^ carry[31];




ALU_1bit alu_bit0(
    .src1(src1[0]),
    .src2(src2[0]),
    .less(set),      
    .Ainvert(Ainvert),
    .Binvert(Binvert),
    .cin(cin_initial),      
    .operation(operation),
    .result(alu_result[0]),
    .cout(carry[0])
);

genvar i;
generate
    for (i = 1; i < 32; i = i + 1) begin: alu_bits
        ALU_1bit alu_bit(
            .src1(src1[i]),
            .src2(src2[i]),
            .less(1'b0),           
            .Ainvert(Ainvert),
            .Binvert(Binvert),
            .cin(carry[i-1]),      
            .operation(operation),
            .result(alu_result[i]),
            .cout(carry[i])
        );
    end
endgenerate





always @(*) begin
    if (!rst_n) begin
        result = 32'b0;
        zero = 1'b0;
        cout = 1'b0;
        overflow = 1'b0;

    end else begin
        result = alu_result;
        zero = (alu_result == 32'b0);
        cout = 1'b0;
        overflow = 1'b0;
        
        if (operation == 2'b10) begin //ADD or SUB
			cout = carry[31];
            overflow = carry[31] ^ carry[30];
        end

    end
end
endmodule