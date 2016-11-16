// main PE unit

module PE (
	clk,
	rst,
	input_A,
	input_B,
	output_A,
	output_B,
	input_C,
	output_C,
	input_en,
	output_en
);
	
input sel_pol; // Polarity of select. For PE0, sel reads from regA2 at cycle1 and regA1 at cycle2
				// For PE1, sel reads from regA1 at cycle1 and regA2 at cycle2
				// sel_pol is 0 for PE0 initially, and 1 for PE1

//define regs and in/outs here
parameter SIZE;
wire [SIZE] RA_out;
wire [SIZE] RB_out;
wire [SIZE] C_inter;
wire [SIZE] add_out;
wire [SIZE] memC_out;
wire [SIZE] fifoC_in;
	
reg M1_sel;
reg A_out;

//control logic (local FSM)
	
always @ (posedge clk or posedge rst)
	begin: FSM
	if (rst) begin
		//reset everyting
	end else
		case (state)
		/*
			At read0 state, based on sel_pol, correct register value will be read 
				depending on which PE are are at
			Then the state changes to read1
			At read1, the other register value is read
			The if statement distinguishes between PEs
			Idle state TBD
			
			Since we have 2 entries per register, only 2 states are needed
		*/
			IDLE: //idle state whatever it is
			READ0: 	if (!sel_pol) 
						A_out <= RA_out1;
					else 
						A_out <= RA_out2;
					state <= READ1;
			READ1:	if (sel_pol)
						A_out <= RA_out1;
					else
						A_out <= RA_out;
					state <= READ0;
			default: state <= IDLE;
		endcase
	end

	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			input_en <= 0;
			output_en <= 0;
			output_A <= 0;
			output_B <= 0;
			output_C <= 0;
		end else begin
		// TBD
		end
	end
	
	FIFO fifo_A (
	.clk (clk),
	.rst (rst),
	.data_in (input_A),
	.data_out (output_A),
	//***TBD
	//.write_sel (),
	//.read_sel (),
	//.read_en (),
	//.write_en (),
	//.full (),
	//.empty ()
	);
	
	FIFO fifo_B (
	.clk (clk),
	.rst (rst),
	.data_in (input_B),
	.data_out (output_B),
	//***TBD
	//.write_sel (),
	//.read_sel (),
	//.read_en (),
	//.write_en (),
	//.full (),
	//.empty ()
	);
		
	Register RA1 (
	.clk (clk),
	.rst (rst),
	.data_in (input_A),
	//.addr_in (),
	.in_enable (input_en),
	.data_out (RA_out1),
	//.addr_out,
	//.out_enable
	);
	
	Register RA2 (
	.clk (clk),
	.rst (rst),
	.data_in (RA_out1),
	//.addr_in (),
	.in_enable (input_en),
	.data_out (RA_out2),
	//.addr_out,
	//.out_enable
	);	
		
	Register RB (
	.clk (clk),
	.rst (rst),
	.data_in (input_B),
	//.addr_in (),
	.in_enable (input_en),
	.data_out (RB_out),
	//.addr_out,
	//.out_enable
	);	

	//Mux mux1 (					//if have multiple A registers
	//.data_1 (RA_out1),
	//.data_2 (RA_out2),
	//.select, //FSM determines
	//.data_out (RA_out));
		
	Mult multiplier (
	.clk (clk),
	.rst (rst),
	.input_A (RA_out),
	.input_B (RB_out),
	.output_C (C_inter)
	);	
	
	Mem_C memoryC (
	.clk (clk),
	.rst (rst),
	.add_result (add_out),
	.output_data (memC_out)
	);
	
	Add adder (
	.clk (clk),
	.rst (rst),
	.mult_out (C_inter),
	.prev_result (memC_out),
	.output_data (add_out)
	);
	
	//FSM controls select signal
	Mux mux2 (					
	.data_1 (add_out),
	.data_2 (input_C),
	.select, //FSM determines
	.data_out (fifoC_in)
	);
	
	FIFO fifo_C (
	.clk (clk),
	.rst (rst),
	.data_in (fifoC_in),
	.data_out (output_C),
	//***TBD
	//.write_sel (),
	//.read_sel (),
	//.read_en (),
	//.write_en (),
	//.full (),
	//.empty ()
	);
	
