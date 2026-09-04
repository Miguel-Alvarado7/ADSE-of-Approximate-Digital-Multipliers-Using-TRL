// BAM (Broken-Array Multiplier) 2 bits, HOR=0 VER=1
// Mahdiani, Ahmadi, Fakhraie & Lucas, IEEE TCAS-I 57(4), 2010. Reimplementacion parametrica: el RTL de AM-Lib esta desenrollado a 16 bits. Regla identica a AM-Lib: pp(i,j) se conserva si j>=HOR y (i+j)>=VER.
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
    wire pp0 = (A[1]&B[0]);
    wire pp1 = (A[0]&B[1]);
    wire pp2 = (A[1]&B[1]);

    // Suma de productos parciales
    wire [1:0] columna4 = 1'b0;
    wire [1:0] columna3 = pp2;
    wire [1:0] columna2 = pp0 + pp1;
    wire [1:0] columna1 = 1'b0;
    assign P = (columna4 << 3) + (columna3 << 2) + (columna2 << 1) + (columna1 << 0);

endmodule
