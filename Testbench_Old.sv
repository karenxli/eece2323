// This is the test-bench for the single-cycle datapath supporting instructions
// add, sub, slt, and, or, lw, sw, beq. When sequential logic components are
// sent an asynchronous reset signal (clear), their content is set to the
// following values:
//
// * The initial value of register PC is 0x00010000 (.text memory section)
//
// * The initial value of all registers are 0, except for the following
//   registers:
//
//	x1 = 1
//	x2 = 2
//	x10 = 0x10000000 (base address of data segment)
//
// * The data memory is initialized with the following words:
//
//	[0x10000000] = 100
//	[0x10000004] = 200
//
// * The instruction memory has been initialized to contain the following
//   program:
//
//	main:
// 		add x3, x1, x2			# x3 = 1 + 2 = 3
// 		sub x3, x1, x2			# x3 = 1 - 2 = -1
// 		and x3, x1, x2			# x3 = 1 & 2 = 0
// 		or x3, x1, x2			# x3 = 1 | 2 = 3
// 		slt x3, x1, x2			# x3 = 1 < 2 = 1 (true)
// 		slt x3, x2, x1			# x3 = 2 < 1 = 0 (false)
// 		beq x10, xzero, main	# Doesn't jump, x10 is 0x10000000
// 		lw x3, 0(x10)			# x3 = Mem[0x10000000] = 100
// 		lw x3, 4(x10)			# x3 = Mem[0x10000004] = 200
// 		sw x3, 8(x10)			# Mem[0x10000008] = 200
// 		beq x0, x0, main		# Jumps to main
// 
module Main;

	// The datapath
	logic clock;
	logic clear;
	logic [31:0] writedata, dataadr;
	logic memwrite;
	
	  // instantiate device to be tested
	Datapath datapath(clock, clear, writedata, dataadr, memwrite);

	// Initial pulse for 'clear'
	initial begin
		clear = 1;
		#5 clear = 0;
	end

	// Clock signal
	initial begin
		clock = 1;
		forever #5 clock = ~clock;
	end

	// Run for 11 cycles
	initial begin
		#110 $finish;
	end
endmodule