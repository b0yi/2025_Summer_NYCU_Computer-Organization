// ID A133506

`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Forwarding_Unit.v"
`include "Hazard_Detection.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "Reg_File.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"

`timescale 1ns / 1ps

module Pipe_CPU_PRO(
    clk_i,
    rst_i
    );

input clk_i;
input rst_i;

// Internal signal

// IF stage
wire [31:0] pc_in_i, pc_out_o;
wire [31:0] instr_o;
wire [31:0] pc_add4;
wire pcwrite, ifid_write, ifid_flush;
wire [31:0] IFID_pc_out, IFID_instr;

// ID stage
wire [31:0] reg1_data, reg2_data;
wire [31:0] sign_ext_o;
wire RegWrite_raw, Branch_raw, MemRead_raw, MemtoReg_raw, MemWrite_raw, ALUSrc_raw, RegDst_raw;
wire [1:0] ALUOp_raw;
wire RegWrite, MemRead, MemtoReg, MemWrite, ALUSrc, RegDst;
wire [1:0] ALUOp;

wire idex_flush, exmem_flush;
wire [4:0] rs, rt;
assign rs = IFID_instr[25:21];
assign rt = IFID_instr[20:16];

// ID/EX Pipeline Register
wire [31:0] IDEX_pc_out, IDEX_reg1_data, IDEX_reg2_data, IDEX_sign_ext;
wire [4:0] IDEX_rs, IDEX_rt, IDEX_rd;
wire [5:0] IDEX_opcode;
wire [5:0] IDEX_funct;
wire IDEX_RegWrite, IDEX_Branch, IDEX_MemRead, IDEX_MemtoReg, IDEX_MemWrite, IDEX_ALUSrc, IDEX_RegDst;
wire [1:0] IDEX_ALUOp;
wire IDEX_RegWrite_raw, IDEX_Branch_raw, IDEX_MemRead_raw, IDEX_MemtoReg_raw, IDEX_MemWrite_raw, IDEX_ALUSrc_raw, IDEX_RegDst_raw;
wire [1:0] IDEX_ALUOp_raw;

wire [1:0] forwarda, forwardb;
wire [31:0] alu_src1, alu_src2_fwd;
// EX stage
wire [31:0] alu_src2;
wire [31:0] alu_result;
wire alu_zero;
wire [3:0] alu_ctrl;
wire [31:0] branch_addr, branch_target;
wire [4:0] reg_dst_addr;
wire branch_taken;

// EX/MEM Pipeline Register
wire [31:0] EXMEM_branch_addr, EXMEM_alu_result, EXMEM_reg2_data;
wire [4:0] EXMEM_reg_dst_addr;
wire [5:0] EXMEM_opcode;
wire EXMEM_RegWrite, EXMEM_Branch, EXMEM_MemRead, EXMEM_MemtoReg, EXMEM_MemWrite;
wire EXMEM_alu_zero;

// MEM stage
wire [31:0] mem_data;
wire pc_src;

// MEM/WB Pipeline Register
wire [31:0] MEMWB_mem_data, MEMWB_alu_result;
wire [4:0] MEMWB_reg_dst_addr;
wire MEMWB_RegWrite, MEMWB_MemtoReg;

// WB stage
wire [31:0] write_data;

// Components

// Components in IF stage
Adder Add_PC(
    .src1_i(pc_out_o),
    .src2_i(32'd4),
    .sum_o(pc_add4)
);

MUX_2to1 #(.size(32)) PC_Source(
    .data0_i(pc_add4),
    .data1_i(EXMEM_branch_addr),
    .select_i(pc_src),
    .data_o(pc_in_i)
);

ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_in_i(pc_in_i),
    .pc_out_o(pc_out_o),
    .pc_write(pcwrite)
);

Instruction_Memory IM(
    .addr_i(pc_out_o),
    .instr_o(instr_o)
);

// IF/ID Pipeline Register
Pipe_Reg #(.size(64)) IF_ID(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i({pc_out_o, instr_o}),
    .data_o({IFID_pc_out, IFID_instr}),
    .write(ifid_write),
    .flush(ifid_flush)
);

// Components in ID stage

Hazard_Detection HD(
    .memread(IDEX_MemRead),
    .instr_i(IFID_instr),
    .idex_regt(IDEX_rt),
    .branch(Branch_raw), 
    .pcwrite(pcwrite),
    .ifid_write(ifid_write),
    .ifid_flush(ifid_flush),
    .idex_flush(idex_flush),
    .exmem_flush(exmem_flush) 
);

Decoder Control(
    .instr_op_i(IFID_instr[31:26]),
    .RegWrite_o(RegWrite_raw),
    .ALUOp_o(ALUOp_raw),
    .ALUSrc_o(ALUSrc_raw),
    .RegDst_o(RegDst_raw),
    .Branch_o(Branch_raw),
    .MemRead_o(MemRead_raw),
    .MemWrite_o(MemWrite_raw),
    .MemtoReg_o(MemtoReg_raw)
);

// ID Flush MUX - When a bubble is needed, output all 0s (NOP)
assign RegWrite = idex_flush ? 1'b0 : RegWrite_raw;
assign MemRead  = idex_flush ? 1'b0 : MemRead_raw;
assign MemtoReg = idex_flush ? 1'b0 : MemtoReg_raw;
assign MemWrite = idex_flush ? 1'b0 : MemWrite_raw;
assign ALUSrc   = idex_flush ? 1'b0 : ALUSrc_raw;
assign RegDst   = idex_flush ? 1'b0 : RegDst_raw;
assign ALUOp    = idex_flush ? 2'b00 : ALUOp_raw;


Reg_File RF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(IFID_instr[25:21]),
    .RTaddr_i(IFID_instr[20:16]),
    .RDaddr_i(MEMWB_reg_dst_addr),
    .RDdata_i(write_data),
    .RegWrite_i(MEMWB_RegWrite),
    .RSdata_o(reg1_data),
    .RTdata_o(reg2_data)
);

Sign_Extend SE(
    .data_i(IFID_instr[15:0]),
    .data_o(sign_ext_o)
);

// ID/EX Pipeline Register
Pipe_Reg #(.size(164)) ID_EX(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .flush(1'b0), 
    .write(1'b1), 
    .data_i({IFID_pc_out, reg1_data, reg2_data, sign_ext_o, IFID_instr[31:26], IFID_instr[25:21], IFID_instr[20:16], IFID_instr[15:11], IFID_instr[5:0], RegWrite_raw, Branch_raw, MemRead_raw, MemtoReg_raw, MemWrite_raw, ALUSrc_raw, RegDst_raw, ALUOp_raw}),
    .data_o({IDEX_pc_out, IDEX_reg1_data, IDEX_reg2_data, IDEX_sign_ext, IDEX_opcode, IDEX_rs, IDEX_rt, IDEX_rd, IDEX_funct, IDEX_RegWrite_raw, IDEX_Branch_raw, IDEX_MemRead_raw, IDEX_MemtoReg_raw, IDEX_MemWrite_raw, IDEX_ALUSrc_raw, IDEX_RegDst_raw, IDEX_ALUOp_raw})
);

// Components in EX stage
assign IDEX_RegWrite = IDEX_RegWrite_raw;
assign IDEX_Branch   = IDEX_Branch_raw;
assign IDEX_MemRead  = IDEX_MemRead_raw;
assign IDEX_MemtoReg = IDEX_MemtoReg_raw;
assign IDEX_MemWrite = IDEX_MemWrite_raw;
assign IDEX_ALUSrc   = IDEX_ALUSrc_raw;
assign IDEX_RegDst   = IDEX_RegDst_raw;
assign IDEX_ALUOp    = IDEX_ALUOp_raw;


Shift_Left_Two_32 Shift(
    .data_i(IDEX_sign_ext),
    .data_o(branch_target)
);

Adder Add_Branch(
    .src1_i(IDEX_pc_out),
    .src2_i(branch_target),
    .sum_o(branch_addr)
);

// Forwarding MUX for ALU src1
MUX_3to1 #(.size(32)) MUXA(
    .data0_i(IDEX_reg1_data),
    .data1_i(write_data),
    .data2_i(EXMEM_alu_result),
    .select_i(forwarda),
    .data_o(alu_src1)
);

// Forwarding MUX for ALU src2
MUX_3to1 #(.size(32)) MUXB(
    .data0_i(IDEX_reg2_data),
    .data1_i(write_data),
    .data2_i(EXMEM_alu_result),
    .select_i(forwardb),
    .data_o(alu_src2_fwd)
);

MUX_2to1 #(.size(32)) ALU_Src2_Mux(
    .data0_i(alu_src2_fwd),
    .data1_i(IDEX_sign_ext),
    .select_i(IDEX_ALUSrc),
    .data_o(alu_src2)
);

ALU ALU_Unit(
    .src1_i(alu_src1),
    .src2_i(alu_src2),
    .ctrl_i(alu_ctrl),
    .result_o(alu_result),
    .zero_o(alu_zero)
);

ALU_Ctrl ALU_Control(
    .funct_i(IDEX_funct), 
    .ALUOp_i(IDEX_ALUOp),
    .ALUCtrl_o(alu_ctrl)
);

MUX_2to1 #(.size(5)) Reg_Dst_Mux(
    .data0_i(IDEX_rt),
    .data1_i(IDEX_rd),
    .select_i(IDEX_RegDst),
    .data_o(reg_dst_addr)
);

Forwarding_Unit FU(
    .regwrite_mem(EXMEM_RegWrite),
    .regwrite_wb(MEMWB_RegWrite),
    .idex_regs(IDEX_rs),
    .idex_regt(IDEX_rt),
    .exmem_regd(EXMEM_reg_dst_addr),
    .memwb_regd(MEMWB_reg_dst_addr),
    .forwarda(forwarda),
    .forwardb(forwardb)
);

// EX/MEM Pipeline Register
Pipe_Reg #(.size(113)) EX_MEM(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .flush(1'b0), 
    .write(1'b1),
    .data_i({branch_addr, alu_result, alu_src2_fwd, IDEX_opcode, reg_dst_addr, IDEX_RegWrite, IDEX_Branch, IDEX_MemRead, IDEX_MemtoReg, IDEX_MemWrite, alu_zero}),
    .data_o({EXMEM_branch_addr, EXMEM_alu_result, EXMEM_reg2_data, EXMEM_opcode, EXMEM_reg_dst_addr, EXMEM_RegWrite, EXMEM_Branch, EXMEM_MemRead, EXMEM_MemtoReg, EXMEM_MemWrite, EXMEM_alu_zero})
);

// Components in MEM stage
assign branch_taken = EXMEM_Branch & ((EXMEM_opcode == 6'b000100) ? EXMEM_alu_zero : ~EXMEM_alu_zero);
assign pc_src = branch_taken;

Data_Memory DM(
    .clk_i(clk_i),
    .addr_i(EXMEM_alu_result),
    .data_i(EXMEM_reg2_data),
    .MemRead_i(EXMEM_MemRead),
    .MemWrite_i(EXMEM_MemWrite),
    .data_o(mem_data)
);

// MEM/WB Pipeline Register
Pipe_Reg #(.size(71)) MEM_WB(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .flush(1'b0),
    .write(1'b1),
    .data_i({mem_data, EXMEM_alu_result, EXMEM_reg_dst_addr, EXMEM_RegWrite, EXMEM_MemtoReg}),
    .data_o({MEMWB_mem_data, MEMWB_alu_result, MEMWB_reg_dst_addr, MEMWB_RegWrite, MEMWB_MemtoReg})
);

// Components in WB stage
MUX_2to1 #(.size(32)) Write_Data_Mux(
    .data0_i(MEMWB_alu_result),
    .data1_i(MEMWB_mem_data),
    .select_i(MEMWB_MemtoReg),
    .data_o(write_data)
);

endmodule