--TRIGGER CONTROLLO TURNI DI UN ISTRUTTORE
CREATE OR REPLACE TRIGGER CONTROLLO_TURNO
BEFORE INSERT ON TURNO 
FOR EACH ROW

DECLARE 
	TROPPI_TURNI EXCEPTION;
	TURNI NUMBER;
	TROPPI_TURNI_MESE EXCEPTION;
	TURNI_M NUMBER;

BEGIN
--VERIFICA TURNI DI UN ISTRUTTORE
	SELECT COUNT(*) INTO TURNI
	FROM TURNO
	WHERE DATA_TURNO = :NEW.DATA_TURNO;

--SE SVOLGE PIU' DI UN TURNO LANCIA UN ERRORE
	IF (TURNI > 1) THEN RAISE TROPPI_TURNI;
	END IF;


--VERIFICA TURNI DI UN ISTRUTTORE IN UN MESE SOLARE
	SELECT COUNT(*) INTO TURNI_M
	FROM TURNO
	WHERE TO_CHAR(DATA_TURNO,'MON-YEAR') = TO_CHAR(:NEW.DATA_TURNO,'MON-YEAR');

--SE SVOLGE PIU DI 27 TURNI AL MESE LANCIA ERRORE
	IF (TURNI_M > 26) THEN RAISE TROPPI_TURNI_MESE;
	END IF;

EXCEPTION 
WHEN TROPPI_TURNI THEN
		RAISE_APPLICATION_ERROR(-20456,'TROPPI TURNI PER QUESTO ISTRUTTORE');
WHEN TROPPI_TURNI_MESE THEN
		RAISE_APPLICATION_ERROR(-20543,'QUESTO ISTRUTTORE HA FATTO GIA 27 TURNI QUESTO MESE');
END;
/
	