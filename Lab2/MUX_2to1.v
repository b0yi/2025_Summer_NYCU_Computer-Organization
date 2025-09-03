//Student ID: A133506
`timescale 1ns/1ps

module MUX_2to1(
	input      src1,
	input      src2,
	input	   select,
	output reg result
);


always @(*) begin
	case(select)
		1'b0: result = src1;
		1'b1: result = src2;
		default: result = 1'b0;
	endcase
end

endmodule