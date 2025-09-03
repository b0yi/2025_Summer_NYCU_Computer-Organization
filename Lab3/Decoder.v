// student ID A133506
module Decoder( 
	instr_op_i,
	ALU_op_o,
	ALUSrc_o,
	RegWrite_o,
	RegDst_o,
	Branch_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
);

// I/O ports
input	[6-1:0] instr_op_i;

output	[2-1:0] ALU_op_o;
output	[2-1:0] RegDst_o, MemtoReg_o;
output  [2-1:0] Branch_o;
output			ALUSrc_o, RegWrite_o, Jump_o, MemRead_o, MemWrite_o;

// Internal Signals
assign ALU_op_o    = (instr_op_i == 6'b000000) ? 2'b10 :   // R-type
                     (instr_op_i == 6'b000110) ? 2'b01 :   // beq
                     (instr_op_i == 6'b000101) ? 2'b01 :   // bne
                     2'b00;                                // other

assign RegDst_o    = (instr_op_i == 6'b000000) ? 2'b00 :   // R-type rd
                     (instr_op_i == 6'b000011) ? 2'b10 :   // jal $ra
                     2'b01;                                // I-type rt

assign MemtoReg_o  = (instr_op_i == 6'b101100) ? 2'b01 :   // lw from memory
                     (instr_op_i == 6'b000011) ? 2'b10 :   // jal PC+4
                     2'b00;                                // ALU result

assign Branch_o    = (instr_op_i == 6'b000110) ? 2'b01 :   // beq
                     (instr_op_i == 6'b000101) ? 2'b10 :   // bne
                     2'b00;
 
assign ALUSrc_o    = (instr_op_i == 6'b001001) ||          // addi
                     (instr_op_i == 6'b101100) ||          // lw
                     (instr_op_i == 6'b100100);            // sw
 
assign RegWrite_o  = (instr_op_i == 6'b000000) ||          // R-type
                     (instr_op_i == 6'b001001) ||          // addi
                     (instr_op_i == 6'b101100) ||          // lw
                     (instr_op_i == 6'b000011);            // jal

assign Jump_o      = (instr_op_i == 6'b000111) ||          // j
                     (instr_op_i == 6'b000011);            // jal

assign MemRead_o   = (instr_op_i == 6'b101100);            // lw

assign MemWrite_o = (instr_op_i == 6'b100100);             // sw


endmodule
                

