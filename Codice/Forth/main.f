\-------------------
\       METODI
\-------------------

\ Struttura GAME_OVER
: GAME_OVER											\ (    --    )
	INITIALIZE_GAME_OVER
	CONTROL_BUTTONS
	0 = IF  INITIALIZE_PLAY  THEN
;

\ Struttura SELECTION
: SELECTION											\ (    --  b1 )
    INITIALIZE_SELECTION
    CONTROL_BUTTONS
;

\ Struttura PLAY
: PLAY												\ (    --    )
	INITIALIZE_PLAY
	BEGIN 
		GCLOCK
		CONTROL_RECEIVER1
		BEGIN  DUP GCLOCK SWAP - 7D0 >  UNTIL

		GSAMPLE 5 = IF  PAUSE_INTERFACE  THEN

        CONTROL_SNAKE
		CONTROL_TIMER
        GDEAD 1 = IF  GAME_OVER  THEN
        BEGIN  DUP GCLOCK SWAP - FA0 >  UNTIL
		
		DROP
	GDEAD 1 =  UNTIL
;

\ Struttura END_GAME
: END_GAME											\ (    --    )
	CLEAR		
;

\ Struttura GAME
: GAME												\ (    --    )
	SELECTION
	0 =  IF  PLAY  THEN
	END_GAME
;
