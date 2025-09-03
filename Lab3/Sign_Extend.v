// student ID A133506
module Sign_Extend(
    data_i,
    data_o
    );
               
// I/O ports
input   [16-1:0] data_i;

output  [32-1:0] data_o;

// Internal Signals
assign data_o = {{16{data_i[15]}}, data_i};

// Main function
/*always @(*) begin
    if(data_i[15] == 1'b1)
        data_o = {16'hFFFF, data_i};
    else
        data_o = {16'h0000, data_i};
end*/
          
endmodule      
     