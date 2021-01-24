/****************************************************************************
 * wb_target_bfm.v
 * 
 ****************************************************************************/

module wb_target_bfm #(
		parameter ADDR_WIDTH = 32,
		parameter DATA_WIDTH = 32
		) (
		input						clock,
		input						reset,
		input[ADDR_WIDTH-1:0]		adr,
		input[DATA_WIDTH-1:0]		dat_w,
		output reg[DATA_WIDTH-1:0]	dat_r,
		input						cyc,
		output reg					err,
		input[(DATA_WIDTH/8)-1:0]	sel,
		input						stb,
		output reg					ack,
		input						we
		);
	reg[DATA_WIDTH-1:0]		dat_v = 0;
	reg						err_v = 0;
	reg						ack_v = 0;
	
	reg						in_reset = 0;
	
	always @(posedge clock) begin
		if (reset) begin
			dat_r <= 0;
			dat_v = 0;
			err <= 0;
			err_v = 0;
			ack <= 0;
			ack_v = 0;
			in_reset <= 1;
		end else begin
			if (in_reset) begin
				_reset();
				in_reset <= 0;
			end
			dat_r <= dat_v;
			err <= err_v;
			ack <= ack_v;
			
			if (cyc && stb) begin
				if (ack) begin
					// End of access
					ack_v = 0;
					err_v = 0;
					err <= 0;
					ack <= 0;
				end else begin
					// Beginning of access
					_access_req(adr, we, sel, dat_w);
				end
			end
		end
	end
	
	task access_ack(
		input reg[63:0]			dat,
		input reg[7:0]			err);
	begin
		ack_v = 1;
		dat_v = dat;
		err_v = err;
	end
	endtask

	task init;
	begin
		$display("wb_target_bfm: %m");
		_set_parameters(ADDR_WIDTH, DATA_WIDTH);
	end
	endtask

	// Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif
endmodule
 