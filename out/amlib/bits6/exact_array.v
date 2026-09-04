// Multiplicador array EXACTO de 6 bits - referencia de normalizacion
// Baseline exacto: normaliza area/potencia frente a los aproximados.
//
// Estilo RTL identico al de los circuitos generados por los agentes
// (suma por columnas) para que la comparacion de area sea justa.
// Generado para el flujo LibreLane de out/Makefile. Top: multiplier(A,B,P).


`timescale 1ns/1ps
module multiplier (
    input  [5:0] A,
    input  [5:0] B,
    output [11:0] P);

    // Generacion de productos parciales
    wire pp0 = (A[0]&B[0]);
    wire pp1 = (A[1]&B[0]);
    wire pp2 = (A[2]&B[0]);
    wire pp3 = (A[3]&B[0]);
    wire pp4 = (A[4]&B[0]);
    wire pp5 = (A[5]&B[0]);
    wire pp6 = (A[0]&B[1]);
    wire pp7 = (A[1]&B[1]);
    wire pp8 = (A[2]&B[1]);
    wire pp9 = (A[3]&B[1]);
    wire pp10 = (A[4]&B[1]);
    wire pp11 = (A[5]&B[1]);
    wire pp12 = (A[0]&B[2]);
    wire pp13 = (A[1]&B[2]);
    wire pp14 = (A[2]&B[2]);
    wire pp15 = (A[3]&B[2]);
    wire pp16 = (A[4]&B[2]);
    wire pp17 = (A[5]&B[2]);
    wire pp18 = (A[0]&B[3]);
    wire pp19 = (A[1]&B[3]);
    wire pp20 = (A[2]&B[3]);
    wire pp21 = (A[3]&B[3]);
    wire pp22 = (A[4]&B[3]);
    wire pp23 = (A[5]&B[3]);
    wire pp24 = (A[0]&B[4]);
    wire pp25 = (A[1]&B[4]);
    wire pp26 = (A[2]&B[4]);
    wire pp27 = (A[3]&B[4]);
    wire pp28 = (A[4]&B[4]);
    wire pp29 = (A[5]&B[4]);
    wire pp30 = (A[0]&B[5]);
    wire pp31 = (A[1]&B[5]);
    wire pp32 = (A[2]&B[5]);
    wire pp33 = (A[3]&B[5]);
    wire pp34 = (A[4]&B[5]);
    wire pp35 = (A[5]&B[5]);

    // Suma de productos parciales
    wire [5:0] columna12 = 1'b0;
    wire [5:0] columna11 = pp35;
    wire [5:0] columna10 = pp29 + pp34;
    wire [5:0] columna9 = pp23 + pp28 + pp33;
    wire [5:0] columna8 = pp17 + pp22 + pp27 + pp32;
    wire [5:0] columna7 = pp11 + pp16 + pp21 + pp26 + pp31;
    wire [5:0] columna6 = pp5 + pp10 + pp15 + pp20 + pp25 + pp30;
    wire [5:0] columna5 = pp4 + pp9 + pp14 + pp19 + pp24;
    wire [5:0] columna4 = pp3 + pp8 + pp13 + pp18;
    wire [5:0] columna3 = pp2 + pp7 + pp12;
    wire [5:0] columna2 = pp1 + pp6;
    wire [5:0] columna1 = pp0;
    assign P = (columna12 << 11) + (columna11 << 10) + (columna10 << 9) + (columna9 << 8) + (columna8 << 7) + (columna7 << 6) + (columna6 << 5) + (columna5 << 4) + (columna4 << 3) + (columna3 << 2) + (columna2 << 1) + (columna1 << 0);

endmodule
