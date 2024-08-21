module ysyx_23060184_Xbar (
    input [`DATA_WIDTH - 1:0]         raddr,
    output                            clint
);
    // ToDo: 0 -- SoC, 1 -- CLINT  

    assign clint = (raddr >= `CLINT_ADDR_BEGIN) ? 
                    (raddr <= `CLINT_ADDR_END) ? 1 : 0 : 0;

endmodule