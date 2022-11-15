/*
* Main Single-Cycle Datapath Top Module
* The rest of the modules are also included below
* 	Top module has 3 new outputs used to verify correct 
* 	operation after modifications.
*/
module Datapath(input logic clock,
		input logic clear,
		output logic[31:0] writedata,
		output logic[31:0] dataadr,
		output logic memwrite);
		
		logic[31:0] data_memory_write_data;
		logic[31:0] data_memory_address;
		logic data_memory_write;
		
		// These have been added to facilitate verification 
		// after modifications
		assign writedata = data_memory_write_data;
		assign dataadr = data_memory_address;
		assign memwrite = data_memory_write;

	// PC register
	logic[31:0] pc_in;
	logic[31:0] pc_out;
	PcRegister pc_register(
			clock,
			clear,
			pc_in,
			pc_out);

	// Instruction memory
	logic[31:0] instruction_memory_address;
	logic[31:0] instruction_memory_instr;
	InstructionMemory instruction_memory(
			clock,
			clear,
			instruction_memory_address,
			instruction_memory_instr);
	
	// Connections for instruction memory
	assign instruction_memory_address = pc_out;
	
	// Adder4
	logic[31:0] adder4_in;
	logic[31:0] adder4_out;
	Adder4 adder4(adder4_in,
			adder4_out);
	
	// Connections for Adder4
	assign adder4_in = pc_out;
	
	// PC MUX
	logic[31:0] pc_mux_in0;
	logic[31:0] pc_mux_in1;
	logic[31:0] pc_mux_out;
	logic pc_mux_sel;
	Mux32Bit2To1 pc_mux(pc_mux_in0,
			pc_mux_in1,
			pc_mux_sel,
			pc_mux_out);
	
	// Connections for PC MUX
	assign pc_in = pc_mux_out;
	assign pc_mux_in0 = adder4_out;

	// Register file
	logic[4:0] register_file_read_index1;
	logic[31:0] register_file_read_data1;
	logic[4:0] register_file_read_index2;
	logic[31:0] register_file_read_data2;
	logic register_file_write;
	logic[4:0] register_file_write_index;
	logic[31:0] register_file_write_data;
	RegisterFile register_file(
			clock,
			clear,
			register_file_read_index1,
			register_file_read_data1,
			register_file_read_index2,
			register_file_read_data2,
			register_file_write,
			register_file_write_index,
			register_file_write_data);
	
	// Connections for register file
	assign register_file_read_index1 = instruction_memory_instr[19:15];
	assign register_file_read_index2 = instruction_memory_instr[24:20];
	assign register_file_write_index = instruction_memory_instr[11:7];

	// ALU MUX
	logic[31:0] alu_mux_in0;
	logic[31:0] alu_mux_in1;
	logic[31:0] alu_mux_out;
	logic alu_mux_sel;
	Mux32Bit2To1 alu_mux(
			alu_mux_in0,
			alu_mux_in1,
			alu_mux_sel,
			alu_mux_out);
	
	// Connections for ALU MUX
	assign alu_mux_in0 = register_file_read_data2;

	// ALU
	logic[31:0] alu_op1;
	logic[31:0] alu_op2;
	logic[3:0] alu_f;
	logic[31:0] alu_result;
	logic alu_zero;
	Alu alu(alu_op1,
			alu_op2,
			alu_f,
			alu_result,
			alu_zero);
	
	// Connections for ALU
	assign alu_op1 = register_file_read_data1;
	assign alu_op2 = alu_mux_out;

	// Data memory
	//logic[31:0] data_memory_address;
	//logic data_memory_write;
	//logic[31:0] data_memory_write_data;
	logic[31:0] data_memory_read_data;
	DataMemory data_memory(
			clock,
			clear,
			data_memory_address,
			data_memory_write,
			data_memory_write_data,
			data_memory_read_data);

	// Connections for data memory
	assign data_memory_address = alu_result;
	assign data_memory_write_data = register_file_read_data2;

	// Data memory MUX
	logic[31:0] data_memory_mux_in0;
	logic[31:0] data_memory_mux_in1;
	logic data_memory_mux_sel;
	logic[31:0] data_memory_mux_out;
	Mux32Bit2To1 data_memory_mux(
			data_memory_mux_in0,
			data_memory_mux_in1,
			data_memory_mux_sel,
			data_memory_mux_out);
	
	// Connections for data memory MUX
	assign data_memory_mux_in0 = alu_result;
	assign data_memory_mux_in1 = data_memory_read_data;
	assign register_file_write_data = data_memory_mux_out;

	// ImmExtend
	logic[31:0] imm_extend_in;
	logic[1:0] imm_extend_sel;
	logic[31:0] imm_extend_out;
	ImmExtend imm_extend(
			imm_extend_in,
			imm_extend_sel,
			imm_extend_out);
	
	// Connections for ImmExtend
	assign imm_extend_in = instruction_memory_instr[31:0];
	assign alu_mux_in1 = imm_extend_out;

	// PCAdder
	logic[31:0] pc_adder_op1;
	logic[31:0] pc_adder_op2;
	logic[31:0] pc_adder_result;
	PCAdder adder(pc_adder_op1,
			pc_adder_op2,
			pc_adder_result);
	
	// Connections for adder
	assign pc_adder_op1 = imm_extend_out;
	assign pc_adder_op2 = pc_out;
	assign pc_mux_in1 = pc_adder_result;

	// And gate
	logic and_gate_in1;
	logic and_gate_in2;
	logic and_gate_pcsrc;
	and and_gate(and_gate_pcsrc,
			and_gate_in1,
			and_gate_in2);
	
	// Connections for and gate
	assign and_gate_in2 = alu_zero;
	assign pc_mux_sel = and_gate_pcsrc;
		
	// Control unit
	logic[6:0] control_unit_opcode;
	logic[2:0] control_unit_funct3;
	logic control_unit_funct7;
	logic[1:0] control_unit_imm_src;
	logic control_unit_reg_write;
	logic control_unit_alu_src;
	logic[3:0] control_unit_alu_op;
	logic control_unit_branch;
	logic control_unit_mem_write;
	logic control_unit_result_src;
	ControlUnit control_unit(
			control_unit_opcode,
			control_unit_funct3,
			control_unit_funct7,
			control_unit_imm_src,
			control_unit_reg_write,
			control_unit_alu_src,
			control_unit_alu_op,
			control_unit_branch,
			control_unit_mem_write,
			control_unit_result_src);
	
	// Connections for control unit
	assign control_unit_opcode = instruction_memory_instr[6:0];
	assign control_unit_funct3 = instruction_memory_instr[14:12];
	assign control_unit_funct7 = instruction_memory_instr[30];
	assign imm_extend_sel = control_unit_imm_src;
	assign register_file_write = control_unit_reg_write;
	assign alu_mux_sel = control_unit_alu_src;
	assign alu_f = control_unit_alu_op;
	assign and_gate_in1 = control_unit_branch;
	assign data_memory_write = control_unit_mem_write;
	assign data_memory_mux_sel = control_unit_result_src;

endmodule

/*
*	Control Unit
*/
module ControlUnit(input logic[6:0] opcode,
		input logic[2:0] funct3,
		input logic funct7,
		output logic[1:0] imm_src,
		output logic reg_write,
		output logic alu_src,
		output logic[3:0] alu_op,
		output logic branch,
		output logic mem_write,
		output logic result_src);

	always_comb
	   begin
		
		// Make sure that all output have an initial value assigned in
		// order to prevent synthesis of sequential logic.
		imm_src = 2'bxx;
		reg_write = 1'bx;
		alu_src = 1'bx;
		alu_op = 4'bxxxx;
		branch = 1'bx;
		mem_write = 1'bx;
		result_src = 1'bx;

		// Check opcode
		case (opcode)

			// If opcode is 011 0011 (R-Type), 
			// check funct3, and funct7 bits
			7'h33: begin

				// Common signals
				reg_write = 1;
				alu_src = 0;
				branch = 0;
				mem_write = 0;
				result_src = 0;
			
				// ALU operation depends on funct3 and funct7
				case (funct3)

					// add or sub
					3'b000: begin
						case (funct7)
							0: begin	// add
								alu_op = 4'b0010;
								$display("\tInstruction 'add'");
								end
							1: begin	// sub
								alu_op = 4'b0110;
								$display("\tInstruction 'sub'");
								end
						endcase
					end
					// and
					3'b111: begin
						alu_op = 4'b0000;
						$display("\tInstruction 'and'");
					end

					// or
					3'b110: begin
						alu_op = 4'b0001;
						$display("\tInstruction 'or'");
					end

					// slt
					3'b010: begin
						alu_op = 4'b0111;
						$display("\tInstruction 'slt'");
					end
					
					// sll
					3'b001: begin
					   alu_op = 4'b1000;
					   $display("\tInstruction 'sll'");
					end
				endcase
			end
            
            // slli
            7'h13: begin
                imm_src = 2'b00;
				reg_write = 1;
				alu_src = 1;
				alu_op = 4'b1000;
				branch = 0;
				mem_write = 0;
				result_src = 0; // alu applied 

				$display("\tInstruction 'slli'");
            end
            
			// lw    (opcode = 000 0011)
			7'h03: begin
				imm_src = 2'b00;
				reg_write = 1;
				alu_src = 1;
				alu_op = 4'b0010;
				branch = 0;
				mem_write = 0;
				result_src = 1;
				$display("\tInstruction 'lw'");
			end

			// sw    (opcode = 010 0011)
			7'h23: begin
				imm_src = 2'b01;
				reg_write = 0;
				alu_src = 1;
				alu_op = 4'b0010;
				branch = 0;
				mem_write = 1;
				$display("\tInstruction 'sw'");
			end

			// beq    (opcode = 110 0011)
			7'h63: begin
				imm_src = 2'b10;
				reg_write = 0;
				alu_src = 0;
				alu_op = 4'b0110;
				branch = 1;
				mem_write = 0;
				$display("\tInstruction 'beq'");
			end
		endcase
	end
endmodule

/*
*	Pc Register
*/
module PcRegister(input logic clock,
		input logic clear,
		input logic[31:0] in,
		output logic[31:0] out);

	// The initial value for the PC register is 0x00010000;
	always_ff @(negedge clock, posedge clear)
		if (clear)
			out = 32'h00010000;
		else
			out = in;
endmodule

/*
*	Instruction Memory
*/
module InstructionMemory(input logic clock,
		input logic clear,
		input logic[31:0] address,
		output logic[31:0] instr);

	// We model 1KB of intruction memory (0x400 bytes in hex)
	logic[31:0] content[255:0];
	integer i;
	
	always_ff @(negedge clock, posedge clear)
		if (clear) begin

			// Reset content
			for (i = 0; i < 256; i = i + 1)
				content[i] = 0;

			// Initial values
			content[0] = 32'h002081B3;	// add x3, x1, x2  <- label 'main'
			content[1] = 32'h402081B3;	// sub x3, x1, x2
			content[2] = 32'h0020F1B3;	// and x3, x1, x2
			content[3] = 32'h0020E1B3;	// or  x3, x1, x2
			content[4] = 32'h0020A1B3;	// slt x3, x1, x2
			content[5] = 32'h001121B3;	// slt x3, x2, x1
			content[6] = 32'hFE0504E3;	// beq x10, x0, main
			content[7] = 32'h00052183;	// lw  x3, 0(x10)
			content[8] = 32'h00452183;	// lw  x3, 4(x10)
			content[9] = 32'h00352423;	// sw  x3, 8(x10)
			content[10] = 32'h00311193;	// slli  x3, x2, 3
			content[11] = 32'h002191B3;	// sll x3, x3, x2
			content[12] = 32'h04352A23;	// sw  x3, 84(x10)			
			content[13] = 32'hFC0006E3;	// beq x0, x0, main
		end
		else begin
			// Display current instruction 
			$display("Fetch at PC %08x: instruction %08x", address, instr);
		end

	// Read instruction
	assign instr = address >= 32'h00010000 && address < 32'h00010400 ?
			content[(address - 32'h00010000) >> 2] : 0;

endmodule

/*
*	Register File
*/
module RegisterFile(input logic clock,
		input logic clear,
		input logic[4:0] read_index1,
		output logic[31:0] read_data1,
		input logic[4:0] read_index2,
		output logic[31:0] read_data2,
		input logic write,
		input logic[4:0] write_index,
		input logic[31:0] write_data);

	logic[31:0] content[31:0];
	integer i;

	always_ff @(negedge clock, posedge clear)
		if (clear) begin

			// Reset all registers
			for (i = 0; i < 32; i = i + 1)
				content[i] = 0;

			// Set initial values
			content[1] = 1;			// x1 = 1
			content[2] = 2;			// x2 = 2
			content[10] = 32'h10000000;	// x10 = 0x10000000
		end else if (write) begin
			content[write_index] = write_data;
			$display("\tR[%d] = %x (hex)", write_index, write_data);
		end
	// A read to register 0 always returns 0
	assign read_data1 = read_index1 == 0 ? 0 : content[read_index1];
	assign read_data2 = read_index2 == 0 ? 0 : content[read_index2];
	

endmodule

/*
*	Data Memory
*/
module DataMemory(input logic clock,
		input logic clear,
		input logic[31:0] address,
		input logic write,
		input logic[31:0] write_data,
		output logic[31:0] read_data);

	// We model 1KB of data memory (0x400 bytes in hex)
	logic[31:0] content[255:0];
	integer i;
	
	always_ff @(negedge clock, posedge clear)
		if (clear) begin

			// Reset memory
			for (i = 0; i < 256; i = i + 1)
				content[i] = 0;

			// Initial values
			// Mem[0x10000000] = 100
			// Mem[0x10000004] = 200
			content[0] = 100;
			content[1] = 200;

		end else if (write
				&& address >= 32'h10000000
				&& address < 32'h10000400)
		begin

			// Valid addresses
			content[(address - 32'h10000000) >> 2] = write_data;
			$display("\tM[%x] = %x (hex)", address, write_data);
		end

	// Return 0 if address is not valid
	assign read_data = address >= 32'h10000000
			&& address < 32'h10000400 ?
			content[(address - 32'h10000000) >> 2] : 0;
	
endmodule

/*
*	ALU
*/
module Alu(input logic[31:0] op1,
		input logic[31:0] op2,
		input logic[3:0] f,
		output logic[31:0] result,
		output logic zero);

	always_comb
		case (f)
			4'b0000: result = op1 & op2;
			4'b0001: result = op1 | op2;
			4'b0010: result = op1 + op2;
			4'b0011: result = 32'hxxxxxxxx;
			4'b0100: result = op1 & ~op2;
			4'b0101: result = op1 | ~op2;
			4'b0110: result = op1 - op2;
			4'b0111: result = op1 < op2;
			4'b1000: result = op1 << op2[4:0];
		endcase
	
	assign zero = result == 0;
endmodule

/*
*	ImmExtend
*/
module ImmExtend(input logic[31:0] instr, 
				input logic[1:0] immSrc,
				output logic[31:0] out);

	always_comb
		case (immSrc)
			2'b00: out = {{20{instr[31]}}, instr[31:20]};
			2'b01: out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
			2'b10: out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
			default: out = 32'bx;
		endcase
endmodule

/*
*	PC Adder
*/
module PCAdder(input logic[31:0] op1,
		input logic[31:0] op2,
		output logic[31:0] result);
	
	assign result = op1 + op2;

endmodule

/*
*	Adder4
*/
module Adder4(input logic[31:0] in,
		output logic[31:0] out);

	assign out = in + 4;
endmodule

/*
*	Multiplexer
*/
module Mux32Bit2To1(input logic[31:0] in0,
		input logic[31:0] in1,
		input logic sel,
		output logic[31:0] out);

	assign out = sel ? in1 : in0;

endmodule

// END

