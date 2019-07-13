CREATE OR REPLACE TRIGGER ISTRUTTORE_ABILITATO
BEFORE INSERT ON ISTRUTTORE
FOR EACH ROW 
DECLARE 
	NO_ABILITATO EXCEPTION;

BEGIN

	IF (((SYSDATE -:NEW.DATA_NASCITA)/365) < 25) THEN RAISE NO_ABILITATO;
	END IF;

EXCEPTION 
	WHEN NO_ABILITATO THEN 
		RAISE_APPLICATION_ERROR(-20504,'ISTRUTTORE NON ABILITATO');
END;
/