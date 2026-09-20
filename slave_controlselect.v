module slave_controlselect (

    input  wire        pclk,
    input  wire        preset_n,

    input  wire        mstr,
    input  wire        spiswai,

    input  wire [1:0]  spimode,

    input  wire        send_data,

    input  wire [11:0] baudratedivisor,

    output reg         receive_data,
    output reg         ss,

    output wire        tip
);


/*----------------------------------------------------------
 TARGET COUNT
----------------------------------------------------------*/

wire [15:0] target;

assign target = baudratedivisor * 16;


/*----------------------------------------------------------
 SPI ENABLE
----------------------------------------------------------*/

wire spi_enable;

assign spi_enable =
        (mstr == 1'b1) &&
        (
            (spimode == 2'b00) ||
            ((spimode == 2'b01) && (~spiswai))
        );


/*----------------------------------------------------------
 TIP
----------------------------------------------------------*/

assign tip = ~ss;


/*----------------------------------------------------------
 COUNTER
----------------------------------------------------------*/

reg [15:0] count;


/*----------------------------------------------------------
 SLAVE SELECT CONTROL
----------------------------------------------------------*/

always @(posedge pclk or negedge preset_n) begin

    if (!preset_n) begin

        receive_data <= 1'b0;
        ss           <= 1'b1;
        count        <= 16'hffff;

    end

    else begin

        receive_data <= 1'b0;


        if (spi_enable) begin

            /*----------------------------------------------
             Start SPI transfer
            ----------------------------------------------*/

            if (send_data) begin

                ss    <= 1'b0;
                count <= 16'd0;

            end


            /*----------------------------------------------
             SPI transfer in progress
            ----------------------------------------------*/

            else if (count <= (target - 1'b1)) begin

                ss    <= 1'b0;
                count <= count + 1'b1;

                if (count == (target - 1'b1))
                    receive_data <= 1'b1;

            end


            /*----------------------------------------------
             Transfer complete
            ----------------------------------------------*/

            else begin

                ss    <= 1'b1;
                count <= 16'hffff;

            end

        end

        else begin

            ss    <= 1'b1;
            count <= 16'hffff;

        end

    end

end

endmodule
