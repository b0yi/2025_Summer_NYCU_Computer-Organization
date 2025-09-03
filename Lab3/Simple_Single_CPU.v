// student ID A133506
`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "Decoder.v"
`include "Sign_Extend.v"
`include "Shift_Left_Two_32.v"
`include "ProgramCounter.v"
`include "Instr_Memory.v"
`include "Reg_File.v"
`include "Data_Memory.v"

module Simple_Single_CPU(
    clk_i,
    rst_i
);

// I/O port
input       clk_i;
input       rst_i;
// Internal Signals
wire [31:0] pc_now, pc_next, instruction;
wire [4:0]  rs_addr, rt_addr, reg_dst_addr;
wire [31:0] rs_data, rt_data, write_data;
wire [3:0]  alu_ctrl;
wire [31:0] alu_operand2, alu_result;
wire [1:0]  alu_op, reg_dst, mem_to_reg, branch_type;
wire        alu_src, reg_write, jump, mem_read, mem_write;
wire [15:0] imm;
wire [31:0] sign_ext_imm, shift_branch, branch_addr;
wire [31:0] pc_plus4;
wire [31:0] mem_data_out;
wire        alu_zero;
wire        branch_en;
wire [31:0] jump_addr, next_pc_candidate;
wire        use_jr;
wire [31:0] jr_addr;

ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_in_i(pc_next),
    .pc_out_o(pc_now)
);

Instr_Memory IM(
    .pc_addr_i(pc_now),
    .instr_o(instruction)
);

Adder PCplus4(
    .src1_i(pc_now),
    .src2_i(32'd4),
    .sum_o(pc_plus4)
);

Decoder myDecoder(
    .instr_op_i(instruction[31:26]),
    .ALU_op_o(alu_op),
    .ALUSrc_o(alu_src),
    .RegWrite_o(reg_write),
    .RegDst_o(reg_dst),
    .Branch_o(branch_type),
    .Jump_o(jump),
    .MemRead_o(mem_read),
    .MemWrite_o(mem_write),
    .MemtoReg_o(mem_to_reg)
);

assign rs_addr = instruction[25:21];
assign rt_addr = instruction[20:16];

MUX_3to1 #(.size(5)) RegDst_mux(
    .data0_i(instruction[15:11]), // rd
    .data1_i(instruction[20:16]), // rt
    .data2_i(5'd31),              // $ra (for jal)
    .select_i(reg_dst),
    .data_o(reg_dst_addr)
);

// Register File
Reg_File Registers(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(rs_addr),
    .RTaddr_i(rt_addr),
    .RDaddr_i(reg_dst_addr),
    .RDdata_i(write_data),
    .RegWrite_i(reg_write),
    .RSdata_o(rs_data),
    .RTdata_o(rt_data)
);

// Sign Extend
assign imm = instruction[15:0];
Sign_Extend sign_ext(
    .data_i(imm),
    .data_o(sign_ext_imm)
);

// Shift left two (for branch offset)
Shift_Left_Two_32 sl2(
    .data_i(sign_ext_imm),
    .data_o(shift_branch)
);

// Branch Adder (target addr)
Adder branchAdder(
    .src1_i(pc_now),
    .src2_i(shift_branch),
    .sum_o(branch_addr)
);

// ALU control
ALU_Ctrl aluCtrl(
    .funct_i(instruction[5:0]),
    .ALUOp_i(alu_op),
    .ALUCtrl_o(alu_ctrl)
);

// ALU src_mux
MUX_2to1 #(.size(32)) ALUSrc_mux(
    .data0_i(rt_data),
    .data1_i(sign_ext_imm),
    .select_i(alu_src),
    .data_o(alu_operand2)
);

// is shamt ? (sll, srl)
wire is_shift_imm = (alu_ctrl == 4'b1000) || (alu_ctrl == 4'b1001);
wire is_shift_var = (alu_ctrl == 4'b1010) || (alu_ctrl == 4'b1011); // sllv, srlv
// shamt extend to 32 bit
wire [31:0] shamt_ext = {27'b0, instruction[10:6]};

// ALU src1
wire [31:0] alu_src1_final;
MUX_3to1 #(.size(32)) ALU_Src1_mux(
    .data0_i(rs_data),      // rs
    .data1_i(shamt_ext),    // sll/srl using shamt
    .data2_i(rs_data),      // sllv/srlv use rs
    .select_i({is_shift_var, is_shift_imm}), // 00=rs, 01=shamt, 10/11=rs
    .data_o(alu_src1_final)
);

// ALU src2
wire [31:0] alu_src2_final;
MUX_2to1 #(.size(32)) ALU_Src2_shift_mux(
    .data0_i(alu_operand2),  // normal
    .data1_i(rt_data),       // shift instru use rt
    .select_i(is_shift_imm | is_shift_var),
    .data_o(alu_src2_final)
);

// ALU
ALU myALU(
    .rst_n(rst_i),
    .src1(alu_src1_final),
    .src2(alu_src2_final),
    .ALU_control(alu_ctrl),
    .result(alu_result),
    .zero(alu_zero),
    .cout(),
    .overflow()
);

// Data Memory
Data_Memory Data_Memory(
    .clk_i(clk_i),
    .addr_i(alu_result),
    .data_i(rt_data),
    .MemRead_i(mem_read),
    .MemWrite_i(mem_write),
    .data_o(mem_data_out)
);

    
MUX_3to1 #(.size(32)) MemtoReg_mux(
    .data0_i(alu_result),
    .data1_i(mem_data_out),
    .data2_i(pc_plus4),
    .select_i(mem_to_reg),
    .data_o(write_data)
);



// （ beq: branch = 2'b01 & zero; bne: branch=2'b10 & !zero ）
assign branch_en = ((branch_type == 2'b01) && alu_zero) ||
                   ((branch_type == 2'b10) && !alu_zero);

// next PC for branch or normal
MUX_2to1 #(.size(32)) PC_beq_mux(
    .data0_i(pc_plus4),
    .data1_i(branch_addr),
    .select_i(branch_en),
    .data_o(next_pc_candidate)
);

// Jump target address (J-type: [pc_plus4[31:28], instr[25:0], 2'b00])
assign jump_addr = {pc_plus4[31:28], instruction[25:0], 2'b00};
// jr 
assign use_jr = (alu_ctrl == 4'b1111);
assign jr_addr = rs_data;

// final PC MUX（branch/jump/jr）
// MUX_3to1 select_i use {use_jr, jump} → 00=next_pc_candidate, 01=jump_addr, 10/11=jr_addr
MUX_3to1 #(.size(32)) PC_final_mux(
    .data0_i(next_pc_candidate), // normal or branch
    .data1_i(jump_addr),         // jump or jal
    .data2_i(jr_addr),           // jr
    .select_i({use_jr, jump}),
    .data_o(pc_next)
);

endmodule
