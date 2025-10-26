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



// gcd_processor.sv (Versión con display secuencial: XIN -> YIN -> CALC -> GCD)
module gcd_processor (
    input  logic clk, clr, go,
    input  logic [7:0] xin, yin,
    output logic [3:0] an,    // Salidas para los ánodos del display
    output logic [6:0] sseg   // Salidas para los segmentos del display
);

    // --- Cables Internos ---
    logic xsel, ysel, xld, yld, gld; // Señales de control CU -> DP
    logic eqflg, ltflg;              // Banderas de estado DP -> CU
    logic [7:0] gcd_internal;        // Salida GCD interna del datapath
    logic cu_done;             // Señal para indicar que la CU está en estado 'done'

    // --- Instanciación de la Unidad de Control ---
    control_unit cu_inst (
        .clk(clk), 
        .clr(clr), 
        .go(go),
        .eqflg(eqflg), 
        .ltflg(ltflg),
        .xsel(xsel), 
        .ysel(ysel), 
        .xld(xld), 
        .yld(yld), 
        .gld(gld)
    );
    assign cu_done = gld; // Detecta cuando la CU ha terminado

    // --- Instanciación de la Ruta de Datos ---
    datapath dp_inst (
        .clk(clk), 
        .clr(clr),
        .xin(xin), 
        .yin(yin),
        .xsel(xsel), 
        .ysel(ysel), 
        .xld(xld), 
        .yld(yld), 
        .gld(gld),
        .eqflg(eqflg), 
        .ltflg(ltflg),
        .gcd(gcd_internal)
    );

    // --- Lógica de Control del Display ---
    typedef enum logic [2:0] { 
    SHOW_IDLE, 
    SHOW_XIN, 
    SHOW_YIN, 
    SHOW_CALC, 
    SHOW_GCD } 
    display_state_t;
    display_state_t disp_state, disp_next_state;
    logic [25:0] timer_reg, timer_next; 
    localparam DISPLAY_TIME = 26'd50_000_000; // ~0.5 segundos

    always_ff @(posedge clk, posedge clr) begin
        if (clr) begin
            disp_state <= SHOW_IDLE;
            timer_reg  <= '0;
        end else begin
            disp_state <= disp_next_state;
            timer_reg  <= timer_next;
        end
    end

    // Lógica del temporizador y siguiente estado del display
    assign timer_next = (disp_state == SHOW_XIN || disp_state == SHOW_YIN) ? timer_reg + 1 : '0;

    always_comb begin
        disp_next_state = disp_state;
        case(disp_state)
            SHOW_IDLE: 
            if (go) 
            disp_next_state = SHOW_XIN; // Inicia secuencia con 'go'
            SHOW_XIN:  
            if (timer_reg == DISPLAY_TIME) 
            disp_next_state = SHOW_YIN; // Muestra XIN por 0.5s
            SHOW_YIN:  
            if (timer_reg == DISPLAY_TIME) 
            disp_next_state = SHOW_CALC; // Muestra YIN por 0.5s
            SHOW_CALC: 
            if (cu_done) 
            disp_next_state = SHOW_GCD; 
            SHOW_GCD:  
            disp_next_state = SHOW_GCD; 
        endcase
        if (clr) disp_next_state = SHOW_IDLE; // Reset siempre vuelve a IDLE
    end

    // --- Lógica de Traducción: Valor a mostrar -> Entradas del Display ---
    logic [3:0] hex3, hex2, hex1, hex0;
    localparam CHAR_DASH = 4'hC; // Código para '-'
    localparam CHAR_C    = 4'hD; // Código para 'C'
    localparam CHAR_A    = 4'hA;
    localparam CHAR_L    = 4'hE; // Código para 'L'
    

    always_comb begin
        // Valor por defecto: muestra guiones "----"
        {hex3, hex2, hex1, hex0} = {CHAR_DASH, CHAR_DASH, CHAR_DASH, CHAR_DASH}; 

        case(disp_state)
            SHOW_XIN:  begin 
            hex3 = 4'hF; 
            hex2 = 4'hF; 
            hex1 = xin[7:4]; 
            hex0 = xin[3:0]; end // Muestra --XX (XIN en Hex)
            
            SHOW_YIN:  begin 
            hex3 = 4'hF; 
            hex2 = 4'hF; 
            hex1 = yin[7:4]; 
            hex0 = yin[3:0]; end // Muestra --YY (YIN en Hex)
            
            SHOW_CALC: 
            {hex3, hex2, hex1, hex0} = {CHAR_C, CHAR_A, CHAR_L, CHAR_C}; // Muestra CALC
            SHOW_GCD:  begin 
            hex3 = 4'h0; 
            hex2 = 4'h0; 
            hex1 = gcd_internal[7:4]; 
            hex0 = gcd_internal[3:0]; end // Muestra 00HH (GCD en Hex)
            
            default:   
            {hex3, hex2, hex1, hex0} = {CHAR_DASH, CHAR_DASH, CHAR_DASH, CHAR_DASH}; 
        endcase
    end

    // --- Instanciación del Controlador del Display ---
    x7segmux display_inst (
        .clk(clk),
        .reset(clr), 
        .hex3(hex3),
        .hex2(hex2),
        .hex1(hex1),
        .hex0(hex0),
        .an(an),
        .sseg(sseg)
    );

endmodule
