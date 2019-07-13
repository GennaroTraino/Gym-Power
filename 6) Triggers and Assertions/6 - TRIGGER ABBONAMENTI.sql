CREATE OR REPLACE TRIGGER CONTROLLO_ABBONAMENTO
BEFORE INSERT ON PREVEDE
FOR EACH ROW

DECLARE
CORSI_SEDE_DIV 		NUMBER;
CORSO_SEDE_DIVERSA 	EXCEPTION;
N_CORSI	NUMBER;
TROPPI_CORSI EXCEPTION;

BEGIN

-- CONTROLLA CON UNA VARIABILE NUMERICA SE L ABBONAMENTO HA GIA CORSI CON SEDE DIVERSA
	SELECT COUNT(*) INTO CORSI_SEDE_DIV
	FROM PREVEDE
	WHERE CAP_CORSO_FK <> :NEW.CAP_CORSO_FK;

	IF(CORSI_SEDE_DIV > 0) THEN RAISE CORSO_SEDE_DIVERSA;
	END IF;

-- VERIFICA QUANTI CORSI CI SONO IN UN ABBONAMENTO
-- SE PIU' DI 2 CORSI LANCIA ECCEZIONE
	SELECT COUNT(*) INTO N_CORSI
	FROM PREVEDE
	WHERE BADGE_FK = :NEW.BADGE_FK;	

	IF(N_CORSI > 1)
		THEN RAISE TROPPI_CORSI;
	END IF;


EXCEPTION

WHEN CORSO_SEDE_DIVERSA THEN
	RAISE_APPLICATION_ERROR(-20543,'IL CORSO HA UNA SEDE DIVERSA RISPETTO AGLI ALTRI GIA PRESENTI NELL ABBONAMENTO');
WHEN TROPPI_CORSI THEN
	RAISE_APPLICATION_ERROR(-21001, 'TROPPI CORSI PER QUESTO ABBONAMENTO');
END;
/