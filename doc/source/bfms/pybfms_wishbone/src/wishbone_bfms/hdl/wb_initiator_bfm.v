/****************************************************************************
 * wb_initiator_bfm.v
 * 
 ****************************************************************************/

module wb_initiator_bfm #(
		parameter ADDR_WIDTH = 32,
		parameter DATA_WIDTH = 32
		) (
		input							clock,
		input							reset,
		output reg[ADDR_WIDTH-1:0]		adr,
		output reg[DATA_WIDTH-1:0]		dat_w,
		input[DATA_WIDTH-1:0]			dat_r,
		output reg						cyc,
		input							err,
		output reg[(DATA_WIDTH/8)-1:0]	sel,
		output reg						stb,
		input							ack,
		output reg						we
		);
	reg[3:0]				stb_v = 0;
	reg[3:0]				cyc_v = 0;
	reg						we_v = 0;
	reg[(DATA_WIDTH/8)-1:0]	sel_v = 0;
	reg[DATA_WIDTH-1:0]		dat_v = 0;
	reg[ADDR_WIDTH-1:0]		adr_v = 0;
	
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
			adr <= 0;
			adr_v = 0;
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
			stb <= |stb_v;
			cyc <= |cyc_v;
			we <= we_v;
			sel <= sel_v;
			dat_w <= dat_v;
			adr <= adr_v;
			
			if (cyc && stb && ack) begin
				_access_ack(dat_r);
				stb_v = stb_v - 1;
				cyc_v = cyc_v - 1;
				/*
				we_v = 0;
				sel_v = 0;
				dat_v = 0;
				adr_v = 0;
				*/
				stb <= 0;
				cyc <= 0;
				we <= 0;
			end
			
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
		input reg[63:0]			dat,
		input reg[7:0]			we,
		input reg[7:0]			sel);
	begin
		stb_v = stb_v + 1;
		cyc_v = cyc_v + 1;
		we_v = we;
		sel_v = sel;
		dat_v = dat;
		adr_v = adr;
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
		_set_parameters(ADDR_WIDTH, DATA_WIDTH);
	end
	endtask

	// Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif
endmodule
 