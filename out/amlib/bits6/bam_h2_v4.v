// BAM (Broken-Array Multiplier) 6 bits, HOR=2 VER=4
// Mahdiani, Ahmadi, Fakhraie & Lucas, IEEE TCAS-I 57(4), 2010. Reimplementacion parametrica: el RTL de AM-Lib esta desenrollado a 16 bits. Regla identica a AM-Lib: pp(i,j) se conserva si j>=HOR y (i+j)>=VER.
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
    wire pp0 = (A[2]&B[2]);
    wire pp1 = (A[3]&B[2]);
    wire pp2 = (A[4]&B[2]);
    wire pp3 = (A[5]&B[2]);
    wire pp4 = (A[1]&B[3]);
    wire pp5 = (A[2]&B[3]);
    wire pp6 = (A[3]&B[3]);
    wire pp7 = (A[4]&B[3]);
    wire pp8 = (A[5]&B[3]);
    wire pp9 = (A[0]&B[4]);
    wire pp10 = (A[1]&B[4]);
    wire pp11 = (A[2]&B[4]);
    wire pp12 = (A[3]&B[4]);
    wire pp13 = (A[4]&B[4]);
    wire pp14 = (A[5]&B[4]);
    wire pp15 = (A[0]&B[5]);
    wire pp16 = (A[1]&B[5]);
    wire pp17 = (A[2]&B[5]);
    wire pp18 = (A[3]&B[5]);
    wire pp19 = (A[4]&B[5]);
    wire pp20 = (A[5]&B[5]);

    // Suma de productos parciales
    wire [5:0] columna12 = 1'b0;
    wire [5:0] columna11 = pp20;
    wire [5:0] columna10 = pp14 + pp19;
    wire [5:0] columna9 = pp8 + pp13 + pp18;
    wire [5:0] columna8 = pp3 + pp7 + pp12 + pp17;
    wire [5:0] columna7 = pp2 + pp6 + pp11 + pp16;
    wire [5:0] columna6 = pp1 + pp5 + pp10 + pp15;
    wire [5:0] columna5 = pp0 + pp4 + pp9;
    wire [5:0] columna4 = 1'b0;
    wire [5:0] columna3 = 1'b0;
    wire [5:0] columna2 = 1'b0;
    wire [5:0] columna1 = 1'b0;
    assign P = (columna12 << 11) + (columna11 << 10) + (columna10 << 9) + (columna9 << 8) + (columna8 << 7) + (columna7 << 6) + (columna6 << 5) + (columna5 << 4) + (columna4 << 3) + (columna3 << 2) + (columna2 << 1) + (columna1 << 0);

endmodule
