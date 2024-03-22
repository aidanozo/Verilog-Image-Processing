`timescale 1ns / 1ps

module process(
	input clk,				// clock 
	input [23:0] in_pix,	// valoarea pixelului de pe pozitia [in_row, in_col] din imaginea de intrare (R 23:16; G 15:8; B 7:0)
	output reg [5:0] row, col, 	// selecteaza un rand si o coloana din imagine
	output reg out_we, 			// activeaza scrierea pentru imaginea de iesire (write enable)
	output reg [23:0] out_pix,	// valoarea pixelului care va fi scrisa in imaginea de iesire pe pozitia [out_row, out_col] (R 23:16; G 15:8; B 7:0)
	output mirror_done,		// semnaleaza terminarea actiunii de oglindire (activ pe 1)
	output gray_done,		// semnaleaza terminarea actiunii de transformare in grayscale (activ pe 1)
	output filter_done);	// semnaleaza terminarea actiunii de aplicare a filtrului de sharpness (activ pe 1)
	
	reg [5:0] state, next_state;
	reg [5:0] next_row, next_col;
	reg [23:0] pix1, pix2;
	
	reg [7:0] R, G, B;
	reg [7:0] min, max;
	reg [7:0] medie;
	
	reg  [7:0] aux1, aux2, aux3;
	reg  [7:0] aux4, aux5, aux6;
	reg  [7:0] aux7, aux8, aux9;
	
	reg signed [11:0] aux;
	
	assign mirror_done = state >= 5;
	assign gray_done = state >= 10;
	assign filter_done = state >= 26; 
	
	always @(posedge clk) begin
		state <= next_state;
		row <= next_row;
		col <= next_col;
	end
		
	always @(*) begin
	
		case(state)
		
		// Mirroring
		
			default: begin
				next_state = 0;
				next_row = 0;
				next_col = 0;
				out_we = 0;
				aux = 0;		
				end
			
			0: begin 
				pix1 = in_pix;
				next_row = 63 - row;
				next_state = 1;
			end
			
			1: begin 
				pix2 = in_pix;
				out_we = 1;
				out_pix = pix1;
				next_row = 63 - row;
				next_state = 3;
			end
			
			3: begin
				out_pix = pix2;
				next_state = 4;
			end
			
			4: begin
			
				out_we = 0;
				
				if (row < 31)
					if (col < 63) begin
						next_col = col + 1;
						next_state = 0;
					end
					else
					begin 
						next_row = row + 1;
						next_col = 0;
						next_state = 0;
					end
				else
					if (col < 63) begin
						next_row = row;
						next_col = col + 1;
						next_state = 0;
					end
					else
					begin 
						next_row = row;
						next_col = col;
						next_state = 5;
					end
				end
				
			5: begin
				next_row = 0;
				next_col = 0;
				next_state = 6;
				end
				
			// Grayscale
			
			6: begin
				R = in_pix[23:16];
				G = in_pix[15:8];
				B = in_pix[7:0];
				next_state = 7;
				end
				
			7: begin
				if (R <= G)
					min = R;
				else
					min = G;
				
				if (B <= min)
					min = B;
					
				if (R >= G)
					max = R;
				else
					max = G;
					
				if (B >= max)
					max = B;
				next_state = 8;
				end
				
			8: begin
				medie = (min + max) / 2;
				out_we = 1;
				out_pix[23:16] = 8'b0;
				out_pix[15:8] = medie;
				out_pix[7:0] = 8'b0;
				next_state = 9;
				end
				
			9: begin
				if (row < 63)
					if (col < 63) begin
						next_col = col + 1;
						next_state = 6;
					end
					else
					begin
						next_col = 0;
						next_row = row + 1;
						next_state = 6;
					end
				else
					if (col < 63) begin
						next_col = col + 1;
						next_state = 6;
					end
					else
					begin
						next_row = row;
						next_col = col;
						next_state = 10;
					end
				end
					
			10: begin 
				 next_row = 0;
				 next_col = 0;
				 next_state = 24;
				 end
				 
			// Sharpening	 
			
			24: begin // copiez bitii din canalul G in canalul R
				 out_we = 1;
				 out_pix[23:16] = in_pix[15:8];
				 next_state = 25;
			end
			
			25: begin // repet procedura pentru intreaga matrice
				 out_we = 0;
				 if (row < 63)
						if (col < 63) begin
							next_col = col + 1;
							next_state = 24;
						end
						else
						begin 
							next_col = 0;
							next_row = row + 1;
							next_state = 24;
						end
					else
						if (col < 63) begin
							next_col = col + 1;
							next_state = 24;
						end
						else
						begin
							next_col = 0;
							next_row = 0;
							next_state = 12;
						end
			end
			
			12: begin // memorez in aux5 valoarea pixelului ce trebuie prelucrat
			
				out_we = 1;
				aux5 = in_pix[15:8];
				
				next_row = row - 1;
				next_col = col - 1;
				next_state = 13;
				
			end

			13: begin // in continuare, testez toate cazurile in care se pot afla pixelii de pe "rama" lui aux5
			
				if(row == 63)
					aux1 = 0;
				else 
					if(col == 63)
						aux1 = 0;
					else
						aux1 = in_pix[23:16];
					
				next_col = col + 1;
				next_state = 14;
			end

			14: begin
				if(row == 63)
					aux2 = 0;
				else
					aux2 = in_pix[23:16];
					
				next_col = col + 1;
				next_state = 15;
			end

			15: begin
				if(row == 63)
					aux3 = 0;
				else 
					if(col == 0)
						aux3 = 0;
					else
						aux3 = in_pix[23:16];
					
				next_col = col - 2;
				next_row = row + 1;
				next_state = 16;
			end

			16: begin
				if(col == 63)
					aux4 = 0;
				else
					aux4 = in_pix[23:16];
					
				next_col = col + 2;
				next_state = 17;
			end

			17: begin
				if(col == 0)
					aux6 = 0;
				else
					aux6 = in_pix[23:16];
					
				next_col = col - 2;
				next_row = row + 1;
				next_state = 18;
			end

			18: begin
				if(row == 0)
					aux7 = 0;
				else if(col == 63)
					aux7 = 0;
				else
					aux7 = in_pix[23:16];
					
				next_col = col + 1;
				next_state = 19;
			end

			19: begin
				if(row == 0)
					aux8 = 0;
				else
					aux8 = in_pix[23:16];
					
				next_col = col + 1;
				next_state = 20;
			end

			20: begin
				if(row == 0)
					aux9 = 0;
				else if(col == 0)
					aux9 = 0;
				else
					aux9 = in_pix[23:16];
					
				next_col = col - 1;
				next_row = row - 1;
				next_state = 21;
			end

			21: begin // aplic matricea de convolutie
				out_we = 1;
				aux = aux5 * 9 - aux1 - aux2 - aux3 - aux4 - aux6 - aux7 - aux8 - aux9;
				next_state = 23;
			end
			
			23: begin // actionez in cazul aparitiei depasirilor, asignand o valoare corecta pixelului curent, si repet algoritmul pentru intreaga matrice
				if (aux > 8'b11111111)
					out_pix[15:8] = 255;
				else
					if (aux < 0)
						out_pix[15:8] = 8'b0;	
					else
						out_pix[15:8] = aux[7:0];
				
				if (row < 63)
						if (col < 63) begin
							next_col = col + 1;
							next_state = 12;
						end
						else
						begin 
							next_col = 0;
							next_row = row + 1;
							next_state = 12;
						end
					else
						if (col < 63) begin
							next_col = col + 1;
							next_state = 12;
						end
						else
						begin
							next_col = 0;
							next_row = 0;
							next_state = 22;
						end
			end

			22: begin // suprascriu cu valoarea 0 canalul R al fiecarui pixel
				out_we = 1;
				out_pix[23:16] = 8'b0;
				
				if (row < 63)
						if (col < 63) begin
							next_col = col + 1;
							next_state = 22;
						end
						else
						begin 
							next_col = 0;
							next_row = row + 1;
							next_state = 22;
						end
					else
						if (col < 63) begin
							next_col = col + 1;
							next_state = 22;
						end
						else
						begin
							next_state = 26;
						end
			end
			
			26: begin
				 next_col = 0;
				 next_row = 0;
			end
		 
		endcase	
	end

endmodule
