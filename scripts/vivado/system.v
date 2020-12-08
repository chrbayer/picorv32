`timescale 1 ns / 1 ps

module system (
	input  wire      clk_300mhz_p,
    input  wire      clk_300mhz_n,
	input            resetn,
	output           trap,
	output reg [7:0] out_byte,
	output reg       out_byte_en
);
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 1;

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 4096;

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;

	// Internal 125 MHz clock
	wire clk_sys_int;
	wire rst_sys_int;

	wire mmcm_rst = ~resetn;
	wire mmcm_locked;
	wire mmcm_clkfb;

	IBUFGDS #(
	   .DIFF_TERM("FALSE"),
	   .IBUF_LOW_PWR("FALSE")   
	)
	clk_300mhz_ibufg_inst (
	   .O   (clk_300mhz_ibufg),
	   .I   (clk_300mhz_p),
	   .IB  (clk_300mhz_n) 
	);

	// MMCM instance
	// 300 MHz in, 125 MHz out
	// PFD range: 10 MHz to 500 MHz
	// VCO range: 600 MHz to 1440 MHz
	// M = 10, D = 3 sets Fvco = 1000 MHz (in range)
	// Divide by 4 to get output frequency of 250 MHz
	MMCME3_BASE #(
	    .BANDWIDTH("OPTIMIZED"),
	    .CLKOUT0_DIVIDE_F(4),
	    .CLKOUT0_DUTY_CYCLE(0.5),
	    .CLKOUT0_PHASE(0),
	    .CLKOUT1_DIVIDE(1),
	    .CLKOUT1_DUTY_CYCLE(0.5),
	    .CLKOUT1_PHASE(0),
	    .CLKOUT2_DIVIDE(1),
	    .CLKOUT2_DUTY_CYCLE(0.5),
	    .CLKOUT2_PHASE(0),
	    .CLKOUT3_DIVIDE(1),
	    .CLKOUT3_DUTY_CYCLE(0.5),
	    .CLKOUT3_PHASE(0),
	    .CLKOUT4_DIVIDE(1),
	    .CLKOUT4_DUTY_CYCLE(0.5),
	    .CLKOUT4_PHASE(0),
	    .CLKOUT5_DIVIDE(1),
	    .CLKOUT5_DUTY_CYCLE(0.5),
	    .CLKOUT5_PHASE(0),
	    .CLKOUT6_DIVIDE(1),
	    .CLKOUT6_DUTY_CYCLE(0.5),
	    .CLKOUT6_PHASE(0),
	    .CLKFBOUT_MULT_F(10),
	    .CLKFBOUT_PHASE(0),
	    .DIVCLK_DIVIDE(3),
	    .REF_JITTER1(0.010),
	    .CLKIN1_PERIOD(3.333),
	    .STARTUP_WAIT("FALSE"),
	    .CLKOUT4_CASCADE("FALSE")
	)
	clk_mmcm_inst (
	    .CLKIN1(clk_300mhz_ibufg),
	    .CLKFBIN(mmcm_clkfb),
	    .RST(mmcm_rst),
	    .PWRDWN(1'b0),
	    .CLKOUT0(clk_sys_mmcm_out),
	    .CLKOUT0B(),
	    .CLKOUT1(),
	    .CLKOUT1B(),
	    .CLKOUT2(),
	    .CLKOUT2B(),
	    .CLKOUT3(),
	    .CLKOUT3B(),
	    .CLKOUT4(),
	    .CLKOUT5(),
	    .CLKOUT6(),
	    .CLKFBOUT(mmcm_clkfb),
	    .CLKFBOUTB(),
	    .LOCKED(mmcm_locked)
	);

	BUFG
	clk_sys_bufg_inst (
	    .I(clk_sys_mmcm_out),
	    .O(clk_sys_int)
	);

	sync_reset #(
	    .N(4)
	)
	sync_reset_125mhz_inst (
	    .clk(clk_sys_int),
	    .rst(~mmcm_locked),
	    .out(rst_sys_int)
	);

	picorv32 picorv32_core (
		.clk         (clk_sys_int   ),
		.resetn      (rst_sys_int   ),
		.trap        (trap          ),
		.mem_valid   (mem_valid     ),
		.mem_instr   (mem_instr     ),
		.mem_ready   (mem_ready     ),
		.mem_addr    (mem_addr      ),
		.mem_wdata   (mem_wdata     ),
		.mem_wstrb   (mem_wstrb     ),
		.mem_rdata   (mem_rdata     ),
		.mem_la_read (mem_la_read   ),
		.mem_la_write(mem_la_write  ),
		.mem_la_addr (mem_la_addr   ),
		.mem_la_wdata(mem_la_wdata  ),
		.mem_la_wstrb(mem_la_wstrb  )
	);

	reg [31:0] memory [0:MEM_SIZE-1];
	initial $readmemh("firmware.hex", memory);

	reg [31:0] m_read_data;
	reg m_read_en;

	generate if (FAST_MEMORY) begin
		always @(posedge clk_sys_int) begin
			mem_ready <= 1;
			out_byte_en <= 0;
			mem_rdata <= memory[mem_la_addr >> 2];
			if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
			end
			else
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
			end
		end
	end else begin
		always @(posedge clk_sys_int) begin
			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready && m_read_en;

			m_read_data <= memory[mem_addr >> 2];
			mem_rdata <= m_read_data;

			out_byte_en <= 0;

			(* parallel_case *)
			case (1)
				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					m_read_en <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					mem_ready <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
					out_byte_en <= 1;
					out_byte <= mem_wdata;
					mem_ready <= 1;
				end
			endcase
		end
	end endgenerate
endmodule
