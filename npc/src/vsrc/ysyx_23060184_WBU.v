module ysyx_23060184_WBU (

    input                               clk,
    input                               rstn,
    input                               Mvalid,


    /*
        Mux_Result_Src Input Signals End
    */

    input [`RESULT_SRC_LENGTH - 1:0]    ResultSrc,
    input [`DATA_WIDTH - 1:0]           PCPlus4,
    input [`DATA_WIDTH - 1:0]           ALUResult,
    input [`DATA_WIDTH - 1:0]           ReadData,
    input [`DATA_WIDTH - 1:0]           CsrRead,

    /*
        Mux_Result_Src Input Signals End
    */

    /* --------------------------------------------- */

    // Output signals
    output reg                          Wready,
    output reg                          Wvalid,
    output reg [`DATA_WIDTH - 1:0]      Result
);

    always @ (posedge clk) begin
        if (~rstn) begin
            Wready <= 1;
            Wvalid <= 0;
        end 
    end

    always @ (posedge clk) begin
        if (Mvalid && Wready) begin
            Wready <= 0;
            Wvalid <= 1;
        end
    end

    always @ (posedge clk) begin
        if (Wvalid) begin
            Wready <= 1;
            Wvalid <= 0;
        end
    end

    ysyx_23060184_Mux_Result_Src Mux_Result_Src (
        .ResultSrc(ResultSrc),
        .PCPlus4(PCPlus4),
        .ALUResult(ALUResult),
        .ReadData(ReadData),
        .CsrRead(CsrRead),
        .Result(Result)
    );

endmodule