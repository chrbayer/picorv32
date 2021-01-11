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

`ifdef PICOSOC_V
`error "icebreaker.v must be read before picosoc.v!"
`endif

`define PICOSOC_MEM ice40up5k_spram

module icebreaker (
	input clk,

	output ser_tx,
	input ser_rx,

	output led1,
	output led2,
	output led3,
	output led4,
	output led5,

	output ledr_n,
	output ledg_n,

	output activity_red,
	output activity_green,

	input sense_led,
	output report_led,
	input user_button,

	// raven
	// output [31:0] gpio_out,
	// input  [31:0] gpio_in,
	// output [31:0] gpio_pullup,
	// output [31:0] gpio_pulldown,
	// output [31:0] gpio_outenb,
	// raven

	input button1,
	input button2,
	input button3,

	output flash_csb,
	output flash_clk,
	inout  flash_io0,
	inout  flash_io1,
	inout  flash_io2,
	inout  flash_io3
);
	parameter integer MEM_WORDS = 32768;

	reg [5:0] reset_cnt = 0;
	wire resetn = &reset_cnt;

	always @(posedge clk) begin
		reset_cnt <= reset_cnt + !resetn;
	end

	wire [7:0] leds;

	// assign led1 = leds[1];
	// assign led2 = leds[2];
	assign led3 = leds[3];
	assign led4 = leds[4];
	assign led5 = leds[5];

	assign button1 = led1;

	assign ledr_n = !leds[6];
	assign ledg_n = !leds[7];

	wire [2:0] new_pmod_leds;

	assign report_led = new_pmod_leds[0];
	assign activity_red = new_pmod_leds[1];
	assign activity_green = new_pmod_leds[2];

	wire flash_io0_oe, flash_io0_do, flash_io0_di;
	wire flash_io1_oe, flash_io1_do, flash_io1_di;
	wire flash_io2_oe, flash_io2_do, flash_io2_di;
	wire flash_io3_oe, flash_io3_do, flash_io3_di;

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) flash_io_buf [3:0] (
		.PACKAGE_PIN({flash_io3, flash_io2, flash_io1, flash_io0}),
		.OUTPUT_ENABLE({flash_io3_oe, flash_io2_oe, flash_io1_oe, flash_io0_oe}),
		.D_OUT_0({flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do}),
		.D_IN_0({flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di})
	);

	wire        iomem_valid;
	reg         iomem_ready;
	wire [3:0]  iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata;

	// raven
	// wire   [31:0] gpio_pullup;
	// wire   [31:0] gpio_pulldown;
	// wire   [31:0] gpio_outenb;
	// raven

	reg [31:0] gpio;
	assign leds = gpio;

	reg [31:0] other_gpio;
	assign new_pmod_leds = other_gpio;

	reg [31:0] gpio_3;

	reg[31:0] mmio;

	// raven
	// reg    [31:0] raven_gpio;	// GPIO output data
	// reg    [31:0] gpio_pu;		// GPIO pull-up enable
	// reg    [31:0] gpio_pd;		// GPIO pull-down enable
	// reg    [31:0] gpio_oeb;		// GPIO output enable (sense negative)
	// raven

	// I'm not sure if this will work, but let's see if it compiles:

	wire input_wire;

	SB_IO #(
	  .PIN_TYPE(6'b0000_01),
	  .PULLUP(1'b0)
	) input_wire_conf (
	  .PACKAGE_PIN(user_button),
	  .D_IN_0(input_wire)
	);

	assign led2 = input_wire;

	// raven
	/*
	assign gpio_out[0] = (comp_output_dest == 2'b01) ? comp_in : raven_gpio[0];
	assign gpio_out[1] = (comp_output_dest == 2'b10) ? comp_in : raven_gpio[1];
	assign gpio_out[2] = (rcosc_output_dest == 2'b01) ? rcosc_in : raven_gpio[2];
	assign gpio_out[3] = (rcosc_output_dest == 2'b10) ? rcosc_in : raven_gpio[3];
	assign gpio_out[4] = (rcosc_output_dest == 2'b11) ? rcosc_in : raven_gpio[4];
	assign gpio_out[5] = (xtal_output_dest == 2'b01) ? xtal_in : raven_gpio[5]; 
	assign gpio_out[6] = (xtal_output_dest == 2'b10) ? xtal_in : raven_gpio[6]; 
	assign gpio_out[7] = (xtal_output_dest == 2'b11) ? xtal_in : raven_gpio[7]; 
	assign gpio_out[8] = (pll_output_dest == 2'b01) ? pll_clk : raven_gpio[8];
	assign gpio_out[9] = (pll_output_dest == 2'b10) ? pll_clk : raven_gpio[9];
	assign gpio_out[10] = (pll_output_dest == 2'b11) ? clk : raven_gpio[10];
	assign gpio_out[11] = (trap_output_dest == 2'b01) ? trap : raven_gpio[11];
	assign gpio_out[12] = (trap_output_dest == 2'b10) ? trap : raven_gpio[12];
	assign gpio_out[13] = (trap_output_dest == 2'b11) ? trap : raven_gpio[13];
	assign gpio_out[14] = (overtemp_dest == 2'b01) ? overtemp : raven_gpio[14];
	assign gpio_out[15] = (overtemp_dest == 2'b10) ? overtemp : raven_gpio[15];
	*/

       	// turn off raven
       	/*
       	assign gpio_out[0] = sense_led;
	assign gpio_out[1] = raven_gpio[1];
	assign gpio_out[2] = raven_gpio[2];
	assign gpio_out[3] = raven_gpio[3];
	assign gpio_out[4] = raven_gpio[4];
	assign gpio_out[5] = raven_gpio[5];
	assign gpio_out[6] = raven_gpio[6];
	assign gpio_out[7] = raven_gpio[7];
	assign gpio_out[8] = raven_gpio[8];
	assign gpio_out[9] = raven_gpio[9];
	assign gpio_out[10] = raven_gpio[10];
	assign gpio_out[11] = raven_gpio[11];
	assign gpio_out[12] = raven_gpio[12];
	assign gpio_out[13] = raven_gpio[13];
	assign gpio_out[14] = raven_gpio[14];
	assign gpio_out[15] = raven_gpio[15];
	assign gpio_out[16] = raven_gpio[16];
	assign gpio_out[17] = raven_gpio[17];
	assign gpio_out[18] = raven_gpio[18];
	assign gpio_out[19] = raven_gpio[19];
	assign gpio_out[20] = raven_gpio[20];
	assign gpio_out[21] = raven_gpio[21];
	assign gpio_out[22] = raven_gpio[22];
	assign gpio_out[23] = raven_gpio[23];
	assign gpio_out[24] = raven_gpio[24];
	assign gpio_out[25] = raven_gpio[25];
	assign gpio_out[26] = raven_gpio[26];
	assign gpio_out[27] = raven_gpio[27];
	assign gpio_out[28] = raven_gpio[28];
	assign gpio_out[29] = raven_gpio[29];
	assign gpio_out[30] = raven_gpio[30];
	assign gpio_out[31] = raven_gpio[31];
	*/

	/*
	assign gpio_outenb[0] = (comp_output_dest == 2'b00)  ? gpio_oeb[0] : 1'b0;
	assign gpio_outenb[1] = (comp_output_dest == 2'b00)  ? gpio_oeb[1] : 1'b0;
	assign gpio_outenb[2] = (rcosc_output_dest == 2'b00) ? gpio_oeb[2] : 1'b0; 
	assign gpio_outenb[3] = (rcosc_output_dest == 2'b00) ? gpio_oeb[3] : 1'b0;
	assign gpio_outenb[4] = (rcosc_output_dest == 2'b00) ? gpio_oeb[4] : 1'b0;
	assign gpio_outenb[5] = (xtal_output_dest == 2'b00)  ? gpio_oeb[5] : 1'b0;
	assign gpio_outenb[6] = (xtal_output_dest == 2'b00)  ? gpio_oeb[6] : 1'b0;
	assign gpio_outenb[7] = (xtal_output_dest == 2'b00)  ? gpio_oeb[7] : 1'b0;
	assign gpio_outenb[8] = (pll_output_dest == 2'b00)   ? gpio_oeb[8] : 1'b0;
	assign gpio_outenb[9] = (pll_output_dest == 2'b00)   ? gpio_oeb[9] : 1'b0;
	assign gpio_outenb[10] = (pll_output_dest == 2'b00)  ? gpio_oeb[10] : 1'b0;
	assign gpio_outenb[11] = (trap_output_dest == 2'b00) ? gpio_oeb[11] : 1'b0;
	assign gpio_outenb[12] = (trap_output_dest == 2'b00) ? gpio_oeb[12] : 1'b0;
	assign gpio_outenb[13] = (trap_output_dest == 2'b00) ? gpio_oeb[13] : 1'b0;
	assign gpio_outenb[14] = (overtemp_dest == 2'b00)    ? gpio_oeb[14] : 1'b0;
	assign gpio_outenb[15] = (overtemp_dest == 2'b00)    ? gpio_oeb[15] : 1'b0;
	*/
        // turn off raven
        // assign gpio_outenb = 32'b0;

	/*
	assign gpio_pullup[0] = (comp_output_dest == 2'b00)  ? gpio_pu[0] : 1'b0;
	assign gpio_pullup[1] = (comp_output_dest == 2'b00)  ? gpio_pu[1] : 1'b0;
	assign gpio_pullup[2] = (rcosc_output_dest == 2'b00) ? gpio_pu[2] : 1'b0; 
	assign gpio_pullup[3] = (rcosc_output_dest == 2'b00) ? gpio_pu[3] : 1'b0;
	assign gpio_pullup[4] = (rcosc_output_dest == 2'b00) ? gpio_pu[4] : 1'b0;
	assign gpio_pullup[5] = (xtal_output_dest == 2'b00)  ? gpio_pu[5] : 1'b0;
	assign gpio_pullup[6] = (xtal_output_dest == 2'b00)  ? gpio_pu[6] : 1'b0;
	assign gpio_pullup[7] = (xtal_output_dest == 2'b00)  ? gpio_pu[7] : 1'b0;
	assign gpio_pullup[8] = (pll_output_dest == 2'b00)   ? gpio_pu[8] : 1'b0;
	assign gpio_pullup[9] = (pll_output_dest == 2'b00)   ? gpio_pu[9] : 1'b0;
	assign gpio_pullup[10] = (pll_output_dest == 2'b00)  ? gpio_pu[10] : 1'b0;
	assign gpio_pullup[11] = (trap_output_dest == 2'b00) ? gpio_pu[11] : 1'b0;
	assign gpio_pullup[12] = (trap_output_dest == 2'b00) ? gpio_pu[12] : 1'b0;
	assign gpio_pullup[13] = (trap_output_dest == 2'b00) ? gpio_pu[13] : 1'b0;
	assign gpio_pullup[14] = (overtemp_dest == 2'b00)    ? gpio_pu[14] : 1'b0;
	assign gpio_pullup[15] = (overtemp_dest == 2'b00)    ? gpio_pu[15] : 1'b0;
	*/
	// turn off raven
        // assign gpio_pullup = gpio_pu;

	/*
	assign gpio_pulldown[0] = (comp_output_dest == 2'b00)  ? gpio_pd[0] : 1'b0;
	assign gpio_pulldown[1] = (comp_output_dest == 2'b00)  ? gpio_pd[1] : 1'b0;
	assign gpio_pulldown[2] = (rcosc_output_dest == 2'b00) ? gpio_pd[2] : 1'b0; 
	assign gpio_pulldown[3] = (rcosc_output_dest == 2'b00) ? gpio_pd[3] : 1'b0;
	assign gpio_pulldown[4] = (rcosc_output_dest == 2'b00) ? gpio_pd[4] : 1'b0;
	assign gpio_pulldown[5] = (xtal_output_dest == 2'b00)  ? gpio_pd[5] : 1'b0;
	assign gpio_pulldown[6] = (xtal_output_dest == 2'b00)  ? gpio_pd[6] : 1'b0;
	assign gpio_pulldown[7] = (xtal_output_dest == 2'b00)  ? gpio_pd[7] : 1'b0;
	assign gpio_pulldown[8] = (pll_output_dest == 2'b00)   ? gpio_pd[8] : 1'b0;
	assign gpio_pulldown[9] = (pll_output_dest == 2'b00)   ? gpio_pd[9] : 1'b0;
	assign gpio_pulldown[10] = (pll_output_dest == 2'b00)  ? gpio_pd[10] : 1'b0;
	assign gpio_pulldown[11] = (trap_output_dest == 2'b00) ? gpio_pd[11] : 1'b0;
	assign gpio_pulldown[12] = (trap_output_dest == 2'b00) ? gpio_pd[12] : 1'b0;
	assign gpio_pulldown[13] = (trap_output_dest == 2'b00) ? gpio_pd[13] : 1'b0;
	assign gpio_pulldown[14] = (overtemp_dest == 2'b00)    ? gpio_pd[14] : 1'b0;
	assign gpio_pulldown[15] = (overtemp_dest == 2'b00)    ? gpio_pd[15] : 1'b0;
	*/
       	// turn off raven
       	// assign gpio_pulldown = gpio_pd;
	// raven

	always @(posedge clk) begin
		if (!resetn) begin
			gpio <= 0;
			other_gpio <= 0;
			gpio_3 <= 0;
			mmio <= 0;

			// raven
			// raven_gpio <= 0;
			// gpio_oeb <= 32'hffff;
			// gpio_pu <= 0;
			// gpio_pd <= 0;
			// raven
		end else begin
			iomem_ready <= 0;
			mmio[0] <= input_wire;
			if (iomem_valid && !iomem_ready) begin
				case (iomem_addr[31:24])
					8'h 03:
					begin
						iomem_ready <= 1;
						iomem_rdata <= gpio;
						if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
						if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
						if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
						if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
					end
					8'h 04:
					begin
						iomem_ready <= 1;
						iomem_rdata <= other_gpio;
						if (iomem_wstrb[0]) other_gpio[ 7: 0] <= iomem_wdata[ 7: 0];
						if (iomem_wstrb[1]) other_gpio[15: 8] <= iomem_wdata[15: 8];
						if (iomem_wstrb[2]) other_gpio[23:16] <= iomem_wdata[23:16];
						if (iomem_wstrb[3]) other_gpio[31:24] <= iomem_wdata[31:24];
					end
					8'h 05:
					begin
						iomem_ready <= 1;
						iomem_rdata <= gpio_3;
						if (iomem_wstrb[0]) gpio_3[ 7: 0] <= iomem_wdata[ 7: 0];
						if (iomem_wstrb[1]) gpio_3[15: 8] <= iomem_wdata[15: 8];
						if (iomem_wstrb[2]) gpio_3[23:16] <= iomem_wdata[23:16];
						if (iomem_wstrb[3]) gpio_3[31:24] <= iomem_wdata[31:24];
					end
					8'h 06:
					begin
						iomem_ready <= 1;
						iomem_rdata <= mmio;
						if (iomem_wstrb[0]) mmio[ 7: 0] <= iomem_wdata[ 7: 0];
						if (iomem_wstrb[1]) mmio[15: 8] <= iomem_wdata[15: 8];
						if (iomem_wstrb[2]) mmio[23:16] <= iomem_wdata[23:16];
						if (iomem_wstrb[3]) mmio[31:24] <= iomem_wdata[31:24];
					end
				/*
					8'h 06:
					begin
						iomem_ready <= 1;
						// raven
						if (iomem_addr[7:0] == 8'h00) begin
							iomem_rdata <= {gpio_out, gpio_in};
							if (iomem_wstrb[0]) raven_gpio[ 7: 0] <= iomem_wdata[ 7: 0];
							if (iomem_wstrb[1]) raven_gpio[15: 8] <= iomem_wdata[15: 8];
							if (iomem_wstrb[2]) raven_gpio[23:16] <= iomem_wdata[23:16];
							if (iomem_wstrb[3]) raven_gpio[31:24] <= iomem_wdata[31:24];
						end else if (iomem_addr[7:0] == 8'h04) begin
							iomem_rdata <= {32'd0, gpio_oeb};
							if (iomem_wstrb[0]) gpio_oeb[ 7: 0] <= iomem_wdata[ 7: 0];
							if (iomem_wstrb[1]) gpio_oeb[15: 8] <= iomem_wdata[15: 8];
							if (iomem_wstrb[2]) gpio_oeb[23:16] <= iomem_wdata[23:16];
							if (iomem_wstrb[3]) gpio_oeb[31:24] <= iomem_wdata[31:24];
						end else if (iomem_addr[7:0] == 8'h08) begin
							iomem_rdata <= {32'd0, gpio_pu};
							if (iomem_wstrb[0]) gpio_pu[ 7: 0] <= iomem_wdata[ 7: 0];
							if (iomem_wstrb[1]) gpio_pu[15: 8] <= iomem_wdata[15: 8];
							if (iomem_wstrb[2]) gpio_pu[23:16] <= iomem_wdata[23:16];
							if (iomem_wstrb[3]) gpio_pu[31:24] <= iomem_wdata[31:24];
						end else if (iomem_addr[7:0] == 8'h0c) begin
							iomem_rdata <= {32'd0, gpio_pu};
							if (iomem_wstrb[0]) gpio_pd[ 7: 0] <= iomem_wdata[ 7: 0];
							if (iomem_wstrb[1]) gpio_pd[15: 8] <= iomem_wdata[15: 8];
							if (iomem_wstrb[2]) gpio_pd[23:16] <= iomem_wdata[23:16];
							if (iomem_wstrb[3]) gpio_pd[31:24] <= iomem_wdata[31:24];
						end
						// raven
					end
				*/
					default:
					begin
					end
				endcase
			end // if iomem_valid
		end // else
	end // always

	picosoc #(
		.BARREL_SHIFTER(0),
		.ENABLE_MULDIV(0),
		.MEM_WORDS(MEM_WORDS)
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
