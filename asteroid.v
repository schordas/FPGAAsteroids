`timescale 1ns / 1ps
/* This module is based on vga_demo.v, but was modified for my asteroid game*/
/* source 2: vga_demo.v on blackboard */
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module Asteroid(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b,
	Sw7,Sw6,Sw5,Sw4,Sw3,Sw2,Sw1,Sw0,
	btnU, btnD, btnC, btnL, btnR,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7,
	MISO,SS,MOSI,SCLK,AN,SEG
	
	);
	
	
	input ClkPort, btnU, btnD, btnC, btnL, btnR;
	input Sw7,Sw6,Sw5,Sw4,Sw3,Sw2,Sw1,Sw0;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg [2:0] vga_r,vga_g;
	reg [1:0] vga_b;
	reg gameover;
	reg start_falling_asteroid;
	reg game_paused;
	reg [2:0] state;
	localparam 
		GG = 3'b100,
		START =  3'b010,
		PAUSE = 3'b001;
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ClkPort, board_clk, clk, button_clk;
	BUF BUF1 (board_clk, ClkPort); 
	BUF BUF2 (reset, btnU);
	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	

	assign	clk = DIV_CLK[1];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
	
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;
	wire [9:0] joy_x,joy_y;   //// JOY STICK POSITION
	///////////////ASTEROID//////////////////////

	//////////////////////////////////////////
	
	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg [9:0] Jet_x_position, Jet_y_position;
	reg [7:0] RGB;
	
	wire [7:0] SW_C;
	assign SW_C = {Sw7,Sw6,Sw5,Sw4,Sw3,Sw2,Sw1,Sw0};
	//////////////////////////////////////////////////////////////////
	///////////////		Initial  		//////////////////////////////
	/////////////////////////////////////////////////////////////////
		reg [4:0] increase_bullet_speed;
		reg [2:0] game_level;
	initial
		begin
			state <= PAUSE;
			game_level <= 0;
			increase_bullet_speed <= 7;
		end
    ////////////////////////////////////////////////////////////////////////////
	////////////////////////////////Moving Jet/////////////////////////////////
	always @(posedge DIV_CLK[19], posedge reset)
		begin  :  move_jet
			if(reset) 
				begin
					Jet_x_position <= 380;
					Jet_y_position <= 430;

				end
			else if (state == GG)
				begin
					////gameover
				end
			else if (state == PAUSE)
				begin
					////Paused
				end
			else////no reset 
				begin  	////////////////////////////////Control of the JET///////////////////////////////////////
				if (Jet_x_position > 15)
					begin
						if(joy_x > 540 && joy_x <= 650)
							Jet_x_position <= Jet_x_position - 1;	
						if(joy_x > 650 && joy_x <= 720)
							Jet_x_position <= Jet_x_position - 2;	
						if(joy_x > 720)
							Jet_x_position <= Jet_x_position - 4;
					end
				if (Jet_x_position < 625)
					begin
						if(joy_x > 330 && joy_x < 440)
							Jet_x_position <= Jet_x_position + 1;
						if(joy_x >= 200 && joy_x <= 330)
							Jet_x_position <= Jet_x_position + 2;	
						if(joy_x < 200)
							Jet_x_position <= Jet_x_position + 4;
					end
				if (Jet_y_position < 450)
					begin
						if(joy_y >= 540 && joy_y <= 700 )
							Jet_y_position <= Jet_y_position +1;
						if(joy_y > 700 )
							Jet_y_position <= Jet_y_position +2;
					end
				if (Jet_y_position > 5)
					begin
					if(joy_y <= 440 && joy_y >=300 )
						Jet_y_position <= Jet_y_position -1;
					if(joy_y < 300 )
						Jet_y_position <= Jet_y_position -2; 
					end
	//////////////////////////End Control Of JET //////////////////////////////////

				
				end  
		end
	//////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////
	wire jet_attack_btn;
	wire bullet_speedup, bullet_speeddown;
	wire Start_stop;	
	////Debouncer provided by EE201 Lab////////////
		ee201_debouncer #(.N_dc(25)) ee201_debouncer_1
				(.CLK(board_clk), .RESET(reset), .PB(btnC), .DPB(), .SCEN(), .MCEN(jet_attack_btn), .CCEN());
		ee201_debouncer2 #(.N_dc(25)) ee201_debouncer_2
				(.CLK(board_clk), .RESET(reset), .PB(btnL), .DPB(), .SCEN(bullet_speeddown), .MCEN(), .CCEN());
		ee201_debouncer2 #(.N_dc(25)) ee201_debouncer_3
				(.CLK(board_clk), .RESET(reset), .PB(btnR), .DPB(), .SCEN(bullet_speedup), .MCEN(), .CCEN());
		ee201_debouncer2 #(.N_dc(25)) ee201_debouncer_4
				(.CLK(board_clk), .RESET(reset), .PB(btnD), .DPB(), .SCEN(Start_stop), .MCEN(), .CCEN());
	////END Debouncer////////////
	
	////////////////////////////////////////////////////////////////
	////////////////////////////Bullet//////////////////////////////


	reg [3:0] bullet_num; ////8 bullets 3'b1000
	reg [9:0] jet_bullet_x [0:8];
	reg [9:0] jet_bullet_y [0:8];
	reg [9:0] jet_bullet_y_ini [0:8];
	/////array for bullet
	
	always @ (posedge jet_attack_btn)
		begin
			if (state == START)
				begin
					jet_bullet_x[bullet_num] <= Jet_x_position;   
					jet_bullet_y_ini[bullet_num] <= Jet_y_position-3;
				end
		end
		
	always @ (negedge jet_attack_btn, posedge reset)
		begin
			if (reset)
				begin
					bullet_num <=0;
				end
			else if (state == START)
				begin
					bullet_num <= bullet_num + 1;
					if (bullet_num == 8) bullet_num <= 0;
				end
		end

	/////////////////////////End Of Bullet//////////////////////////////
	///////////////////////////////////////////////////////////////////
		always @ (posedge Start_stop) /////Function Pause/Start
		begin
			start_falling_asteroid <= ~start_falling_asteroid;
		end
	///////////////////////////////////////////////////////////////////
	///////////////			Produce Random Number /////////////////////
	///////////////////////////////////////////////////////////////////
	wire rand_bit;
	reg [9:0] rand;
	////LFSR, source:http://outputlogic.com//////
	lfsr_counter random_generator1(.clk(clk), .reset(), .d0(rand_bit));
	reg [3:0] i_rand;
	always @ (posedge DIV_CLK[2])
		begin
			rand [i_rand] = rand_bit;
			i_rand <= i_rand + 1;
			if (i_rand == 9) i_rand <= 0;
		end
	//////////////////End Random Number////////////////////////////
	
	//////////////////Start Declaring Asteroids////////////////////
	reg [9:0] asteroid_y [0:8];
	reg [9:0] asteroid_x [0:8];
	reg [7:0] score;
	reg [3:0] num_asteroid; ////  8
	reg [11:0] game_level_counter;
	reg [4:0] y_i,y_i_2;
	
	reg [7:0] asteroid_rate_counter; //counter for the generation rate of asteroid.
	always @ (posedge DIV_CLK[19], posedge reset)
		begin: Set_asteroid_y
			if (reset)
				begin
					game_level_counter<= 0;
					game_level <= 0;
					score <= 0;
					num_asteroid <= 0;
					gameover <= 0;
					state <= PAUSE;
					increase_bullet_speed <= 7;
					for(y_i=0; y_i <= 8; y_i = y_i + 1)
					begin
						jet_bullet_y[y_i] <= 0;
						asteroid_x[y_i] <= 0;
						asteroid_y[y_i] <= 0;
					end
				end
			else if (gameover)
				begin
					state <= GG;
				end
			else
				begin ///if not gameover and not reset
					if (start_falling_asteroid && state != GG)
						begin
							state <= START;
						end
					else if (!start_falling_asteroid && state != GG)
						begin
							state <= PAUSE;
						end
					//////////////Game Level//////////////////
					if (game_level != 3 && state == START)
						begin
							game_level_counter <= game_level_counter + 1;
						end
					if (game_level_counter >= 1300 && state == START)
						begin
							game_level <= game_level + 1;
							game_level_counter <= 0;
						end
					//////////////End Game Level//////////////////
					asteroid_rate_counter <= asteroid_rate_counter + 1;
					if ((asteroid_rate_counter ) >= (100 - (game_level*15)) && state == START)		////Assign X position to asteroids.
						begin
							asteroid_x[num_asteroid] <= (rand >620)? (rand >> 1): (rand+20);
							asteroid_y[num_asteroid] <= 0;
							num_asteroid <= num_asteroid + 1;
							if (num_asteroid >= 8) 
								begin
									num_asteroid <= 0;	
								end
							asteroid_rate_counter <= 0;
						end
					if (bullet_speeddown) 
						begin
							if (increase_bullet_speed>6) increase_bullet_speed <= increase_bullet_speed -1;
						end 
					if (bullet_speedup) 
						begin
							if (increase_bullet_speed<11) increase_bullet_speed <= increase_bullet_speed +1;
						end 
					if (state == START)
						begin
							for(y_i=0; y_i <= 8; y_i = y_i + 1)
							begin
								if (jet_bullet_x[y_i] > 5 && jet_bullet_y[y_i] > (increase_bullet_speed+3) )   
										begin  /////////////// Move bullets //////////////////////
											jet_bullet_y[y_i] <= jet_bullet_y[y_i] - increase_bullet_speed;
										end
									else
										begin
											jet_bullet_y[y_i] <= 0;

										end
								
								if (asteroid_y[y_i] <=510 && asteroid_x[y_i] > 0)  
									begin   ////////////////////Move Asteroids ///////////////////////
										asteroid_y[y_i] <= asteroid_y[y_i] + (game_level+1);
									end

								/////////////////////////////////////////////////////////////////////
								for (y_i_2=0; y_i_2<=8;y_i_2=y_i_2+1)
									begin 
										if (
											( (jet_bullet_x[y_i]-16) <= asteroid_x[y_i_2] ) &&  ((jet_bullet_x[y_i]+16) >= asteroid_x[y_i_2] ) &&
											 ( (jet_bullet_y[y_i]-8) <= asteroid_y[y_i_2] )
											)
											begin /////////////////////Destroy Asteroids////////////////////////////////
												asteroid_y[y_i_2] <= 0;	
												asteroid_x[y_i_2] <= 0;
												jet_bullet_y[y_i] <= 0;
												score <= score + 1;
											end
										
										if ( ((asteroid_x[y_i_2] - 16) <= Jet_x_position) && ((asteroid_x[y_i_2] + 16) >= Jet_x_position) && 
												((asteroid_y[y_i_2]-20) <= Jet_y_position) && ((asteroid_y[y_i_2]) >= Jet_y_position)
												
											)/////////////////if jet got hit////////////////////////////
											begin///////////GameOVER/////////////
						
												gameover <= 1;
											end
									end
								///////////////////////////////////////////////////////////////////////////
								
							end///y_i for loop
							
						end// end start_falling_asteroid if
					if (jet_attack_btn && state == START) 
									begin   ////////////////////Bullet initial position //////////////////
										jet_bullet_y[bullet_num] <= jet_bullet_y_ini[bullet_num];
									end
				end////reset///else////
		end

	
	
	/////////////////////Start Drawing////////////////////////////////
	//////////////////////////////////////////////////////////////////
	reg draw_color;
	reg [3:0] a;
	always @(posedge clk)
	begin:DRAW
				draw_color = 0;
				if 
					(  
						(CounterX>=(Jet_x_position-1) && CounterX<=(Jet_x_position+1) && CounterY >= (Jet_y_position) && CounterY <= (Jet_y_position+3)) ||
						(CounterX>=(Jet_x_position-2) && CounterX<=(Jet_x_position+2) && CounterY >= (Jet_y_position+3) && CounterY <= (Jet_y_position+5)) ||
						(CounterX>=(Jet_x_position-3) && CounterX<=(Jet_x_position+3) && CounterY >= (Jet_y_position+5) && CounterY <= (Jet_y_position+7)) ||
						(CounterX>=(Jet_x_position-4) && CounterX<=(Jet_x_position+4) && CounterY >= (Jet_y_position+7) && CounterY <= (Jet_y_position+10)) ||
						(CounterX>=(Jet_x_position-10) && CounterX<=(Jet_x_position+10) && CounterY >= (Jet_y_position+10) && CounterY <= (Jet_y_position+15)) ||
						(CounterX>=(Jet_x_position-3) && CounterX<=(Jet_x_position+3) && CounterY >= (Jet_y_position+15) && CounterY <= (Jet_y_position+22)) ||
						(CounterX>=(Jet_x_position-8) && CounterX<=(Jet_x_position+8) && CounterY >= (Jet_y_position+22) && CounterY <= (Jet_y_position+27))
					)
					begin   ////Draw jet
						if (!(state == GG)) RGB = SW_C;  //// set color for the jet
						else RGB = 8'b11100000;
						draw_color = 1;
					end
			
			for (a = 0; a <= 8; a = a + 1)  
				begin
					if (jet_bullet_x[a] > 0)
					begin  ///Draw Bullet
						if 
						(
							CounterX >= (jet_bullet_x[a]-2) && CounterX <= (jet_bullet_x[a]+2) && CounterY >= (jet_bullet_y[a]-7) && CounterY <= (jet_bullet_y[a])
						)
						begin
							if (jet_bullet_y[a] != 0)
							begin
								if (!(state == GG)) RGB = 8'b11111111;
								else RGB = 8'b11100000;
								draw_color = 1;
							end
						end
					end
					if (asteroid_x[a] > 14 && asteroid_x[a] >3)  ////////display after 14px.
					begin ////////////////////Draw Asteriod/////////////////////////
						if 
						 ( 
							( CounterX >= (asteroid_x[a]-9) && CounterX <= (asteroid_x[a]+9)  && CounterY == (asteroid_y[a])) ||
							( CounterX >= (asteroid_x[a]-11) && CounterX <= (asteroid_x[a]+11)  && CounterY == (asteroid_y[a]-1))  ||
							( CounterX >= (asteroid_x[a]-14) && CounterX <= (asteroid_x[a]+14)  && CounterY == (asteroid_y[a]-2)) 
						 )
							begin
								if (!(state == GG)) RGB = 8'b11100001; 
								else RGB = 8'b11100000;
								draw_color = 1;
							end
						if 
						(
							(CounterX >= (asteroid_x[a]-6) && CounterX <= (asteroid_x[a]+6) && CounterY == (asteroid_y[a]-1)) ||
							(CounterX >= (asteroid_x[a]-9) && CounterX <= (asteroid_x[a]+10) && CounterY <= (asteroid_y[a]-2) && CounterY >= (asteroid_y[a]-7)) ||
							((CounterX == (asteroid_x[a]-7) || CounterX == (asteroid_x[a]+5)) && CounterY <= (asteroid_y[a]-7) && CounterY >= (asteroid_y[a]-10)) 
						)
							begin
			
								if (!(state == GG)) RGB = 8'b00001111;
								else RGB = 8'b11100000;
								draw_color = 1;
						
							end
					end
				end
			
				if (draw_color == 0) 
					begin
					if (!(state == GG)) RGB = 0;
					if (state == GG) RGB = 8'b01001010;
						draw_color <= 0;
					end
				vga_r = RGB[7:5];
				vga_g = RGB[4:2];
				vga_b = RGB[1:0];
					
		
	
			
			
			

	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = increase_bullet_speed[0];
	assign LD1 = increase_bullet_speed[1];	
	assign LD2 = increase_bullet_speed[2];
	assign LD3 = increase_bullet_speed[3];

	assign LD4 = !game_level[0] && !game_level[1];
	assign LD5 = game_level[0] && !game_level[1];	
	assign LD6 = game_level[1] && !game_level[0];
	assign LD7 = game_level[0] && game_level[1];
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	
	///Start Copied Code
	///Source:http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,401,529&Prod=PMOD-JSTK
	
	/////////////////////////////////////////////////////////////////
	//////////////////    JOYSTICK     ///////////////////////////////
	
			input MISO;					// Master In Slave Out, Pin 3, Port JA
			output SS;					// Slave Select, Pin 1, Port JA
			output MOSI;				// Master Out Slave In, Pin 2, Port JA
			output SCLK;				// Serial Clock, Pin 4, Port JA
			output [3:0] AN;			// Anodes for Seven Segment Display
			output [6:0] SEG;			// Cathodes for Seven Segment Display
			
			wire SS;						// Active low
			wire MOSI;					// Data transfer from master to slave
			wire SCLK;					// Serial clock that controls communication
			wire [3:0] AN;				// Anodes for Seven Segment Display
			wire [6:0] SEG;			// Cathodes for Seven Segment Display
			// Holds data to be sent to PmodJSTK
			wire [7:0] sndData;
			// Signal to send/receive data to/from PmodJSTK
			wire sndRec;
			wire [39:0] jstkData;
			wire [9:0] posData;

			//-----------------------------------------------
			//  	  			PmodJSTK Interface
			//-----------------------------------------------
			PmodJSTK PmodJSTK_Int(
					.CLK(board_clk),
					.sndRec(sndRec),
					.DIN(sndData),
					.MISO(MISO),
					.SS(SS),
					.SCLK(SCLK),
					.MOSI(MOSI),
					.DOUT(jstkData)
			);
			//-----------------------------------------------
			//  			 Send Receive Generator
			//-----------------------------------------------
			ClkDiv_5Hz genSndRec(
					.CLK(board_clk),
					.CLKOUT(sndRec)
			);
			//-----------------------------------------------
			//  		Seven Segment Display Controller
			//-----------------------------------------------
			ssdCtrl DispCtrl(
					.CLK(board_clk),
					.DIN(posData),
					.AN(AN),
					.SEG(SEG)
			);
			// End Copied Code
			/////////////////////////
			
			assign posData = score;
			
			assign joy_x = {jstkData[25:24], jstkData[39:32]};
			assign joy_y = {jstkData[9:8], jstkData[23:16]};
	
endmodule
