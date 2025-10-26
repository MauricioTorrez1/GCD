`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2025 16:22:11
// Design Name: 
// Module Name: x7segmux
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



// x7segmux.sv (Versión Corregida)
module x7segmux(
    input logic clk, reset,
    input logic [3:0] hex3, hex2, hex1, hex0,
    output logic [3:0] an,
    output logic [6:0] sseg
);
    localparam N = 18;
    logic [N-1:0] q_reg;
    logic [3:0] hex_in;

    always_ff @(posedge clk or posedge reset)
        if (reset) q_reg <= '0;
        else       q_reg <= q_reg + 1;

    always_comb
        case (q_reg[N-1:N-2])
            2'b00: begin an = 4'b1110; hex_in = hex0; end // Dígito 0 (derecha)
            2'b01: begin an = 4'b1101; hex_in = hex1; end // Dígito 1
            2'b10: begin an = 4'b1011; hex_in = hex2; end // Dígito 2
            default: begin an = 4'b0111; hex_in = hex3; end // Dígito 3 (izquierda)
        endcase

    // Decodificador Hexadecimal a 7 Segmentos (Ajustado)
    always_comb
        case(hex_in)
            // Números 0-9
            4'h0: sseg = 7'b1000000; // 0
            4'h1: sseg = 7'b1111001; // 1
            4'h2: sseg = 7'b0100100; // 2
            4'h3: sseg = 7'b0110000; // 3
            4'h4: sseg = 7'b0011001; // 4
            4'h5: sseg = 7'b0010010; // 5 (y también usado para 'S')
            4'h6: sseg = 7'b0000010; // 6
            4'h7: sseg = 7'b1111000; // 7
            4'h8: sseg = 7'b0000000; // 8
            4'h9: sseg = 7'b0010000; // 9
            
            // Caracteres usados en gcd_processor
            4'hA: sseg = 7'b0001000; // Dibuja 'A' (CHAR_A)
            4'hB: sseg = 7'b0001100; // Dibuja 'P' (CHAR_P)
            4'hC: sseg = 7'b0111111; // Dibuja '-' (Guion, CHAR_DASH)
            4'hD: sseg = 7'b1000110; // Dibuja 'C' (CHAR_C)
            4'hE: sseg = 7'b1000111; // Dibuja 'L' (CHAR_L)
            
            // Carácter para dígito apagado o no usado (si lo necesitas)
            4'hF: sseg = 7'b1111111; // Todos los segmentos apagados (BLANK)
            
            // Default (en caso de recibir un código inesperado, muestra 'F')
            default: sseg = 7'b0001110; 
        endcase
endmodule