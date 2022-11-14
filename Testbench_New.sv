
/*
* Use this testbench module to verify the sll and slli instructions
* Remove the testbench included in the base design
*/
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
		#140 $finish;
	end
	
	// check that 28 gets written to address 84
  always_ff@(negedge clock)
    begin
      if(memwrite) 
        begin
          if(dataadr === 32'h10000054 & writedata === 64) 
            begin
              $display("SIMULATION OF sll and slli SUCCEEDED...!");
            end 
          else if (dataadr !== 32'h10000008) 
             $display("SIMULATION OF sll or slli FAILED...!");
        end
    end
endmodule