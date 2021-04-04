/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module ecp5evn (
	input clk,
	input rstn,

	output ser_tx,
	input ser_rx,

	output [7:0] leds,

	output flash_csb,
`ifdef SIM
	output flash_clk,
`endif
	inout  flash_io0,
	inout  flash_io1,
	inout  flash_io2,
	inout  flash_io3,
	output debug_flash_csb,
	output debug_flash_clk,
	output debug_flash_io0,
	output debug_flash_io1,
	output debug_flash_io2,
	output debug_flash_io3
);
	reg [5:0] reset_cnt = 0;
	wire resetn = (&reset_cnt) && rstn;

	always @(posedge clk) begin
		reset_cnt <= reset_cnt + !resetn;
	end

	wire flash_clk;
	wire flash_io0_oe, flash_io0_do, flash_io0_di;
	wire flash_io1_oe, flash_io1_do, flash_io1_di;
	wire flash_io2_oe, flash_io2_do, flash_io2_di;
	wire flash_io3_oe, flash_io3_do, flash_io3_di;

	BB flash_io_buf [3:0] (
		.B({flash_io3, flash_io2, flash_io1, flash_io0}),
		.T(~{flash_io3_oe, flash_io2_oe, flash_io1_oe, flash_io0_oe}),
		.I({flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do}),
		.O({flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di})
	);
//	BB flash_io0_buf (.B(flash_io0), .T(~flash_io0_oe), .I(flash_io0_do), .O(flash_io0_di));
//	BB flash_io1_buf (.B(flash_io1), .T(~flash_io1_oe), .I(flash_io1_do), .O(flash_io1_di));
//	BB flash_io2_buf (.B(flash_io2), .T(~flash_io2_oe), .I(flash_io2_do), .O(flash_io2_di));
//	BB flash_io3_buf (.B(flash_io3), .T(~flash_io3_oe), .I(flash_io3_do), .O(flash_io3_di));

	//TRELLIS_IO #(.DIR("BIDIR")) TRELLIS_IO_19 (
	//	    .B(flash_io0), .I(flash_io0_do), .T((~flash_io0_oe)), .O(flash_io0_di));
	//TRELLIS_IO #(.DIR("BIDIR")) TRELLIS_IO_20 (
	//	    .B(flash_io1), .I(flash_io1_do), .T((~flash_io1_oe)), .O(flash_io1_di));
	//TRELLIS_IO #(.DIR("BIDIR")) TRELLIS_IO_21 (
	//	    .B(flash_io2), .I(flash_io2_do), .T((~flash_io2_oe)), .O(flash_io2_di));
	//TRELLIS_IO #(.DIR("BIDIR")) TRELLIS_IO_22 (
	//	    .B(flash_io3), .I(flash_io3_do), .T((~flash_io3_oe)), .O(flash_io3_di));

	assign debug_flash_csb = flash_csb;
	assign debug_flash_clk = flash_clk;
	assign debug_flash_io0 = flash_io0_do;
	assign debug_flash_io1 = flash_io1_di;
	assign debug_flash_io2 = flash_io2_do;
	assign debug_flash_io3 = flash_io3_do;

`ifndef SIM
	wire flash_clk;
	USRMCLK USRMCLK(
		.USRMCLKI(flash_clk),
		.USRMCLKTS(1'd0)
	);
`endif

	wire        iomem_valid;
	reg         iomem_ready;
	wire [3:0]  iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata;

	reg [31:0] gpio;
	assign leds = gpio;

	always @(posedge clk) begin
		if (!resetn) begin
			gpio <= 0;
		end else begin
			iomem_ready <= 0;
			if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
				iomem_ready <= 1;
				iomem_rdata <= gpio;
				if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
				if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
				if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
				if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
			end
		end
	end

	picosoc #(
		.BARREL_SHIFTER(0),
		.ENABLE_MULDIV(0),
		.PROGADDR_RESET(32'h 0020_0000) // 2 MB into flash
	) soc (
		.clk          (clk         ),
		.resetn       (resetn      ),

		.ser_tx       (ser_tx      ),
		.ser_rx       (ser_rx      ),

		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		.flash_io2_oe (flash_io2_oe),
		.flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di),

		.irq_5        (1'b0        ),
		.irq_6        (1'b0        ),
		.irq_7        (1'b0        ),

		.iomem_valid  (iomem_valid ),
		.iomem_ready  (iomem_ready ),
		.iomem_wstrb  (iomem_wstrb ),
		.iomem_addr   (iomem_addr  ),
		.iomem_wdata  (iomem_wdata ),
		.iomem_rdata  (iomem_rdata )
	);
endmodule
