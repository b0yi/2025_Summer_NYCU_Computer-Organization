// ID A133506
module Hazard_Detection(
    memread,
    instr_i,
    idex_regt,
    branch,
    pcwrite,
    ifid_write,
    ifid_flush,
    idex_flush,
    exmem_flush
);
    input memread;
    input [31:0] instr_i;
    input [4:0] idex_regt;
    input branch;
    output reg pcwrite;
    output reg ifid_write;
    output reg ifid_flush;
    output reg idex_flush;
    output reg exmem_flush;

    wire [4:0] rs, rt;
    assign rs = instr_i[25:21];
    assign rt = instr_i[20:16];

    always @(*) begin
        // load-use hazard
        if (memread && ((idex_regt == rs) || (idex_regt == rt))) begin
            pcwrite    = 0;
            ifid_write = 0;
            ifid_flush = 0;
            idex_flush = 1;
            exmem_flush= 0;
        // branch hazard
        end else if (branch) begin
            pcwrite    = 1;
            ifid_write = 1;
            ifid_flush = 1;
            idex_flush = 0;
            exmem_flush= 0;
        end else begin
            pcwrite    = 1;
            ifid_write = 1;
            ifid_flush = 0;
            idex_flush = 0;
            exmem_flush= 0;
        end
    end
endmodule