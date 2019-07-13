--TRIGGER PER CONTROLLARE CHE IL NUMERO DEGLI ESERCIZI IN UNA SCHEDA NON SIA MAGGIORE DI 6
CREATE OR REPLACE TRIGGER CONTROLLO_ESERCIZI_SCHEDA
BEFORE INSERT ON CONTIENE
FOR EACH ROW 
DECLARE 
	NUM_ES NUMBER;
	TROPPI_ESERCIZI EXCEPTION;

BEGIN

	SELECT COUNT(*) INTO NUM_ES
	FROM CONTIENE
	WHERE N_SCHEDA_FK = :NEW.N_SCHEDA_FK;

	IF (NUM_ES > 5) THEN RAISE TROPPI_ESERCIZI;
	END IF;

EXCEPTION 
	WHEN TROPPI_ESERCIZI THEN 
		RAISE_APPLICATION_ERROR(-20530,'TROPPI ESERCIZI IN QUESTA SCHEDA');
END;
/