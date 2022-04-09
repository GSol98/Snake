HEX

\-------------------------
\   AUTOCONFIGURAZIONE
\------------------------

\ Autoconfigurazione base_register 
: AUTOCONFIG										\ (  -- b1 )
	3F003004 @
	5 DROP
	3F003004 @ =  IF
		FE000000		
	ELSE
		3F000000
	THEN
;
AUTOCONFIG CONSTANT BASE_REGISTER

\------------------
\   COSTANTI
\------------------

\ Indirizzo del registro dove sono
\ memorizzati i microsendi passati dall'avvio della macchina
BASE_REGISTER 3004 +  CONSTANT CLO
: GCLOCK CLO @ ;									\ (    -- b1 )


\--------------------
\	VARIABILI
\--------------------

\ Contiene il valore rgb del colore
\ scelto per il timer
VARIABLE TIMER_COLOR
: GTIMER_COLOR TIMER_COLOR @ ;						\ (    -- b1 )
: STIMER_COLOR TIMER_COLOR ! ;						\ ( a1 --    )

\ Contiene l'indirizzo del pixel di 
\ partenza in cui stampare il timer
VARIABLE TIMER_PIXEL
: GTIMER_PIXEL TIMER_PIXEL @ ;						\ (    -- b1 )
: STIMER_PIXEL TIMER_PIXEL ! ;						\ ( a1 --    )

\ Contiene la dimensione del timer
VARIABLE TIMER_SIZE
: GTIMER_SIZE TIMER_SIZE @ ;						\ (    -- b1 )
: STIMER_SIZE TIMER_SIZE ! ;						\ ( a1 --    )

\ Contiene i decimi di secondo passati
\ dall'avvio della macchina
VARIABLE TIMER
: GTIMER TIMER @ ;									\ (    -- b1 )
: STIMER TIMER ! ;									\ ( a1 --    )
: SAVE_TIMER GCLOCK 186A0 / STIMER ;				\ (    --    )

\ Contiene i minuti
VARIABLE MINUTES
: GMINUTES MINUTES @ ;								\ (    -- b1 )
: SET_MINUTES 0 MINUTES ! ;							\ (    --    )
: UPDATE_MINUTES 									\ (    --    )
	GMINUTES 1 +  DUP MINUTES ! 
	GTIMER_PIXEL SPIXEL  
	BLACK SCOLOR 
	GCHAR_SIZE 8 *  GCHAR_SIZE C *  PRINT_PIXEL
	GTIMER_COLOR SCOLOR
	DUP  A /  0 =  IF  0 PRINT_NUMBER  THEN
	PRINT_NUMBER
;

\ Contiene i secondi
VARIABLE SECONDS
: GSECONDS SECONDS @ ;								\ (    -- b1 )
: SET_SECONDS 0 SECONDS ! ;							\ (    --    )
: UPDATE_SECONDS 									\ (    --    )
	GSECONDS 1 + 
	DUP 3C =  IF  
		SET_SECONDS  
		UPDATE_MINUTES  
		DROP GSECONDS
	ELSE 
		DUP SECONDS ! 
	THEN 

	GTIMER_PIXEL SPIXEL
	E GCHAR_SIZE * INC_PIXEL_O  
	BLACK SCOLOR
	GCHAR_SIZE 8 *  GCHAR_SIZE C *  PRINT_PIXEL
	GTIMER_COLOR SCOLOR
	DUP  A / 0 =  IF  0 PRINT_NUMBER  THEN
	PRINT_NUMBER
;

\ Contiene i decimi di secondo
VARIABLE DECSECONDS
: GDECSECONDS DECSECONDS @ ;						\ (    -- b1 )
: SET_DECSECONDS 0 DECSECONDS ! ;					\ (    --    )
: UPDATE_DECSECONDS 								\ (    --    )
	GDECSECONDS 1 + 
	DUP A =  IF  
		SET_DECSECONDS 
		UPDATE_SECONDS  
		DROP GDECSECONDS
	ELSE 
		DUP DECSECONDS ! 
	THEN 

	GTIMER_PIXEL SPIXEL
	1C GTIMER_SIZE * INC_PIXEL_O  
	BLACK SCOLOR 
	GCHAR_SIZE 8 *  GCHAR_SIZE 5 *  PRINT_PIXEL
	GTIMER_COLOR SCOLOR
	PRINT_NUMBER
;

\--------------------
\       METODI
\--------------------

\ Inizializza il timer e lo stampa 
: SET_TIMER												\ (    --    )
	SET_MINUTES
	SET_SECONDS
	SET_DECSECONDS
	GTIMER_COLOR  SCOLOR
	GTIMER_PIXEL  SPIXEL 
	GTIMER_SIZE   SCHAR_SIZE
	GMINUTES	 DUP PRINT_NUMBER PRINT_NUMBER  .DP. PRINT_CHAR  GCHAR_SIZE 2 * INC_PIXEL_O
	GSECONDS 	 DUP PRINT_NUMBER PRINT_NUMBER  .DP. PRINT_CHAR  GCHAR_SIZE 2 * INC_PIXEL_O
	GDECSECONDS      PRINT_NUMBER 
;

\ Controlla se è il momento di 
\ aggiornare il timer
: CONTROL_TIMER									\ (    --    )
	GCLOCK 186A0 /
	DUP GTIMER <>  IF
		STIMER
		GTIMER_COLOR SCOLOR
		GTIMER_SIZE SCHAR_SIZE
		UPDATE_DECSECONDS
	ELSE
		DROP
	THEN
;
