// Multiplicador array EXACTO de 4 bits - referencia de normalizacion
// Baseline exacto: normaliza area/potencia frente a los aproximados.
//
// Estilo RTL identico al de los circuitos generados por los agentes
// (suma por columnas) para que la comparacion de area sea justa.
// Generado para el flujo LibreLane de out/Makefile. Top: multiplier(A,B,P).


`timescale 1ns/1ps
module multiplier (
    input  [3:0] A,
    input  [3:0] B,
    output [7:0] P);

    // Generacion de productos parciales
    wire pp0 = (A[0]&B[0]);
    wire pp1 = (A[1]&B[0]);
    wire pp2 = (A[2]&B[0]);
    wire pp3 = (A[3]&B[0]);
    wire pp4 = (A[0]&B[1]);
    wire pp5 = (A[1]&B[1]);
    wire pp6 = (A[2]&B[1]);
    wire pp7 = (A[3]&B[1]);
    wire pp8 = (A[0]&B[2]);
    wire pp9 = (A[1]&B[2]);
    wire pp10 = (A[2]&B[2]);
    wire pp11 = (A[3]&B[2]);
    wire pp12 = (A[0]&B[3]);
    wire pp13 = (A[1]&B[3]);
    wire pp14 = (A[2]&B[3]);
    wire pp15 = (A[3]&B[3]);

    // Suma de productos parciales
    wire [3:0] columna8 = 1'b0;
    wire [3:0] columna7 = pp15;
    wire [3:0] columna6 = pp11 + pp14;
    wire [3:0] columna5 = pp7 + pp10 + pp13;
    wire [3:0] columna4 = pp3 + pp6 + pp9 + pp12;
    wire [3:0] columna3 = pp2 + pp5 + pp8;
    wire [3:0] columna2 = pp1 + pp4;
    wire [3:0] columna1 = pp0;
    assign P = (columna8 << 7) + (columna7 << 6) + (columna6 << 5) + (columna5 << 4) + (columna4 << 3) + (columna3 << 2) + (columna2 << 1) + (columna1 << 0);

endmodule
