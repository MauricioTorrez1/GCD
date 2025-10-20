`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 17:41:47
// Design Name: 
// Module Name: gcd_processor
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



module gcd_processor (
    input  logic clk, clr, go,
    input  logic [7:0] xin, yin,
    output logic [7:0] gcd
);

    // --- Cables Internos para Conexión ---
    logic xsel, ysel, xld, yld, gld; // Señales de control
    logic eqflg, ltflg;              // Banderas de estado

    // --- Instanciación de la Unidad de Control ---
    control_unit cu_inst (
        .clk(clk), 
        .clr(clr), 
        .go(go),
        .eqflg(eqflg), 
        .ltflg(ltflg), // Conecta banderas desde datapath
        .xsel(xsel), 
        .ysel(ysel), 
        .xld(xld), 
        .yld(yld), 
        .gld(gld) // Conecta señales de control hacia datapath
    );

    // --- Instanciación de la Ruta de Datos (datapath---
    datapath dp_inst (
        .clk(clk), .clr(clr),
        .xin(xin), .yin(yin),
        .xsel(xsel), .ysel(ysel), .xld(xld), .yld(yld), .gld(gld), // Conecta señales de control desde control_unit
        .eqflg(eqflg), .ltflg(ltflg), // Conecta banderas hacia control_unit
        .gcd(gcd)
    );

endmodule
