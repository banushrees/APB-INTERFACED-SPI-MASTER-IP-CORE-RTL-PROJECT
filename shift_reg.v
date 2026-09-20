module shift_reg (

    input  wire       pclk,
    input  wire       preset_n,

    input  wire       ss,
    input  wire       send_data,

    input  wire       lsbfe,
    input  wire       cpha,
    input  wire       cpol,

    input  wire       miso_receive_sclk,
    input  wire       miso_receive_sclk0,

    input  wire       mosi_send_sclk,
    input  wire       mosi_send_sclk0,

    input  wire [7:0] data_mosi,
    input  wire       miso,

    input  wire       receive_data,

    output reg        mosi,

    output wire [7:0] data_miso
);


/*----------------------------------------------------------
 SHIFT REGISTERS
----------------------------------------------------------*/

reg [7:0] shift_reg;
reg [7:0] temp_reg;


/*----------------------------------------------------------
 TRANSMIT / RECEIVE COUNTERS
----------------------------------------------------------*/

reg [2:0] tx_count_up;
reg [2:0] tx_count_down;

reg [2:0] rx_count_up;
reg [2:0] rx_count_down;


/*----------------------------------------------------------
 SPI PULSES
----------------------------------------------------------*/

wire tx_pulse;
wire rx_pulse;

assign tx_pulse =
        mosi_send_sclk |
        mosi_send_sclk0;

assign rx_pulse =
        miso_receive_sclk |
        miso_receive_sclk0;


/*----------------------------------------------------------
 RECEIVED DATA
----------------------------------------------------------*/

assign data_miso =
        receive_data ? temp_reg : 8'b0;


/*----------------------------------------------------------
 SHIFT REGISTER
----------------------------------------------------------*/

always @(posedge pclk or negedge preset_n) begin

    if (!preset_n) begin

        shift_reg <= 8'h00;
        temp_reg  <= 8'h00;

        mosi <= 1'b0;

        tx_count_up   <= 3'd0;
        tx_count_down <= 3'd7;

        rx_count_up   <= 3'd0;
        rx_count_down <= 3'd7;

    end

    else begin

        /*----------------------------------------------
         Load transmit data
        ----------------------------------------------*/

        if (send_data) begin

            shift_reg <= data_mosi;

        end


        /*----------------------------------------------
         Slave not selected
        ----------------------------------------------*/

        else if (ss) begin

            mosi <= 1'b0;

            tx_count_up   <= 3'd0;
            tx_count_down <= 3'd7;

            rx_count_up   <= 3'd0;
            rx_count_down <= 3'd7;

        end


        /*----------------------------------------------
         SPI transfer
        ----------------------------------------------*/

        else begin


            /*------------------------------------------
             TRANSMIT
            ------------------------------------------*/

            if (tx_pulse) begin

                if (lsbfe) begin

                    mosi <= shift_reg[tx_count_up];

                    if (tx_count_up < 3'd7)
                        tx_count_up <= tx_count_up + 1'b1;

                end

                else begin

                    mosi <= shift_reg[tx_count_down];

                    if (tx_count_down > 3'd0)
                        tx_count_down <= tx_count_down - 1'b1;

                end

            end


            /*------------------------------------------
             RECEIVE
            ------------------------------------------*/

            if (rx_pulse) begin

                if (lsbfe) begin

                    temp_reg[rx_count_up] <= miso;

                    if (rx_count_up < 3'd7)
                        rx_count_up <= rx_count_up + 1'b1;

                end

                else begin

                    temp_reg[rx_count_down] <= miso;

                    if (rx_count_down > 3'd0)
                        rx_count_down <= rx_count_down - 1'b1;

                end

            end

        end

    end

end

endmodule
