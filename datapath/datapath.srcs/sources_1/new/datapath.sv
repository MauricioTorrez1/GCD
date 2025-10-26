`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 17:15:04
// Design Name: 
// Module Name: datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module datapath (
    // Entradas desde el mundo exterior (switches) y la Unidad de Control
    input  logic clk, clr,
    input  logic [7:0] xin, yin,
    input  logic xsel, ysel, xld, yld, gld,
    
    // Salidas hacia la Unidad de Control y el mundo exterior
    output logic eqflg, ltflg,
    output logic [7:0] gcd
);

    // --- Señales Internas (Cables) ---
    logic [7:0] x, y, g;      // Salidas de los registros xreg, yreg, greg
    logic [7:0] x1, y1;     // Salidas de los multiplexores xmux, ymux
    logic [7:0] xr, yr;     // Salidas de los restadores xsubstractor, ysubstractor

    // --- Instanciación de Componentes ---

    // Multiplexor para la entrada de xreg
    // Si xsel=0, selecciona xr (resultado de x-y)
    // Si xsel=1, selecciona xin (entrada externa)
    assign x1 = (xsel) ? xin : xr; 

    // Multiplexor para la entrada de yreg
    // Si ysel=0, selecciona yr (resultado de y-x)
    // Si ysel=1, selecciona yin (entrada externa)
    assign y1 = (ysel) ? yin : yr;

    // Registros
    always_ff @(posedge clk, posedge clr) begin
        if (clr) begin
            x <= 8'b0;
            y <= 8'b0;
            g <= 8'b0;
        end else begin
            if (xld) 
            x <= x1; // Carga xreg si xld=1
            if (yld) 
            y <= y1; // Carga yreg si yld=1
            if (gld) 
            g <= x;  // Carga greg si gld=1 (almacena el resultado final desde x)
        end
    end

    // Restadores
    assign xr = x - y; // Calcula x-y
    assign yr = y - x; // Calcula y-x

    // Comparador
    assign eqflg = (x == y); // eqflg es 1 si x es igual a y
    assign ltflg = (x < y);  // ltflg es 1 si x es menor que y (comparación sin signo)

    // Salida final
    assign gcd = g; // La salida gcd es el valor almacenado en greg

endmodule
