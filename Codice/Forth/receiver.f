HEX

\-------------------------
\   AUTOCONFIGURAZIONE
\------------------------

\ Autoconfigurazione base_register 
: AUTOCONFIG							\ (  -- b1 )
	3F003004 @
	5 DROP
	3F003004 @ =  IF
		FE000000		
	ELSE
		3F000000
	THEN
;
AUTOCONFIG CONSTANT BASE_REGISTER

\---------------
\   COSTANTI
\---------------

\ Legge il bit del pin 9 (output del ricevitore)
BASE_REGISTER 200034 +  CONSTANT GPLEV0
: INPUT GPLEV0 @ 400000 * 80000000 / ;			\ (    -- b1 )

\ Indirizzo del registro dove sono
\ memorizzati i microsendi passati dall'avvio della macchina
BASE_REGISTER 3004 +  CONSTANT CLO
: GCLOCK CLO @ ;								\ (    -- b1 )


\------------------
\   VARIABILI
\------------------

\ Primo punto di campionamento
VARIABLE SAMPLE_POINT1		
: GSAMPLE_POINT1 SAMPLE_POINT1 @ ;				\ (    -- b1 )
: SSAMPLE_POINT1 SAMPLE_POINT1 ! ;				\ ( a1 --    )

\ Secondo punto di campionamento
VARIABLE SAMPLE_POINT2		
: GSAMPLE_POINT2 SAMPLE_POINT2 @ ;				\ (    -- b1 )
: SSAMPLE_POINT2 SAMPLE_POINT2 ! ;				\ ( a1 --    )

\ Terzo punto di campionamento
VARIABLE SAMPLE_POINT3		
: GSAMPLE_POINT3 SAMPLE_POINT3 @ ;				\ (    -- b1 )
: SSAMPLE_POINT3 SAMPLE_POINT3 ! ;				\ ( a1 --    )

\ Contiene la codifica del pulsante 2 
VARIABLE P2		
: GP2 P2 @ ;									\ (    -- b1 )
: SP2 P2 ! ;									\ ( a1 --    )

\ Contiene la codifica del pulsante 4
VARIABLE P4		
: GP4 P4 @ ;									\ (    -- b1 )
: SP4 P4 ! ;									\ ( a1 --    )

\ Contiene la codifica del pulsante 6 
VARIABLE P6		
: GP6 P6 @ ;									\ (    -- b1 )
: SP6 P6 ! ;									\ ( a1 --    )

\ Contiene la codifica del pulsante 8 
VARIABLE P8		
: GP8 P8 @ ;									\ (    -- b1 )
: SP8 P8 ! ;									\ ( a1 --    )

\ Contiene la codifica del pulsante PLAY
VARIABLE PP		
: GPP PP @ ;									\ (    -- b1 )
: SPP PP ! ;									\ ( a1 --    )

\ Contiene lo stato del metodo
\ CONTROL_RECEIVER
VARIABLE STATE_RECEIVER		
: GSTATE_RECEIVER STATE_RECEIVER @ ;			\ (    -- b1 )
: SSTATE_RECEIVER STATE_RECEIVER ! ;			\ ( a1 --    )

\ Variabile temporanea usata in CONTROL_RECEIVER
VARIABLE TIMESAMPLE
: GTIMESAMPLE TIMESAMPLE @ ;					\ (    -- b1 )
: STIMESAMPLE TIMESAMPLE ! ;					\ ( a1 --    )

\ Contiene il valore campionato
VARIABLE SAMPLE
: GSAMPLE SAMPLE @ ;							\ (    -- b1 )
: SSAMPLE SAMPLE ! ;							\ ( a1 --    )



\-----------------
\      METODI
\-----------------

\ Caricano sullo stack i valori di campionamento
\ personali
: ENRICO    							\ (     -- b1 b2 b3 b4 b5 b6 b7 b8 )
	A410  A85C  B0F4  
	0 3 4 2 5	
;			

: GIULIANO  							\ (     -- b1 b2 b3 b4 b5 b6 b7 b8 )
	B284  BB99  BFFE 
	1 6 2 0 5 
;					

\ Imposta i punti di campionamento e le 
\ codifiche dei campioni
: SET_RECEIVER 							\ ( a1 a2 a3 a4 a5 a6 a7 a8 --     )
	SP8  SP6  SPP  SP4  SP2
	SSAMPLE_POINT3
	SSAMPLE_POINT2
	SSAMPLE_POINT1
;

\ Decodifica i bit ricevuti
: DECODE 								\ ( a1 a2 a3 --  b1 )
	SWAP 2 * +
	SWAP 4 * +
	DUP GP2 =  IF  2  ELSE 
	DUP GP4 =  IF  4  ELSE 
	DUP GPP =  IF  5  ELSE 
	DUP GP6 =  IF  6  ELSE 
	DUP GP8 =  IF  8  ELSE 
				  -1 
	THEN THEN THEN THEN THEN 
	SWAP DROP
;

\ Secondo metodo che permette la ricezione
\ di un valore tramite infrarossi
: CONTROL_RECEIVER1												\ (    --    )
	GSTATE_RECEIVER 
	DUP   0 =  IF
		INPUT  0 =  IF  1 SSTATE_RECEIVER  THEN
	ELSE
		DUP 2 =  IF
			GCLOCK GTIMESAMPLE - GSAMPLE_POINT1 1388 - >  IF
				BEGIN  GCLOCK GTIMESAMPLE - GSAMPLE_POINT1 >  UNTIL  INPUT
				BEGIN  GCLOCK GTIMESAMPLE - GSAMPLE_POINT2 >  UNTIL  INPUT
				BEGIN  GCLOCK GTIMESAMPLE - GSAMPLE_POINT3 >  UNTIL  INPUT

				DECODE SSAMPLE 3 SSTATE_RECEIVER  GCLOCK STIMESAMPLE
			THEN
		ELSE
			DUP 1 =  IF
				BEGIN  INPUT  1 =  UNTIL
				GCLOCK STIMESAMPLE  2 SSTATE_RECEIVER
			ELSE
				GCLOCK GTIMESAMPLE - 13880 >  IF  0 SSTATE_RECEIVER  THEN 
	THEN THEN THEN
	DROP
;

\ Interfaccia che sfrutta CONTROL_RECEIVER1 
\ e blocca il flusso di esecuzione
: CONTROL_RECEIVER2								\ (  --  )
	1 SSTATE_RECEIVER
	BEGIN  INPUT 0 =  UNTIL
	BEGIN
		CONTROL_RECEIVER1 
	GSTATE_RECEIVER 0 =  UNTIL
;



\-----------------------
\        EXTRA
\-----------------------

\ Variabile temporanea usata in RECEIVE_BITS
VARIABLE TIME
: GTIME TIME @ ;								\ (    -- b1 )
: STIME TIME ! ;								\ ( a1 --    )

\ Contatore utilizzato in SAMPLES
VARIABLE COUNT
: GCOUNT COUNT @ ;								\ (    -- b1 )
: SCOUNT COUNT ! ;								\ ( a1 --    )
: INC_COUNT GCOUNT 1 + SCOUNT ;					\ (    --    )

\ Contiene il range selezionato
\ per il campionamento
VARIABLE RANGE
: GRANGE RANGE @ ;								\ (    -- b1 )
: SRANGE RANGE ! ;								\ ( a1 --    )

\ Campiona i bit del range selezionato
: SAMPLES 										\ (    --    )
    0 SCOUNT 
	0 SSAMPLE 
	BEGIN  INPUT 1 <>  UNTIL
	GCLOCK STIME  2710 GRANGE * 
	BEGIN  DUP  GCLOCK GTIME -  <  UNTIL 
	DROP 

    BEGIN 
        INPUT 
        DUP GSAMPLE <>  IF  
            DUP SSAMPLE  INC_COUNT  GCLOCK GTIME -
        ELSE
            DROP
        THEN 
    GCLOCK GTIME - 2710 GRANGE 1 + * >  UNTIL 

    GCOUNT 2 * SCOUNT 
    BEGIN  
        DECIMAL . HEX
        GCOUNT 2 MOD 1 =  IF  CR  THEN 
        GCOUNT 0 <>  IF  GCOUNT  1 - SCOUNT  THEN
    GCOUNT 0 = UNTIL 
;
