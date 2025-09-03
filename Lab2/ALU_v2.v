//Student ID: A133506
`timescale 1ns/1ps
`include "ALU_1bit.v"

module ALU(
    input                   rst_n,         
    input        [32-1:0]   src1,          
    input        [32-1:0]   src2,          
    input        [ 4-1:0]   ALU_control,   
    output reg   [32-1:0]   result,        
    output reg              zero,          
    output reg              cout,          
    output reg              overflow       
);

wire [31:0] alu_result_raw;  // 原始ALU結果
wire [31:0] carry;
wire [31:0] alu_result_final; // 最終結果（SLT修正後）

// 控制信號分解
wire [1:0] operation;
wire Ainvert, Binvert, cin_initial;

assign operation = ALU_control[1:0];
assign Ainvert = ALU_control[3];
assign Binvert = ALU_control[2];
assign cin_initial = Binvert;

// 最低位ALU - less輸入暫時設為0
ALU_1bit alu_bit0(
    .src1(src1[0]),
    .src2(src2[0]),
    .less(1'b0),            // 先設為0，稍後處理SLT
    .Ainvert(Ainvert),
    .Binvert(Binvert),
    .cin(cin_initial),
    .operation(operation),
    .result(alu_result_raw[0]),
    .cout(carry[0])
);

// 中間位ALU
genvar i;
generate
    for (i = 1; i < 31; i = i + 1) begin: alu_bits
        ALU_1bit alu_bit(
            .src1(src1[i]),
            .src2(src2[i]),
            .less(1'b0),
            .Ainvert(Ainvert),
            .Binvert(Binvert),
            .cin(carry[i-1]),
            .operation(operation),
            .result(alu_result_raw[i]),
            .cout(carry[i])
        );
    end
endgenerate

// 最高位ALU
ALU_1bit alu_bit31(
    .src1(src1[31]),
    .src2(src2[31]),
    .less(1'b0),
    .Ainvert(Ainvert),
    .Binvert(Binvert),
    .cin(carry[30]),
    .operation(operation),
    .result(alu_result_raw[31]),
    .cout(carry[31])
);

// SLT邏輯處理
wire slt_result;
wire slt_overflow = carry[31] ^ carry[30];
assign slt_result = slt_overflow ? ~alu_result_raw[31] : alu_result_raw[31];

// 根據運算類型選擇最終結果
assign alu_result_final[31:1] = (operation == 2'b11) ? 31'b0 : alu_result_raw[31:1];
assign alu_result_final[0] = (operation == 2'b11) ? slt_result : alu_result_raw[0];

// 輸出邏輯
always @(*) begin
    if (!rst_n) begin
        result = 32'b0;
        zero = 1'b0;
        cout = 1'b0;
        overflow = 1'b0;
    end else begin
        result = alu_result_final;
        zero = (alu_result_final == 32'b0);
        
        if (operation == 2'b10) begin  // ADD/SUB運算
            cout = carry[31];
            overflow = carry[31] ^ carry[30];
        end else begin
            cout = 1'b0;
            overflow = 1'b0;
        end
    end
end

endmodule