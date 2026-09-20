module baud_generator (

    input  wire       pclk,
    input  wire       preset_n,

    input  wire [1:0] spimode,
    input  wire       spiswai,

    input  wire [2:0] sppr,
    input  wire [2:0] spr,

    input  wire       cpol,
    input  wire       cpha,

    input  wire       ss,

    output reg        sclk,

    output reg        miso_receive_sclk,
    output reg        miso_receive_sclk0,

    output reg        mosi_send_sclk,
    output reg        mosi_send_sclk0,

    output wire [11:0] baudratedivisor
);


/*----------------------------------------------------------
 BAUD RATE DIVISOR
----------------------------------------------------------*/

assign baudratedivisor =
        (sppr + 1'b1) * (2 ** (spr + 1'b1));


/*----------------------------------------------------------
 IDLE SCLK LEVEL
----------------------------------------------------------*/

wire pre_sclk;

assign pre_sclk = cpol ? 1'b1 : 1'b0;


/*----------------------------------------------------------
 SPI ENABLE
----------------------------------------------------------*/

wire spi_enable;

assign spi_enable =
        (~ss) &&
        (
            (spimode == 2'b00) ||
            ((spimode == 2'b01) && (~spiswai))
        );


/*----------------------------------------------------------
 COUNTER
----------------------------------------------------------*/

reg [11:0] count;


/*----------------------------------------------------------
 BAUD GENERATOR
----------------------------------------------------------*/

always @(posedge pclk or negedge preset_n) begin

    if (!preset_n) begin

        sclk <= pre_sclk;

        count <= 12'd0;

        miso_receive_sclk  <= 1'b0;
        miso_receive_sclk0 <= 1'b0;

        mosi_send_sclk  <= 1'b0;
        mosi_send_sclk0 <= 1'b0;

    end

    else begin

        /* default pulse outputs */
        miso_receive_sclk  <= 1'b0;
        miso_receive_sclk0 <= 1'b0;

        mosi_send_sclk  <= 1'b0;
        mosi_send_sclk0 <= 1'b0;


        if (spi_enable) begin

            /*------------------------------------------------
             End of baud period
            ------------------------------------------------*/

            if (count == (baudratedivisor - 1'b1)) begin

                count <= 12'd0;


                /*--------------------------------------------
                 RECEIVE FLAG
                --------------------------------------------*/

                if (((~cpha) && cpol) ||
                    (cpha && (~cpol))) begin

                    if (sclk == 1'b1)
                        miso_receive_sclk <= 1'b1;

                end

                else begin

                    if (sclk == 1'b0)
                        miso_receive_sclk0 <= 1'b1;

                end


                /*--------------------------------------------
                 TOGGLE SCLK
                --------------------------------------------*/

                sclk <= ~sclk;

            end

            else begin

                count <= count + 1'b1;


                /*--------------------------------------------
                 TRANSMIT FLAG
                --------------------------------------------*/

                if (count == (baudratedivisor - 2)) begin

                    if (((~cpha) && cpol) ||
                        (cpha && (~cpol))) begin

                        if (sclk == 1'b0)
                            mosi_send_sclk <= 1'b1;

                    end

                    else begin

                        if (sclk == 1'b1)
                            mosi_send_sclk0 <= 1'b1;

                    end

                end

            end

        end

        else begin

            sclk <= pre_sclk;
            count <= 12'd0;
        end

    end

end

endmodule
