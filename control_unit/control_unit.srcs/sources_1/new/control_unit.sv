`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 17:27:36
// Design Name: 
// Module Name: control_unit
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


module control_unit (
    // Entradas desde el mundo exterior y la Ruta de Datos (datapath)
    input  logic clk, clr, go,
    input  logic eqflg, ltflg,
    
    // Salidas hacia la Ruta de Datos
    output logic xsel, ysel, xld, yld, gld
);

    // --- Definición de Estados ---
    typedef enum logic [2:0] { // 3 bits para 6 estados
        start, 
        input_state, 
        test1, 
        test2, 
        sub_y, // Estado y=y-x
        sub_x, // Estado x=x-y
        done 
    } statetype;

    // --- Registros de Estado ---
    statetype estado_actual, estado_siguiente;

    always_ff @(posedge clk, posedge clr) begin
        if (clr)
            estado_actual <= start;
        else
            estado_actual <= estado_siguiente;
    end

    // --- Lógica del Siguiente Estado (Transiciones) ---
    always_comb begin
        estado_siguiente = estado_actual; // Valor por defecto: permanecer en el mismo estado
        case (estado_actual)
          start:       
            if (go) 
            estado_siguiente = input_state; // Espera 'go'
          input_state: 
            estado_siguiente = test1; // Carga y pasa a test1
          test1:       
            if (eqflg) 
            estado_siguiente = done; // Si x==y, termina
            else       
            estado_siguiente = test2; // Si x!=y, pasa a test2
          test2:       
            if (ltflg) 
            estado_siguiente = sub_y; // Si x<y, calcula y=y-x
            else       
            estado_siguiente = sub_x; // Si x>=y, calcula x=x-y
          sub_y:       
          estado_siguiente = test1; // Después de y=y-x, vuelve a comparar
          sub_x:       
          estado_siguiente = test1; // Después de x=x-y, vuelve a comparar
          done:        
          estado_siguiente = done; // Permanece en 'done'
          default:     
          estado_siguiente = start;
        endcase
    end

    // --- Lógica de Salida (Señales de Control) ---
    // Las salidas dependen del estado_siguiente (tipo Mealy para acciones rápidas)
    always_comb begin
        // Valores por defecto (inactivos)
        xsel = 1'b0; 
        ysel = 1'b0; 
        xld = 1'b0; 
        yld = 1'b0; 
        gld = 1'b0;

        case (estado_siguiente) // O basado en estado_actual si se prefiere Moore
            input_state: begin // Activa la carga inicial
                xsel = 1'b1; 
                ysel = 1'b1; 
                xld = 1'b1; 
                yld = 1'b1; 
            end
            sub_y: begin // Activa la resta y carga en yreg
                ysel = 1'b0; 
                yld = 1'b1; 
            end
            sub_x: begin // Activa la resta y carga en xreg
                xsel = 1'b0; 
                xld = 1'b1; 
            end
            done: begin // Activa la carga del resultado final
                gld = 1'b1; 
            end
        endcase
    end

endmodule
