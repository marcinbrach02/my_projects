module microSD(
	input wire CLK50,
	input wire RST,
	
	input wire W_STB,
	input wire [7:0] W_DATA,
	
	input wire R_STB,
	output reg [7:0] R_DATA,
	
	output reg MOSI,
	input reg MISO,
	output wire SCLK,
	output reg CS,	
	
);

wire CLK8;
wire CLK74;
reg [1:0] period; 
reg [3:0] period1;
reg [7:0] period2;
reg [7:0] DATA;


always @(posedge CLK50 or posedge RST)								//dzielnik częstotliwości do 100 - 400 kHz
	if(RST) 														//przy zegarze 50 MHz dla period[8] ~ 195 KHz
		period = 0;													//period[1] = 25MHz 
	else
		period = period + 1;

assign SCLK = period[1];

always@(posedge SCLK or posedge RST)								//odmierzanie 8 taktow dla odbioru wiadomości gdy period1 = 8	 	
	if (MISO == 0) 				
		period1 = 8;								
	else
		period1 = period1 - 1;

assign CLK8 = period1[3];


always@(posedge SCLK or posedge RST)								//odmierzanie 74 takty	 	
	if (RST == 1)													//dla period2[7] i period2 = 74
		period2 = 4;
	else if(period2[3] == 1)
		period2 = 4'b1111;	
	else
		period2 = period2 - 1;

assign CLK74 = period2[3];
					


always @(posedge SCLK or posedge W_STB or posedge CLK74 or posedge CS)	   	//wysłanie komendy do karty
	if(W_STB)
		DATA <= W_DATA;	
	else if (CLK74 == 0)
		begin
			MOSI <= 1;
			CS <= 1;
		end	
	else if (CLK74 == 1)
		begin
			CS <= 0; 
			MOSI <= DATA[7];					   
		    DATA <= DATA << 1;
			if ((DATA == 8'b0000_0000) && (W_STB == 1))	 
				begin
				DATA <= W_DATA;
				end		
			else if ((DATA == 8'b0000_0000) && (W_STB == 0))	 
				begin
				MOSI <= 1;
				end	
		end	
		
		
always @(posedge SCLK or posedge R_STB)	   					//odbiór danych
	if (R_STB)
		R_DATA <= DATA;
	else if ((MISO == 0) || (CLK8 == 0))
		begin
		DATA[0] <= MISO;
		DATA <= DATA << 1;
		end
		
		
endmodule