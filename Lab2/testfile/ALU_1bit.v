//Student ID: A133506
`timescale 1ns/1ps
`include "MUX_2to1_ALU.v"
`include "MUX_4to1.v"

module ALU_1bit(
	input				src1,       //1 bit source 1  (input)
	input				src2,       //1 bit source 2  (input)
	input				less,       //1 bit less      (input)
	input 				Ainvert,    //1 bit A_invert  (input)
	input				Binvert,    //1 bit B_invert  (input)
	input 				cin,        //1 bit carry in  (input)
	input 	    [2-1:0] operation,  //2 bit operation (input)
	output reg          result,     //1 bit result    (output)
	output reg          cout        //1 bit carry out (output)
);
		
wire processed_a, processed_b;
wire logic_and, logic_or;
wire adder_sum;
wire adder_carry;

MUX_2to1_ALU mux_a(
	.src1(src1),
    .src2(~src1),
    .select(Ainvert),
    .result(processed_a)
);

MUX_2to1_ALU mux_b(
    .src1(src2),
    .src2(~src2),
    .select(Binvert),
    .result(processed_b)
);

assign logic_and = processed_a & processed_b;
assign logic_or = processed_a | processed_b;
assign adder_sum = processed_a ^ processed_b ^ cin;
assign adder_carry = (processed_a & processed_b) | (processed_a & cin) | (processed_b & cin);


always @(*) begin

	case(operation)
		2'b00: result = logic_or;
		2'b01: result = logic_and;
		2'b10: result = adder_sum;
		2'b11: result = less;
		default: result = 1'b0;
	endcase

	cout = adder_carry;
end
	
endmodule