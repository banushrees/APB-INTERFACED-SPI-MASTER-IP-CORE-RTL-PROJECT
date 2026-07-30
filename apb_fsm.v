module apb_fsm (
    input  wire       pclk,
    input  wire       preset_n,
    input  wire       psel,
    input  wire       penable,
    output reg  [1:0] state
);

    localparam IDLE   = 2'b00;
    localparam SETUP  = 2'b01;
    localparam ENABLE = 2'b10;

    reg [1:0] next_state;

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
                if (psel && !penable)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end

            SETUP: begin
                if (psel && penable)
                    next_state = ENABLE;
                else if (psel && !penable)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end
          
 ENABLE: begin
                if (psel)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule


