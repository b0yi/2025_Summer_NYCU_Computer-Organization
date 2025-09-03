// ID A133506
module Forwarding_Unit(
    regwrite_mem,
    regwrite_wb,
    idex_regs,
    idex_regt,
    exmem_regd,
    memwb_regd,
    forwarda,
    forwardb
);
    input regwrite_mem;
    input regwrite_wb;
    input [4:0] idex_regs;
    input [4:0] idex_regt;
    input [4:0] exmem_regd;
    input [4:0] memwb_regd;
    output reg [1:0] forwarda;
    output reg [1:0] forwardb;

    always @(*) begin
        // ForwardA
        if (regwrite_mem && (exmem_regd != 0) && (exmem_regd == idex_regs)) begin
            forwarda = 2'b10;
        end else if (
            regwrite_wb && (memwb_regd != 0) && (memwb_regd == idex_regs) &&
            !(regwrite_mem && (exmem_regd != 0) && (exmem_regd == idex_regs))
        ) begin
            forwarda = 2'b01;
        end else begin
            forwarda = 2'b00;
        end

        // ForwardB
        if (regwrite_mem && (exmem_regd != 0) && (exmem_regd == idex_regt)) begin
            forwardb = 2'b10;
        end else if (
            regwrite_wb && (memwb_regd != 0) && (memwb_regd == idex_regt) &&
            !(regwrite_mem && (exmem_regd != 0) && (exmem_regd == idex_regt))
        ) begin
            forwardb = 2'b01;
        end else begin
            forwardb = 2'b00;
        end
    end
endmodule