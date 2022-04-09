HEX

\-------------------
\    VARIABILI
\-------------------

: JF-CREATE CREATE ;
: JF-WORD WORD ;
: CREATE JF-WORD JF-CREATE DOCREATE , ;

\ Contiene l'indirizzo del registro del pixel di 
\ partenza in una stampa
VARIABLE PIXEL
: GPIXEL PIXEL @ ;								\ (    -- b1 )
: SPIXEL PIXEL ! ;								\ ( a1 --    )
: INC_PIXEL_O  4    * GPIXEL + SPIXEL ;			\ ( a1 --    )
: INC_PIXEL_V  1000 * GPIXEL + SPIXEL ;			\ ( a1 --    )

\ Contiene il valore rgb del colore
\ scelto per la stampa
VARIABLE COLOR
: GCOLOR COLOR @ ;								\ (    -- b1 )
: SCOLOR COLOR ! ;							 	\ ( a1 --    )

\ Contiene la dimensione di un pixel
VARIABLE PIXEL_SIZE
: GPIXEL_SIZE PIXEL_SIZE @ ;					\ (    -- b1 )
: SPIXEL_SIZE PIXEL_SIZE ! ;					\ ( a1 --    )

\ Contiene la dimensione di un carattere
VARIABLE CHAR_SIZE
: GCHAR_SIZE CHAR_SIZE @ ;						\ (    -- b1 )
: SCHAR_SIZE CHAR_SIZE ! ;						\ ( a1 --    )

\ Contiene la codifica della prima
\ parte di una lettera
VARIABLE CHAR1
: GCHAR1 CHAR1 @ ;								\ (    -- b1 )
: SCHAR1 CHAR1 ! ;								\ ( a1 --    )

\ Contiene la codifica della seconda
\ parte di una lettera
VARIABLE CHAR2
: GCHAR2 CHAR2 @ ;								\ (    -- b1 )
: SCHAR2 CHAR2 ! ;								\ ( a1 --    )

\ Variabile temporanea usata
\ dal metodo PRINT_NUMBER
VARIABLE NUM_TEMP
: GNUM_TEMP NUM_TEMP @ ;						\ (    -- b1 )
: SNUM_TEMP NUM_TEMP ! ;						\ ( a1 --    )



\-----------------
\      METODI
\-----------------

\ Restituisce l'indirizzo del primo 
\ pixel dello schermo
: GFRAMEBUFFER  FRAMEBUFFER @ ;					\ (    -- b1 )

\ Subroutine in assembly per stampare a
\ schermo un rettangolo
CREATE PRINT_PIXEL_ASSEMBLY
e92d5000 , e59f0060 , e5900000 , e59f105c    , e5911000 ,
e1a02001 , e59f3054 , e0011003 , e59f3050    , e0022003 , 	
e1a02622 , e59f3048 , e5933000 , eb000001    , e8bd5000 , 	
e12fff1e , e1a04002 , e1a02004 , e4803004    , e2522001 , 
1afffffc , e1a02104 , e0500002 , e2800a01    , e2511001 , 
1afffff6 , e12fff1e ,  PIXEL   , PIXEL_SIZE  , 00000fff , 
00fff000 , COLOR ,

\ Interfaccia Forth di PRINT_PIXEL_ASSEMBLY
: PRINT_PIXEL 1000 * + SPIXEL_SIZE PRINT_PIXEL_ASSEMBLY JSR DROP ;	\ ( a1 a2 -- )

\ Subroutine in assembly per stampare a
\ schermo un carattere
CREATE PRINT_CHAR_ASSEMBLY
e92d4010 , e59f0144 , e5900000 , e59f1140 , e5911000 , 	
e59f213c , e5922000 , e59f3138 , e5933000 , e59f4134 , 	 
e5944000 , e1833404 , eb000001 , e8bd4010 , e12fff1e , 
e92d0030 , e92d00c0 , e92d4100 , e1a04000 , e1a05001 , 
e1a06002 , e3a07000 , e3c380ff , e1a08428 , e20330ff , 
e3a02020 , e1a00006 , e3a01001 , e0000001 , e3500000 , 
0a000005 , e1a00004 , e1a01003 , e92d000c , e1a03008 , 
eb00001b , e8bd000c , e0844103 , e2422001 , e1a060a6 , 
e0820007 , e3a01005 , eb000022 , e3500002 , 1a000005 , 
e3a01014 , e0000391 , e0444000 , e3a01a01 , e0000391 , 
e0844000 , e1a00002 , e3500000 , 1affffe3 , e3570002 , 
0a000003 , e3a07002 , e3a02008 , e1a06005 , eaffffdd , 
e8bd4100 , e8bd00c0 , e8bd0030 , e12fff1e , e92d1010 , 
e1a02001 , e1a04002 , e1a02004 , e4803004 , e2522001 , 	
1afffffc , e1a02104 , e0500002 , e2800a01 , e2511001 , 
1afffff6 , e8bd1010 , e12fff1e , e1500001 , ba000002 , 
e0400001 , e1500001 , aafffffc , e12fff1e , PIXEL    ,
CHAR1    , CHAR2    , CHAR_SIZE , COLOR   ,

\ Interfaccia Forth di PRINT_PIXEL_ASSEMBLY
: PRINT_CHAR SCHAR2 SCHAR1 PRINT_CHAR_ASSEMBLY JSR DROP ;		\ ( a1 a2 -- )

\ Effettua l'elevazione a potenza
: EXP															\ ( a1 a2 -- b1 )
	DUP 0 =  IF  DROP DROP 1  ELSE
	DUP 1 =  IF  DROP 	      ELSE
		SWAP DUP ROT
		BEGIN
			1 -  ROT ROT SWAP DUP ROT * ROT
		DUP 1 =  UNTIL
		DROP SWAP DROP
	THEN THEN
;

\ Codifica il numero in input
: CODE_NUMBER													\ ( a1 -- b1 b2 b3 )
	DUP 0 =  IF  74 6318C62E  ELSE
	DUP 1 =  IF  F9 084210E4  ELSE
	DUP 2 =  IF  F8 4444462E  ELSE
	DUP 3 =  IF  74 6106422E  ELSE
	DUP 4 =  IF  42 3E952988  ELSE
	DUP 5 =  IF  7C 2107843F  ELSE
	DUP 6 =  IF  74 6317862E  ELSE
	DUP 7 =  IF  21 0844421F  ELSE
	DUP 8 =  IF  74 6317462E  ELSE
				 74 610F462E  
	THEN THEN THEN THEN THEN THEN THEN THEN THEN
;

\ Stampa il numero in input
: PRINT_NUMBER 													\ ( a1 -- )
	DUP SNUM_TEMP  -1 SWAP
	BEGIN
		SWAP 1 +  SWAP A /
	DUP 0 =  UNTIL
	DROP
	BEGIN
		DUP A SWAP EXP  GNUM_TEMP SWAP /
		CODE_NUMBER  PRINT_CHAR  GCHAR_SIZE 6 * INC_PIXEL_O
		SWAP DUP  A SWAP EXP  ROT * GNUM_TEMP SWAP - SNUM_TEMP  1 -
	DUP -1 =  UNTIL
	DROP
;

\ Stampa le lettere in input
: PRINT_WORD										\ ( a1 ... an an+1 -- )
	DUP 6 * GCHAR_SIZE * INC_PIXEL_O
	BEGIN
		GCHAR_SIZE -6 * INC_PIXEL_O
		ROT ROT PRINT_CHAR
		1 -
	DUP 0 =  UNTIL
	DROP
;

\-----------------
\   COLORI
\-----------------

00FFFFFF CONSTANT WHITE
00FFFFFE CONSTANT WHITE1
00FF0000 CONSTANT RED
00000000 CONSTANT BLACK


\-----------------
\   CARATTERI
\-----------------

\ ( -- b1 b2 )
: .A. 8C 7F18C62E ;			
: .B. 7C 6317C62F ;
: .C. F0 4210843E ;
: .D. 7C 6318C62F ;
: .E. F8 4217843F ;
: .F. 08 4217843F ;
: .G. 74 6316843E ;
: .H. 8C 631FC631 ;
: .I. 71 0842108E ;
: .J. 32 5084211C ;
: .K. 8C 63149D31 ;
: .L. F8 42108421 ;
: .M. 8C 631AD771 ;
: .N. 8C 639ACE31 ;
: .O. 74 6318C62E ;
: .P. 08 42F8C62F ;
: .Q. 20 CA94A526 ;
: .R. 8A 4AF8C62F ;
: .S. 74 6107062E ;
: .T. 21 0842109F ;
: .U. 74 6318C631 ;
: .V. 21 14A54631 ;
: .W. 55 6B5AC631 ;
: .X. 8A 94422951 ;
: .Y. 21 08452A31 ;
: .Z. F8 4222221F ;
: .0. 74 6318C62E ;
: .1. F9 084210E4 ;
: .2. F8 4444462E ;
: .3. 74 6106422E ;
: .4. 42 3E952988 ;
: .5. 7C 2107843F ;
: .6. 74 6317862E ;
: .7. 21 0844421F ;
: .8. 74 6317462E ;
: .9. 74 610F462E ;
: .DP. 0 40008000 ;
: .SPACE. 0 0 ;
