`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 17:58:06
// Design Name: 
// Module Name: gcd_processor_tb
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



module gcd_processor_tb;

    // --- Señales del Testbench ---
    reg clk, clr, go;
    reg [7:0] xin, yin;
    wire [7:0] gcd;

    // --- Instanciación del DUT ---
    gcd_processor dut (
        .clk(clk), .clr(clr), .go(go),
        .xin(xin), .yin(yin),
        .gcd(gcd)
    );

    // --- Generación del Reloj ---
    always begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    // --- Bloque de Estímulos ---
    initial begin
        $display("Iniciando simulación del Procesador GCD...");
        $monitor("Tiempo=%0t | clr=%b go=%b | xin=%d yin=%d | gcd=%d | Estado CU=%s | x=%d y=%d | eq=%b lt=%b",
                 $time, clr, go, xin, yin, gcd, dut.cu_inst.estado_actual.name(), dut.dp_inst.x, dut.dp_inst.y, dut.dp_inst.eqflg, dut.dp_inst.ltflg);

        // Reset
        clr = 1'b1; go=0; xin=0; yin=0;
        #20;
        clr = 1'b0;
        #10;
        // VERIFICAR: Estado = start, gcd = 0

        // Prueba GCD(15, 70) = 5
        xin = 8'd210; yin = 8'd255;
        go = 1'b1; // Inicia el cálculo
        #10;
        go = 1'b0;
        #200; // 'go' es solo un pulso
        // Espera suficiente tiempo para que el algoritmo termine
        // (El número exacto de ciclos depende de los números, da un margen)
        #200;
        // VERIFICAR: Estado = done, gcd = 5

        //  Reset para nueva prueba
        clr = 1'b1;
        #20;
        clr = 1'b0;
        #10;

        //  Prueba GCD(18, 12) = 6
        xin = 8'd18; yin = 8'd12;
        go = 1'b1;
        #10;
        go = 1'b0;
        #200;
        // VERIFICAR: Estado = done, gcd = 6

        $display("Simulación del Procesador GCD completada.");
        $finish;
    end

endmodule
