module ysyx_23060184_InstMem(input [31:0] A,
               output reg [31:0] RD);

    import "DPI-C" function int pmem_read(input int raddr);

    assign RD = pmem_read(A);

endmodule //InstMem
