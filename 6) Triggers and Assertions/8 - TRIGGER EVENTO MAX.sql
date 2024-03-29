CREATE OR REPLACE TRIGGER CONTROLLO_EVENTI
BEFORE INSERT ON EVENTO
FOR EACH ROW 
DECLARE 
	N_EVENTI NUMBER;
	TROPPI_EVENTI EXCEPTION;

BEGIN
-- CONTROLLA IL NUMERO DI EVENTI IN UNA STRUTTURA
-- NON DEVONO ESSERE PIU DI 4 IN UN GIORNO
	SELECT COUNT(*) INTO N_EVENTI
	FROM EVENTO
	WHERE CAP_EVENTO = :NEW.CAP_EVENTO AND DATA = :NEW.DATA;

	IF (N_EVENTI > 3 AND :NEW.DATA > SYSDATE)
		THEN RAISE TROPPI_EVENTI;
	END IF;

EXCEPTION 
	WHEN TROPPI_EVENTI THEN 
		RAISE_APPLICATION_ERROR(-20510,'TROPPI EVENTI NELLA STESSA DATA');
	
END;
/