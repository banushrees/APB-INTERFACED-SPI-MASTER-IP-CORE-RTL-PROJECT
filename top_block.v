module top (

    input  wire       pclk,
    input  wire       preset_n,

    input  wire [2:0] paddr,
    input  wire       pwrite,
    input  wire       psel,
    input  wire       penable,

    input  wire [7:0] pwdata,

    input  wire       miso,

    output wire       ss,
    output wire       sclk,

    output wire       spi_interrupt_request,

    output wire       mosi,

    output wire [7:0] prdata,

    output wire       pready,
    output wire       pslverr
);


/*----------------------------------------------------------
 INTERNAL SIGNALS
----------------------------------------------------------*/

wire [7:0] data_mosi;
wire [7:0] data_miso;

wire send_data;
wire receive_data;

wire tip;

wire [1:0] spi_mode;

wire cpol;
wire cpha;
wire lsbfe;
wire spiswai;

wire [2:0] sppr;
wire [2:0] spr;

wire [11:0] baudratedivisor;

wire mstr;

wire miso_receive_sclk;
wire miso_receive_sclk0;

wire mosi_send_sclk;
wire mosi_send_sclk0;


/*----------------------------------------------------------
 BAUD GENERATOR
----------------------------------------------------------*/

baud_generator u1 (

    .pclk                  (pclk),
    .preset_n              (preset_n),

    .spimode               (spi_mode),
    .spiswai               (spiswai),

    .sppr                  (sppr),
    .spr                   (spr),

    .cpol                  (cpol),
    .cpha                  (cpha),

    .ss                    (ss),

    .sclk                  (sclk),

    .miso_receive_sclk     (miso_receive_sclk),
    .miso_receive_sclk0    (miso_receive_sclk0),

    .mosi_send_sclk        (mosi_send_sclk),
    .mosi_send_sclk0       (mosi_send_sclk0),

    .baudratedivisor       (baudratedivisor)

);


/*----------------------------------------------------------
 SLAVE CONTROL / CHIP SELECT
----------------------------------------------------------*/

slave_controlselect u2 (

    .pclk             (pclk),
    .preset_n         (preset_n),

    .mstr             (mstr),
    .spiswai          (spiswai),
    .spimode          (spi_mode),

    .send_data        (send_data),

    .baudratedivisor  (baudratedivisor),

    .receive_data     (receive_data),

    .ss               (ss),

    .tip              (tip)

);


/*----------------------------------------------------------
 SHIFT REGISTER
----------------------------------------------------------*/

shift_reg u3 (

    .pclk                  (pclk),
    .preset_n              (preset_n),

    .ss                    (ss),
    .send_data             (send_data),

    .lsbfe                 (lsbfe),
    .cpha                   (cpha),
    .cpol                   (cpol),

    .miso_receive_sclk     (miso_receive_sclk),
    .miso_receive_sclk0    (miso_receive_sclk0),

    .mosi_send_sclk        (mosi_send_sclk),
    .mosi_send_sclk0       (mosi_send_sclk0),

    .data_mosi             (data_mosi),

    .miso                  (miso),

    .receive_data          (receive_data),

    .mosi                  (mosi),

    .data_miso             (data_miso)

);


/*----------------------------------------------------------
 APB SLAVE INTERFACE
----------------------------------------------------------*/

apb_slave_interface apb2 (

    .pclk                    (pclk),
    .preset_n                (preset_n),

    .pwrite                  (pwrite),
    .psel                    (psel),
    .penable                 (penable),

    .ss                      (ss),

    .receive_data            (receive_data),
    .tip                     (tip),

    .paddr                   (paddr),
    .pwdata                  (pwdata),

    .miso_data               (data_miso),

    .prdata                  (prdata),

    .mstr                    (mstr),
    .cpol                    (cpol),
    .cpha                    (cpha),
    .lsbfe                   (lsbfe),

    .spiswai                 (spiswai),

    .spi_interrupt_request   (spi_interrupt_request),

    .pready                  (pready),
    .pslverr                 (pslverr),

    .send_data               (send_data),

    .spi_mode                (spi_mode),

    .sppr                    (sppr),
    .spr                     (spr),

    .mosi_data               (data_mosi)

);

endmodule
