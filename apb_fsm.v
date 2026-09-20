   module apb_fsm (
    input  wire       pclk,
    input  wire       preset_n,
    input  wire       psel,
    input  wire       penable,
    output wire [1:0] apb_state
);

localparam IDLE     = 2'b00;
localparam SETUP    = 2'b01;
localparam ENABLE_S = 2'b10;

reg [1:0] state;
reg [1:0] next_state;

assign apb_state = state;

always @(posedge pclk or negedge preset_n) begin
    if (!preset_n)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin

    next_state = state;

    case (state)

        IDLE: begin
            if (psel)
                next_state = SETUP;
            else
                next_state = IDLE;
        end

        SETUP: begin
            if (psel && penable)
                next_state = ENABLE_S;
            else if (!psel)
                next_state = IDLE;
            else
                next_state = SETUP;
        end

        ENABLE_S: begin
            if (psel && penable)
                next_state = ENABLE_S;
            else if (psel && !penable)
                next_state = SETUP;
            else
                next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end

    endcase

end

endmodule
