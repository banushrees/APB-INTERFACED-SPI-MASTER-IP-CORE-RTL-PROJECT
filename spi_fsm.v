module spi_fsm (
    input  wire       pclk,
    input  wire       preset_n,
    input  wire       spe,
    input  wire       spiswai,
    output wire [1:0] spi_mode
);

localparam SPI_RUN  = 2'b00;
localparam SPI_WAIT = 2'b01;
localparam SPI_STOP = 2'b10;

reg [1:0] state;
reg [1:0] next_state;

assign spi_mode = state;

always @(posedge pclk or negedge preset_n) begin
    if (!preset_n)
        state <= SPI_RUN;
    else
        state <= next_state;
end

always @(*) begin

    next_state = state;

    case (state)

        SPI_RUN: begin
            if (!spe)
                next_state = SPI_WAIT;
            else
                next_state = SPI_RUN;
        end

        SPI_WAIT: begin
            if (spe)
                next_state = SPI_RUN;
            else if (spiswai)
                next_state = SPI_STOP;
            else
                next_state = SPI_WAIT;
        end

        SPI_STOP: begin
            if (spe)
                next_state = SPI_RUN;
            else if (!spiswai)
                next_state = SPI_WAIT;
            else
                next_state = SPI_STOP;
        end

        default: begin
            next_state = SPI_RUN;
        end

    endcase

end

endmodule
