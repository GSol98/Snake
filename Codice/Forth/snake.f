
\------------------------
\   RIFERIMENTI SCHERMO
\------------------------

GFRAMEBUFFER 84010  +  CONSTANT BHL
GFRAMEBUFFER 2FBFEC +  CONSTANT BLR



\-------------------
\    VARIABILI
\-------------------

\ Contiene l'indirizzo del pixel in cui
\ si trova la testa in ongi istante
VARIABLE  REF_HEAD
: GHEAD   REF_HEAD @ ;                                          \ (    -- b1 )
: SHEAD   REF_HEAD ! ;                                          \ ( a1 --    )

\ Contiene l'indirizzo del pixel in cui
\ si trova la coda in ongi istante
VARIABLE  REF_TAIL
: GTAIL   REF_TAIL @ ;                                          \ (    -- b1 )
: STAIL   REF_TAIL ! ;                                          \ ( a1 --    )

\ Contiene lo stato del serpente
\ 0 -> vivo ,  1 -> morto
VARIABLE DEAD
: GDEAD   DEAD @ ;                                              \ (    -- b1 )
: SDEAD   DEAD ! ;                                              \ ( a1 --    )

\ Contiene le direzioni di testa e coda
VARIABLE SNAKE_DIR
: GSNAKE_DIR   SNAKE_DIR @ ;                                    \ (    -- b1 )
: SSNAKE_DIR   SNAKE_DIR ! ;                                    \ ( a1 --    )

\ Consentono di accedere in maniera diretta 
\ ai bit memorizzati nella variabile SNAKE_DIR
: GHEAD_DIR   GSNAKE_DIR 3 AND ;                                \ (    -- b1 )
: GTAIL_DIR   GSNAKE_DIR C AND 4 / ;                            \ (    -- b1 )
: SHEAD_DIR   GSNAKE_DIR C AND +  SSNAKE_DIR ;                  \ ( a1 --    )
: STAIL_DIR   4 * GSNAKE_DIR 3 AND +  SSNAKE_DIR ;              \ ( a1 --    )


\ Contiene il punteggio
VARIABLE SCORE
: GSCORE   SCORE @ ;                                            \ (  -- b1 )
: SET_SCORE   0 SCORE ! ;                                       \ (  --    )
: UPDATE_SCORE                                                  \ (  --    )
	3E9142A8 SPIXEL  BLACK SCOLOR  GSCORE DUP PRINT_NUMBER
	3E9142A8 SPIXEL  WHITE SCOLOR  1 +    DUP PRINT_NUMBER
	SCORE !
;

\ Contiene l'indirizzo del pixel in cui si trova la mela 
VARIABLE APPLE                                  
: GAPPLE  APPLE @ ;                                             \ (    -- b1 )
: SAPPLE  APPLE ! ;                                             \ ( a1 --    )

\ Contiene lo stato di CHECK_APPLE
VARIABLE STATE_APPLE                                  
: GSTATE_APPLE  STATE_APPLE @ ;                                 \ (    -- b1 )
: SSTATE_APPLE  STATE_APPLE ! ;                                 \ ( a1 --    )


\---------------
\    METODI 
\---------------

\ Incrementa orizzontalmente un indirizzo
\ del numero di pixel passati in input
: INC_O                                                         \ ( a1 a2 -- b1 )
    4 * + 
    DUP   FFFFF000 AND   
    SWAP  00000FFF AND 
    DUP  FEC >  IF  FE0 -  ELSE 
    DUP  010 <  IF  FE0 +  THEN THEN + 
;

\ Incrementa verticalmente un indirizzo
\ del numero di pixel passati in input
: INC_V                                                         \ ( a1 a2 -- b1 )
    1000 * +  
    DUP   FF000FFF AND
    SWAP  00FFF000 AND 
    DUP   BF5000 >  IF  278000 - ELSE
    DUP   97E000 <  IF  278000 + THEN THEN + 
;  

\ Controlla il colore dei pixel di fronte al serpente 
: CHECK_FORWARD                                                             \ (  -- b1 )
	GHEAD  GHEAD_DIR   
	DUP  0 =  IF  DROP  4 INC_O  DUP  -3 INC_V @  SWAP  3 INC_V @  ELSE 
	DUP  1 =  IF  DROP  4 INC_V  DUP  -3 INC_O @  SWAP  3 INC_O @  ELSE
	DUP  2 =  IF  DROP -4 INC_O  DUP  -3 INC_V @  SWAP  3 INC_V @  ELSE 
	              DROP -4 INC_V  DUP  -3 INC_O @  SWAP  3 INC_O @   
	THEN  THEN  THEN 
    GCOLOR =  SWAP  GCOLOR =  OR
;


\------------
\    MELA
\------------

\ Stampa la mela 7x7 in un punto casuale libero dello schermo
: PRINT_APPLE                                                               \ (  -- b1)
    GCLOCK       
    BEGIN                                                 
		GHEAD GCLOCK DUP INC_O -1 * INC_V  BLR BHL -  MOD  BHL +  DUP SAPPLE
		DUP @                   BLACK <>                  IF  0  ELSE
		DUP 1C   + @            BLACK <>                  IF  0  ELSE
		DUP 7000 + DUP @        BLACK <>  SWAP BLR >  OR  IF  0  ELSE
		DUP 1C +  7000 + DUP @  BLACK <>  SWAP BLR >  OR  IF  0  ELSE
		                                                     -1  
        THEN  THEN  THEN  THEN
    NIP DUP ROT  GCLOCK SWAP -  2BC >  OR  UNTIL

 	IF GAPPLE SPIXEL  RED SCOLOR  7 7 PRINT_PIXEL  0  ELSE  1  THEN
;

\ Incrementa la lunghezza del serpente e cancella
\ la mela appena mangiata
: EAT   GTAIL GTAIL_DIR                                                     \ (  --  ) 
    DUP  0 =  IF  DROP -7 INC_O DUP  -3 INC_O -3 INC_V SPIXEL  ELSE
    DUP  1 =  IF  DROP -7 INC_V DUP  -3 INC_V -3 INC_O SPIXEL  ELSE
    DUP  2 =  IF  DROP  7 INC_O DUP  -4 INC_O -3 INC_V SPIXEL  ELSE
                  DROP  7 INC_V DUP  -4 INC_V -3 INC_O SPIXEL   
    THEN THEN THEN 
    STAIL
    WHITE1 SCOLOR  7 7 PRINT_PIXEL

    GAPPLE SPIXEL  BLACK SCOLOR  7 7 PRINT_PIXEL   
;

\ In base al suo stato consente al serpente di
\ mangiare la mela e incrementare il punteggio
\ o stampa una nuova mela   
: CHECK_APPLE                                                       \ (  --  )
    GSTATE_APPLE  0 = IF
        RED SCOLOR  CHECK_FORWARD  IF 
            EAT  UPDATE_SCORE  1 SSTATE_APPLE  
        THEN
    ELSE
        PRINT_APPLE  SSTATE_APPLE
    THEN
;

\-------------------
\     SERPENTE
\-------------------

\ Stampa il serpente sullo schermo
: PRINT_SNAKE                                                       \ (  --  )
	WHITE1 SCOLOR  
	GFRAMEBUFFER 1BF670 +  SPIXEL  7 C8 PRINT_PIXEL 
	GFRAMEBUFFER 1C2980 +  SHEAD
	GFRAMEBUFFER 1C267C +  STAIL
	0 SDEAD
	0 SSNAKE_DIR
    0 SSTATE_APPLE
;

\ Controlla se il serpente ha sbattuto su se stesso
: CHECK_DEAD   WHITE1 SCOLOR  CHECK_FORWARD  IF  1 SDEAD  THEN ;        \ (  --  )

\ Muove la testa o la coda del serpente stampando 
\ delle righe o colonne bianche o nere
: MOVE                                                                  \ ( a1 a2 a3 a4 --   )
    0 = IF  SHEAD  ELSE  STAIL  THEN
    SWAP
    DUP  0 =  SWAP  2 =  OR  IF  
        -4 INC_V  7
        BEGIN
            SWAP 1 INC_V DUP GCOLOR SWAP ! 
            SWAP 1 - DUP
        0 =  UNTIL  DROP DROP  
    ELSE  
        -4 INC_O  7
        BEGIN
            SWAP 1 INC_O DUP GCOLOR SWAP ! 
            SWAP 1 - DUP
        0 =  UNTIL  DROP DROP  
    THEN 
;

\ Lascia sullo stack tutti i dati necessari a MOVE per
\ muovere la testa e stampare una riga o colonna bianca
: HEAD                                                                  \ (  -- b1 b2 b3 b4 )
    GHEAD GHEAD_DIR
    DUP 0 =  IF  SWAP  1 INC_O  DUP  3 INC_O   ELSE
    DUP 1 =  IF  SWAP  1 INC_V  DUP  3 INC_V   ELSE
    DUP 2 =  IF  SWAP -1 INC_O  DUP -3 INC_O   ELSE
                 SWAP -1 INC_V  DUP -3 INC_V    
    THEN THEN THEN  

    WHITE1 SCOLOR  SWAP  0
;

\ Lascia sullo stack tutti i dati necessari a MOVE per
\ muovere la coda e stampare una riga o colonna nera
: TAIL                                                                  \ (  -- b1 b2 b3 b4 )                  
    0
    GTAIL  4 INC_O @  WHITE1 =  IF  1 +  0 SWAP  THEN 
    GTAIL  4 INC_V @  WHITE1 =  IF  1 +  1 SWAP  THEN
    GTAIL -4 INC_O @  WHITE1 =  IF  1 +  2 SWAP  THEN
    GTAIL -4 INC_V @  WHITE1 =  IF  1 +  3 SWAP  THEN
    
    2 =  IF  2DROP  GTAIL_DIR  THEN 

    GTAIL SWAP 
    DUP 0 = IF  SWAP  DUP -3 INC_O  SWAP  1 INC_O  ELSE
    DUP 1 = IF  SWAP  DUP -3 INC_V  SWAP  1 INC_V  ELSE
    DUP 2 = IF  SWAP  DUP  3 INC_O  SWAP -1 INC_O  ELSE
                SWAP  DUP  3 INC_V  SWAP -1 INC_V  
    THEN  THEN  THEN 

    ROT DUP STAIL_DIR  ROT ROT  BLACK SCOLOR  1
;


\ Controlla il valore contenuto nella variabile SAMPLE 
\ e in base a questo modifica la direzione del serpente
: CONTROL_DIRECTION                                                         \ (  --  )
    GHEAD_DIR  GSAMPLE
    DUP 2 = IF  DROP DUP  0 =  SWAP  2 =  OR IF  3 SHEAD_DIR  THEN  ELSE
    DUP 4 = IF  DROP DUP  1 =  SWAP  3 =  OR IF  2 SHEAD_DIR  THEN  ELSE
    DUP 6 = IF  DROP DUP  1 =  SWAP  3 =  OR IF  0 SHEAD_DIR  THEN  ELSE
    DUP 8 = IF  DROP DUP  0 =  SWAP  2 =  OR IF  1 SHEAD_DIR  THEN  ELSE
                2DROP
    THEN THEN THEN THEN
;

\ Svolge tutti i controlli necessari 
\ e muove il serpente
: CONTROL_SNAKE                                             \ (  --  )                          
    CONTROL_DIRECTION
    CHECK_APPLE
    CHECK_DEAD
    HEAD MOVE
    TAIL MOVE
;
