module tb_game_logic();
	reg clk,rst,press;
	int ox,oy,d1,d2,d3,d4,d5;

	game_state uut(
		.clk(clk), .rst(rst), .press(press),
		.ox(ox), .oy(oy), .oscore(), .oseq(),
		.d1(d1),.d2(d2),.d3(d3),.d4(d4),.d5(d5)
	);

	initial begin
	    {clk,rst,press} = 3'b110; #10;
	    
	    rst = 0;
	    for( int i = 0; i < 4; i++ ) begin
	    	clk = 0; #10;
	    	clk = 1; #10;
	    end
	    
	    press = 1;
	    for( int i = 0; i < 5; i++ ) begin
	    	clk = 0; #10;
	    	clk = 1; #10;
	    end
	    press = 0;
	    for( int i = 0; i < 10; i++ ) begin
	    	clk = 0; #10;
	    	clk = 1; #10;
	    end
	    
	    press = 1;
	    for( int i = 0; i < 5; i++ ) begin
	    	clk = 0; #10;
	    	clk = 1; #10;
	    end
	    press = 0;
	    for( int i = 0; i < 10; i++ ) begin
	    	clk = 0; #10;
	    	clk = 1; #10;
	    end
	end    

	initial begin
	    $dumpfile("db_tb_game_logic.vcd");
	    $dumpvars(1, tb_game_logic); 
	end

endmodule
