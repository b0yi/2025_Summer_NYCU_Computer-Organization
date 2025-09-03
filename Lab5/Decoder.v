// ID A133506
module Decoder( 
	instr_op_i, 
	ALUOp_o, 
	ALUSrc_o,
	RegWrite_o,	
	RegDst_o,
	Branch_o,
	MemRead_o, 
	MemWrite_o, 
	MemtoReg_o
);
     
// TO DO
input  [5:0] instr_op_i;

output reg [1:0] ALUOp_o;
output reg       RegDst_o, MemtoReg_o, Branch_o;
output reg       ALUSrc_o, RegWrite_o, MemRead_o, MemWrite_o;

always @(*) begin
	
    RegDst_o    = 0;
    MemtoReg_o  = 0;
    Branch_o    = 0;
    ALUSrc_o    = 0;
    RegWrite_o  = 0;
    MemRead_o   = 0;
    MemWrite_o  = 0;
    ALUOp_o    = 2'b00;

    case(instr_op_i)
        6'b000000: begin // R-type
            RegDst_o   = 1;
            RegWrite_o = 1;
            ALUOp_o   = 2'b10;
        end
        6'b001001: begin // addi
            ALUSrc_o   = 1;
            RegWrite_o = 1;
            ALUOp_o   = 2'b00;
        end
        6'b101100: begin // lw
            ALUSrc_o   = 1;
            MemtoReg_o = 1;
            RegWrite_o = 1;
            MemRead_o  = 1;
            ALUOp_o   = 2'b00;
        end
        6'b100100: begin // sw
            ALUSrc_o   = 1;
            MemWrite_o = 1;
            ALUOp_o   = 2'b00;
        end
        6'b000110: begin // beq
            Branch_o   = 1;
            ALUOp_o   = 2'b01;
        end
        6'b000101: begin // bne
            Branch_o   = 1;
            ALUOp_o   = 2'b01;
        end

        default: begin
            RegDst_o    = 0;
            MemtoReg_o  = 0;
            Branch_o    = 0;
            ALUSrc_o    = 0;
            RegWrite_o  = 0;
            MemRead_o   = 0;
            MemWrite_o  = 0;
            ALUOp_o    = 2'b00;
        end
    endcase
end

endmodule
