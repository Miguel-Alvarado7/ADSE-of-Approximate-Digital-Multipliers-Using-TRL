// Multiplicador array EXACTO de 2 bits - referencia de normalizacion
// Baseline exacto: normaliza area/potencia frente a los aproximados.
//
// Estilo RTL identico al de los circuitos generados por los agentes
// (suma por columnas) para que la comparacion de area sea justa.
// Generado para el flujo LibreLane de out/Makefile. Top: multiplier(A,B,P).


`timescale 1ns/1ps
module multiplier (
    input  [1:0] A,
    input  [1:0] B,
    output [3:0] P);

    // Generacion de productos parciales
    wire pp0 = (A[0]&B[0]);
    wire pp1 = (A[1]&B[0]);
    wire pp2 = (A[0]&B[1]);
    wire pp3 = (A[1]&B[1]);

    // Suma de productos parciales
    wire [1:0] columna4 = 1'b0;
    wire [1:0] columna3 = pp3;
    wire [1:0] columna2 = pp1 + pp2;
    wire [1:0] columna1 = pp0;
    assign P = (columna4 << 3) + (columna3 << 2) + (columna2 << 1) + (columna1 << 0);

endmodule
