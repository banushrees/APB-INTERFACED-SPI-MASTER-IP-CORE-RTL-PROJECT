module apb_slave_interface (

    input  wire       pclk,
    input  wire       preset_n,

    input  wire [2:0] paddr,
    input  wire       pwrite,
    input  wire       psel,
    input  wire       penable,
    input  wire [7:0] pwdata,

    input  wire       ss,
    input  wire [7:0] miso_data,
    input  wire       receive_data,
    input  wire       tip,

    output reg  [7:0] prdata,

    output wire       mstr,
    output wire       cpol,
    output wire       cpha,
    output wire       lsbfe,
    output wire       spiswai,

    output wire [2:0] sppr,
    output wire [2:0] spr,

    output wire       spi_interrupt_request,
    output wire       pready,
    output wire       pslverr,

    output reg        send_data,
    output reg  [7:0] mosi_data,

    output wire [1:0] spi_mode
);

localparam [7:0] CR_MASK = 8'b0001_1011;
localparam [7:0] BR_MASK = 8'b0111_0111;

localparam [2:0] ADDR_CR1 = 3'b000;
localparam [2:0] ADDR_CR2 = 3'b001;
localparam [2:0] ADDR_BR  = 3'b010;
localparam [2:0] ADDR_SR  = 3'b011;
localparam [2:0] ADDR_DR  = 3'b101;

localparam [1:0] ENABLE_S = 2'b10;

localparam [1:0] SPI_RUN  = 2'b00;
localparam [1:0] SPI_WAIT = 2'b01;

reg [7:0] spi_cr1;
reg [7:0] spi_cr2;
reg [7:0] spi_br;
reg [7:0] spi_dr;

wire [7:0] spi_sr;

wire [1:0] apb_state;

wire wr_enb;
wire rd_enb;

wire modf;
wire sptef;
wire spif;

wire ssoe;
wire modfen;
wire spie;
wire spe;
wire sptie;

wire sel0;
wire sel1;
wire sel2;

wire mux1;
wire mux2;


/*----------------------------------------------------------
 APB FSM
----------------------------------------------------------*/

apb_fsm u_apb_fsm (

    .pclk       (pclk),
    .preset_n   (preset_n),
    .psel       (psel),
    .penable    (penable),
    .apb_state  (apb_state)

);


/*----------------------------------------------------------
 SPI FSM
----------------------------------------------------------*/

spi_fsm u_spi_fsm (

    .pclk       (pclk),
    .preset_n   (preset_n),
    .spe        (spe),
    .spiswai    (spiswai),
    .spi_mode   (spi_mode)

);


/*----------------------------------------------------------
 APB READ / WRITE ENABLE
----------------------------------------------------------*/

assign wr_enb = (apb_state == ENABLE_S) && pwrite;

assign rd_enb = (apb_state == ENABLE_S) && !pwrite;


/*----------------------------------------------------------
 CR1
----------------------------------------------------------*/

always @(posedge pclk or negedge preset_n) begin

    if (!preset_n)
        spi_cr1 <= 8'h04;

    else if (wr_enb && (paddr == ADDR_CR1))
        spi_cr1 <= pwdata;

end


/*----------------------------------------------------------
 CR2
----------------------------------------------------------*/

always @(posedge pclk or negedge preset_n) begin

    if (!preset_n)
        spi_cr2 <= 8'h00;

    else if (wr_enb && (paddr == ADDR_CR2))
        spi_cr2 <= pwdata & CR_MASK;

end


/*----------------------------------------------------------
 BAUD RATE REGISTER
----------------------------------------------------------*/

always @(posedge pclk or negedge preset_n) begin

    if (!preset_n)
        spi_br <= 8'h00;

    else if (wr_enb && (paddr == ADDR_BR))
        spi_br <= pwdata & BR_MASK;

end


/*----------------------------------------------------------
 DATA REGISTER / SEND DATA
----------------------------------------------------------*/

always @(posedge pclk or negedge preset_n) begin

    if (!preset_n) begin

        spi_dr    <= 8'h00;
        send_data <= 1'b0;
        mosi_data <= 8'h00;

    end

    else begin

        /* default: send_data is a one-clock pulse */
        send_data <= 1'b0;

        /* APB write to DATA register */
        if (wr_enb && (paddr == ADDR_DR)) begin

            spi_dr <= pwdata;

            if ((spi_mode == SPI_RUN) ||
                (spi_mode == SPI_WAIT)) begin

                send_data <= 1'b1;
                mosi_data <= pwdata;

            end

        end

        /* SPI receive completed */
        else if (receive_data &&
                ((spi_mode == SPI_RUN) ||
                 (spi_mode == SPI_WAIT))) begin

            spi_dr <= miso_data;

        end

    end

end


/*----------------------------------------------------------
 CONTROL REGISTER BIT EXTRACTION
----------------------------------------------------------*/

assign spie   = spi_cr1[7];
assign spe    = spi_cr1[6];
assign sptie  = spi_cr1[5];

assign mstr   = spi_cr1[4];
assign cpol   = spi_cr1[3];
assign cpha   = spi_cr1[2];

assign ssoe   = spi_cr1[1];
assign lsbfe  = spi_cr1[0];


/*----------------------------------------------------------
 CR2 BIT EXTRACTION
----------------------------------------------------------*/

assign modfen = spi_cr2[4];
assign spiswai = spi_cr2[1];


/*----------------------------------------------------------
 BAUD RATE BIT EXTRACTION
----------------------------------------------------------*/

assign sppr = spi_br[6:4];
assign spr  = spi_br[2:0];


/*----------------------------------------------------------
 MODE FAULT
----------------------------------------------------------*/

assign modf = (~ss) && mstr && modfen && (~ssoe);


/*----------------------------------------------------------
 STATUS FLAGS
----------------------------------------------------------*/

assign sptef = (spi_dr == 8'h00);

assign spif  = (spi_dr != 8'h00);

assign spi_sr = (!preset_n)
              ? 8'b0010_0000
              : {spif, 1'b0, sptef, modf, 4'b0000};


/*----------------------------------------------------------
 APB READ DATA
----------------------------------------------------------*/

always @(*) begin

    if (rd_enb) begin

        case (paddr)

            ADDR_CR1:
                prdata = spi_cr1;

            ADDR_CR2:
                prdata = spi_cr2;

            ADDR_BR:
                prdata = spi_br;

            ADDR_SR:
                prdata = spi_sr;

            ADDR_DR:
                prdata = spi_dr;

            default:
                prdata = 8'h00;

        endcase

    end

    else begin
        prdata = 8'h00;
    end

end


/*----------------------------------------------------------
 APB RESPONSE
----------------------------------------------------------*/

assign pready = (apb_state == ENABLE_S);

assign pslverr = (apb_state == ENABLE_S) ? tip : 1'b0;


/*----------------------------------------------------------
 SPI INTERRUPT LOGIC
----------------------------------------------------------*/

assign sel0 = (~spie) && (~sptie);

assign sel1 = (~sptie) && spie;

assign sel2 = (~spie) && sptie;

assign mux1 = sel2
            ? sptef
            : (spif | modf | sptef);

assign mux2 = sel1
            ? (spif | modf)
            : mux1;

assign spi_interrupt_request =
            sel0 ? 1'b0 : mux2;

endmodule
