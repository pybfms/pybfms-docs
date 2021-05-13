/****************************************************************************
 * wb_initiator_bfm.v
 * 
 ****************************************************************************/

module wb_tag_initiator_bfm #(
		parameter ADR_WIDTH = 32,
		parameter DAT_WIDTH = 32,
		parameter TGA_WIDTH = 4,
		parameter TGD_WIDTH = 4,
		parameter TGC_WIDTH = 4
		) (
		input							clock,
		input							reset,
		output reg[ADR_WIDTH-1:0]		adr,
		output reg[TGA_WIDTH-1:0]		tga,
		output reg[DAT_WIDTH-1:0]		dat_w,
		output reg[TGD_WIDTH-1:0]		tgd_w,
		input[DAT_WIDTH-1:0]			dat_r,
		input[TGD_WIDTH-1:0]			tgd_r,
		output reg						cyc,
		input							err,
		output reg[(DAT_WIDTH/8)-1:0]	sel,
		output reg						stb,
		input							ack,
		output reg						we,
		output reg[TGC_WIDTH-1:0]		tgc
		);
	reg[3:0]				stb_v = 0;
	reg[3:0]				cyc_v = 0;
	reg						we_v = 0;
	reg[(DAT_WIDTH/8)-1:0]	sel_v = 0;
	reg[DAT_WIDTH-1:0]		dat_v = 0;
	reg[ADR_WIDTH-1:0]		adr_v = 0;
	reg[TGA_WIDTH-1:0]		tga_v = 0;
	reg[TGD_WIDTH-1:0]		tgd_v = 0;
	reg[TGC_WIDTH-1:0]		tgc_v = 0;
	
	reg						in_reset = 0;
	reg[3:0]				post_reset_delay = 0;
	reg[31:0]				wait_cnt = 0;
	reg[31:0]				wait_cnt_v = 0;
	
	always @(posedge clock) begin
		if (reset) begin
			stb <= 0;
			cyc <= 0;
			we <= 0;
			sel <= 0;
			dat_w <= 0;
			dat_v = 0;
			tgd_w <= 0;
			tgd_v = 0;
			adr <= 0;
			tga <= 0;
			adr_v = 0;
			tga_v = 0;
			tgc <= 0;
			tgc_v = 0;
			wait_cnt <= 0;
			wait_cnt_v = 0;
			in_reset <= 1;
			post_reset_delay <= 0;
		end else begin
			if (in_reset) begin
				if (post_reset_delay == 4'hf) begin
					_reset();
					in_reset <= 0;
				end else begin
					post_reset_delay <= post_reset_delay + 1;
				end
			end
			if (cyc && stb && ack) begin
				stb_v = stb_v - 1;
				cyc_v = cyc_v - 1;
				_access_ack(dat_r, tgd_r);
			end
			
			stb <= |stb_v;
			cyc <= |cyc_v;
			we <= we_v;
			sel <= sel_v;
			dat_w <= dat_v;
			tgd_w <= tgd_v;
			adr <= adr_v;
			tga <= tga_v;
			tgc <= tgc_v;
			
			if (wait_cnt_v > 0) begin
				if (wait_cnt >= wait_cnt_v) begin
					_wait_ack();
					wait_cnt_v = 0;
					wait_cnt <= 0;
				end else begin
					wait_cnt <= wait_cnt+1;
				end
			end
		end
	end
	
	task _access_req(
		input reg[63:0]			adr,
		input reg[63:0]			tga,
		input reg[63:0]			dat,
		input reg[63:0]			tgd,
		input reg[7:0]			we,
		input reg[7:0]			sel,
		input reg[63:0]			tgc);
	begin
		stb_v = stb_v + 1;
		cyc_v = cyc_v + 1;
		we_v = we;
		sel_v = sel;
		dat_v = dat;
		tgd_v = tgd;
		adr_v = adr;
		tga_v = tga;
		tgc_v = tgc;
	end
	endtask
	
	task _wait_req(
		input reg[31:0]			cnt);
	begin
		wait_cnt_v = cnt;
	end
	endtask

	task init;
	begin
		$display("wb_initiator_bfm: %m");
		_set_parameters(ADR_WIDTH, DAT_WIDTH, TGA_WIDTH, TGD_WIDTH, TGC_WIDTH);
	end
	endtask

	// Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif
endmodule
 