// ID A133506
module ALU_Ctrl(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);
          
// TO DO
input      [5:0] funct_i;
input      [1:0] ALUOp_i;
output reg [3:0] ALUCtrl_o;

always @(*) begin
    case(ALUOp_i)
        2'b00: ALUCtrl_o = 4'b0010; // add (lw, sw, addi)
        2'b01: ALUCtrl_o = 4'b0110; // sub (beq, bne)
        2'b10: begin 
            case(funct_i)
                6'b100011: ALUCtrl_o = 4'b0010; // add
                6'b100001: ALUCtrl_o = 4'b0110; // sub
                6'b100110: ALUCtrl_o = 4'b0000; // and
                6'b100101: ALUCtrl_o = 4'b0001; // or
                6'b101011: ALUCtrl_o = 4'b1100; // nor
                6'b101000: ALUCtrl_o = 4'b0111; // slt
                default:   ALUCtrl_o = 4'b0000;
            endcase
        end
        default: ALUCtrl_o = 4'b0000;
    endcase
end

endmodule
