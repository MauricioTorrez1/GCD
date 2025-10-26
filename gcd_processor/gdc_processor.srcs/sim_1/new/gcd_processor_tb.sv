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



module tb_gcd_processor_display;

    // --- Señales del Testbench ---
    reg clk, clr, go;
    reg [7:0] xin, yin;
    wire [3:0] an;
    wire [6:0] sseg;

    // --- Instanciación del DUT ---
    gcd_processor dut (
        .clk(clk), .clr(clr), .go(go),
        .xin(xin), .yin(yin),
        .an(an), .sseg(sseg)
    );

    // --- Generación del Reloj ---
    always begin
        clk = 1'b0; #5; // 100 MHz
        clk = 1'b1; #5;
    end

    // --- Bloque de Estímulos ---
    initial begin
        $display("Iniciando simulación del GCD Processor con Display Secuencial...");
        // Usar $monitor para ver cambios clave (opcional, útil para depurar)
        // $monitor("Time=%0t | go=%b | disp_state=%s | gcd_internal=%h | an=%h sseg=%h",
        //          $time, go, dut.disp_state.name(), dut.gcd_internal, an, sseg);

        // 1. Reset Inicial (Mostrará "----")
        clr = 1'b1; go=0; xin=0; yin=0;
        #20;
        clr = 1'b0;
        #10;
        $display("Tiempo=%0t | Estado: IDLE (Display='----')", $time);

        // 2. Prueba GCD(15, 70) = 5
        xin = 8'd15; // 0F hex
        yin = 8'd70; // 46 hex
        $display("Tiempo=%0t | Iniciando calculo para GCD(15, 70)...", $time);
        go = 1'b1; // Pulso de inicio
        #10;
        go = 1'b0;

        // 3. Esperar a que se muestre XIN ("--0F")
        $display("Tiempo=%0t | Esperando mostrar XIN...", $time);
        #0.6s; // Espera un poco más de 0.5s

        // 4. Esperar a que se muestre YIN ("--46")
        $display("Tiempo=%0t | Esperando mostrar YIN...", $time);
        #0.6s; // Espera otro poco más de 0.5s

        // 5. Esperar a que se muestre "CALC"
        $display("Tiempo=%0t | Esperando mostrar CALC...", $time);
        #50; // Solo necesita unos ciclos para cambiar a CALC

        // 6. Esperar a que termine el cálculo y se muestre GCD ("0005")
        $display("Tiempo=%0t | Esperando resultado GCD...", $time);
        wait (dut.cu_done == 1); // Espera hasta que la unidad de control termine
        #10; // Un ciclo extra para que el display FSM cambie a SHOW_GCD
        #100; // Espera un poco para observar el resultado en el display

        $display("Tiempo=%0t | Calculo terminado. Resultado GCD mostrado.", $time);
        #1s; // Mantener el resultado visible por 1 segundo

        // 7. (Opcional) Iniciar una nueva prueba o terminar
        // clr = 1'b1; #20; clr = 1'b0; // Reset para nueva prueba
        // ...

        $display("Simulacion completada.");
        $finish;
    end

endmodule
