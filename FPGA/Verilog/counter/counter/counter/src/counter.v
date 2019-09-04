module counter(
	input wire CLK50,
	input wire RST,
	output wire LED0, 
	
	output wire [2:0] TEMP
);

reg [3:0] period;


always@(posedge CLK50 or posedge RST)		 	//proces umożliwiający zliczanie zdarzeń zegarowych
	if ((RST) || (period[3] == 1)) 				//i generowanie sygnału zegarowego o zmiennym wypełnieniu 
		period = 2;								//zaleznym od ustawionej wartości period
	else
		period = period - 1;

assign LED0 = period[3];

assign TEMP = period;
 

/*
always @(posedge CLK50 or posedge RST)		   //proces umożliwiający zliczanie taktów i łapanie
	if(RST) 								   //bitu na określonej pozycji - gwarantowane wypełnienie 1/2
		period = 0;
	else
		period = period + 1;

assign LED0 = period[4];
*/

endmodule