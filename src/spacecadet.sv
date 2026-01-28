//cntrl sw should be sw6
module spacegame(input logic CLOCK_50, input logic [17:0] SW,
				input logic [1:0] KEY, output logic [6:0]HEX7, output logic [6:0]HEX6, output logic [6:0]HEX5,
				output logic [6:0]HEX4, output logic [6:0]HEX3, output logic [6:0]HEX2, output logic [6:0]HEX1, output logic [6:0]HEX0, 
				output logic [15:6] LEDR);

	//output for the pseudorandom sequence creator
	logic [4:0] LFSRout;
	
	//clocks
	logic gameCLK;
	logic timerCLK;
	
	//important logic signals
	logic [4:0] difficultyLevel = 0;
	logic [1:0] cnt = 0; //for ensuring obstacle generation occurs in intervals and not every single clock cycle
	logic [31:0] timer = 0; //keeps track of how much time has passed since game start
	logic [3:0] difficulty_current_state = 0;
	logic gamestate = 0; //gamestate = 0 means game hasnt started //gamestate = 1 means game has started
	logic gamestate_next;
	
	//begin LFSR
		logic k = 0;
	
	always_ff@(posedge CLOCK_50) begin
		if (k == 0) begin
			LFSRout <= 5'b10000; 
			k <= 1;
		end
		else LFSRout <= {(LFSRout[2] ^ LFSRout[0]), LFSRout[4:1]};
	end
	//end LFSR
	
	//keep track of how much time has passed since the game start
	//also increases difficulty by 1 every twenty seconds
	//and lights up 1 LED every twenty seconds to signify increase in score
	always_ff@(posedge timerCLK) begin
		
		if(gamestate == 0) timer <= 0;
		else timer <= timer + 1;
		
		
		if((timer <= 2))  begin 
			LEDR <= 10'b0000000000;
			difficultyLevel <= 0;
		end

		case (difficulty_current_state)
            0: begin
				difficultyLevel <= 0;
				LEDR <= 10'b0000000000;
                if (timer >= 20)   difficulty_current_state <= 1;
            end
            1: begin
				difficultyLevel <= 1;
				LEDR <= 10'b0000000001;
                if (timer >= 40)   difficulty_current_state <= 2;
				if(gamestate == 0) difficulty_current_state <= 0;
            end
            2: begin
				difficultyLevel <= 2;
				LEDR <= 10'b0000000011;
                if (timer >= 60)   difficulty_current_state <= 3;
				if(gamestate == 0) difficulty_current_state <= 0;
            end
            3: begin
				difficultyLevel <= 3;
				LEDR <= 10'b0000000111;
                if (timer >= 80)   difficulty_current_state <= 4;
				if(gamestate == 0) difficulty_current_state <= 0;
            end
			4: begin
				difficultyLevel <= 4;
				LEDR <= 10'b0000001111;
                if (timer >= 100)   difficulty_current_state <= 5;
				if(gamestate == 0) difficulty_current_state <= 0;
            end
			5: begin
				difficultyLevel <= 5;
				LEDR <= 10'b0000011111;
                if (timer >= 120)   difficulty_current_state <= 6;
				if(gamestate == 0) difficulty_current_state <= 0;
            end
			6: begin
				difficultyLevel <= 6;
				LEDR <= 10'b0000111111;
                if (timer >= 140)   difficulty_current_state <= 7;
				if(gamestate == 0) difficulty_current_state <= 0;
            end
			7: begin
				difficultyLevel <= 7;
				LEDR <= 10'b0001111111;
                if (timer >= 160)   difficulty_current_state <= 8;
				if(gamestate == 0) difficulty_current_state <= 0;
            end
			8: begin
				difficultyLevel <= 8;
				LEDR <= 10'b0011111111;
                if (timer >= 180)   difficulty_current_state <= 9;
				if(gamestate == 0) difficulty_current_state <= 0;
            end
			9: begin
				difficultyLevel <= 9;
				LEDR <= 10'b0111111111;
				if(gamestate == 0) difficulty_current_state <= 0;
            end
            default: begin
				difficultyLevel <= 0;
				LEDR <= 10'b0111111111;
                if (timer >= 20)   difficulty_current_state <= 1;
            end
        endcase
		
		
	end

	
	always_ff @(posedge gameCLK) begin
		gamestate <= gamestate_next;
	end
	always_comb begin
		gamestate_next = gamestate; 

		//allows game to begin (gamestate gets set to 1) when key1 is pressed
		//ends the game (gamestate gets set to 0) when the player collides with an obstacle
		case (gamestate)
			0: begin 
				if (~KEY[1])
					gamestate_next = 1;
			end

			//game over collision detection conditions
			//obstacle_up = 0x1C
			//obstacle_down = 0x23
			1: begin
				if ((HEX0 == 7'h1C && SW[6]) ||
					(HEX0 == 7'h23 && !SW[6]))
					gamestate_next = 0;
			end
		endcase
	end
 
	//obstacle spawner
	//speed at which obstacles approach the player is based off of game difficulty
	always_ff@(posedge gameCLK) begin
			
		if(gamestate == 1) begin
			
			if(cnt != 2) cnt <= cnt + 1;
			else cnt <= cnt - 2;
			
			//every in game time unit make obstacles move 1 display to the right
			HEX0 <= HEX1;
			HEX1 <= HEX2;
			HEX2 <= HEX3;
			HEX3 <= HEX4;
			HEX4 <= HEX5;
			HEX5 <= HEX6;
			HEX6 <= HEX7;
			
			//move player up or down on the display depending on sw[6] input
			if(SW[6] == 1) HEX0[0] <= 0;
			else if (SW[6] == 0) HEX0[3] <= 0;
			
			//spawn obstacles every 2 gametime(gameCLK) units
			//obstacle_up = 0x1C
			//obstacle_down = 0x23
			//no_obstacle = 0x7F
			if((cnt == 2) & (LFSRout[3] == 1) & (LFSRout[4] == 1)) HEX7 <= 7'h1C;
			else if ((cnt == 2) & (LFSRout[3] == 1) & (LFSRout[4] == 0)) HEX7 <= 7'h23;
			else HEX7 <= 7'h7F;
		end
		
	end
	
	//begin gamespeed
	logic tenhzclk;
	logic ninehzclk;
	logic eighthzclk;
	logic sevenhzclk;
	logic sixhzclk;
	logic fivehzclk;
	logic fourhzclk;
	logic threehzclk;
	logic twohzclk;
	logic onehzclk;
	logic [32:0] cnt10 = 33'd0;
	logic [32:0] cnt9 = 33'd0;
	logic [32:0] cnt8 = 33'd0;
	logic [32:0] cnt7 = 33'd0;
	logic [32:0] cnt6 = 33'd0;
	logic [32:0] cnt5 = 33'd0;
	logic [32:0] cnt4 = 33'd0;
	logic [32:0] cnt3 = 33'd0;
	logic [32:0] cnt2 = 33'd0;
	logic [32:0] cnt1 = 33'd0;

	always_ff@(posedge CLOCK_50) begin
	
		//creates 1,2,3,4,5,6,7,8,9 and 10hz clocks for use in controlling difficulty/game speed
		cnt10 <= cnt10 + 33'd1718;
		tenhzclk <= cnt10[32];	
		
		cnt9 <= cnt9 + 33'd1546;
		ninehzclk <= cnt9[32];

		cnt8 <= cnt8 + 33'd1374;
		eighthzclk <= cnt8[32];
		
		cnt7 <= cnt7 + 33'd1202;
		sevenhzclk <= cnt7[32];	
		
		cnt6 <= cnt6 + 33'd1030;
		sixhzclk <= cnt6[32];

		cnt5 <= cnt5 + 33'd859;
		fivehzclk <= cnt5[32];
		
		cnt4 <= cnt4 + 33'd687;
		fourhzclk <= cnt4[32];	
		
		cnt3 <= cnt3 + 33'd515;
		threehzclk <= cnt3[32];

		cnt2 <= cnt2 + 33'd343;
		twohzclk <= cnt2[32];
		
		cnt1 <= cnt1 + 33'd171;
		onehzclk <= cnt1[32];

	end
	
	always_comb begin

		//adjust speed of the game depending on difficulty
		case (difficultyLevel)
			0: gameCLK = onehzclk;
			1: gameCLK = twohzclk;
			2: gameCLK = threehzclk;
			3: gameCLK = fourhzclk;
			4: gameCLK = fivehzclk;
			5: gameCLK = sixhzclk;
			6: gameCLK = sevenhzclk;
			7: gameCLK = eighthzclk;
			8: gameCLK = ninehzclk;
			9: gameCLK = tenhzclk;
			default: gameCLK = onehzclk; 
		endcase

		timerCLK = onehzclk;
	end
	//end gamespeed
	
endmodule
