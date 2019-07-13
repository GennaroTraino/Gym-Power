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


--SEQUENCE PER INSERIMENTO AUTOMATICO NUMERO SCHEDA
DROP SEQUENCE SEQ_N_SCHEDA;

CREATE SEQUENCE SEQ_N_SCHEDA
	START WITH 31
	INCREMENT BY 1
	NOMAXVALUE
	NOCYCLE;

--INSERIMENTO AUTOMATICO NUMERO SCHEDA
CREATE OR REPLACE TRIGGER N_SCHEDA
BEFORE INSERT ON SCHEDA_ESERCIZI
FOR EACH ROW 
WHEN (NEW.N_SCHEDA IS NULL)
--------------
DECLARE
	N_S NUMBER := SEQ_N_SCHEDA.NEXTVAL;
BEGIN 
	:NEW.N_SCHEDA := N_S;
END;
/


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


-- TRIGGER PER CONTROLLARE L'INSERIMENTO DI UN CORSO
CREATE OR REPLACE TRIGGER INSERIMENTO_CORSO
BEFORE INSERT ON CORSO
FOR EACH ROW

DECLARE 
	N_CORSI_ISTRUTTORE  NUMBER;
	N_CORSI_STRUTTURA  NUMBER;
	DATA_INFERIORE  EXCEPTION;
	TROPPO_LAVORO  EXCEPTION;
	TROPPI_CORSI  EXCEPTION;


BEGIN
-- NON SI PUO' INSERIRE UN CORSO CHE ABBIA DATA INIZIALE MINORE DELLA DATA CORRENTE
	IF(:NEW.DATA_INIZIO_CORSO < SYSDATE)
		THEN RAISE DATA_INFERIORE;
	END IF;

-- VERIFICA QUANTI CORSI STA TENENDO L'ISTRUTTORE IN CONTEMPORANEA
-- SE LAVORA A PIU DI 4 CORSI ALLORA LANCIA UN ECCEZIONE
	SELECT COUNT(*) INTO N_CORSI_ISTRUTTORE
	FROM ISTRUTTORE JOIN CORSO  ON CF_ISTRUTTORE = CF_ISTRUTTORE_CORSO
	WHERE CF_ISTRUTTORE_CORSO = :NEW.CF_ISTRUTTORE_CORSO 
		AND DATA_FINE_CORSO > SYSDATE;

	IF(N_CORSI_ISTRUTTORE > 3) 
		THEN RAISE TROPPO_LAVORO;
	END IF;


-- VERIFICA QUANTI CORSI TIENE UNA STRUTTURA CONTEMPORANEAMENTE,
-- SE CI SONO PIU' DI 8 CORSI LANCIA UN ECCEZIONE
	SELECT COUNT(*) INTO N_CORSI_STRUTTURA
	FROM CORSO JOIN STRUTTURA ON CAP_CORSO = CAP
	WHERE CAP_CORSO = :NEW.CAP_CORSO
		AND DATA_FINE_CORSO > SYSDATE;

	IF(N_CORSI_STRUTTURA > 8) 
		THEN RAISE TROPPI_CORSI;
	END IF;


EXCEPTION 
	WHEN DATA_INFERIORE THEN 
		RAISE_APPLICATION_ERROR(-20505,'E'' STATA INSERITA UNA DATA INIZIO CORSO PRECEDENTE A QUELLA DI OGGI');
	WHEN TROPPO_LAVORO THEN 
		RAISE_APPLICATION_ERROR(-20506,'ISTRUTTORE STA SEGUENDO GIA 4 CORSI');
	WHEN TROPPI_CORSI THEN 
		RAISE_APPLICATION_ERROR(-20507,'TROPPI CORSI PER QUESTA STRUTTURA');

END;
/


--SEQUENCE PER INSERIMENTO AUTOMATICO NUMERO SCHEDA
DROP SEQUENCE SEQ_N_BADGE;

CREATE SEQUENCE SEQ_N_BADGE
	START WITH 106 	
	INCREMENT BY 1
	NOMAXVALUE
	NOCYCLE;

--INSERIMENTO AUTOMATICO NUMERO BADGE
CREATE OR REPLACE TRIGGER N_BADGE
BEFORE 
INSERT ON ABBONAMENTO
FOR EACH ROW 
WHEN (NEW.BADGE IS NULL)
--------------
DECLARE
	N_S NUMBER := SEQ_N_BADGE.NEXTVAL;
BEGIN 
-- DIVIDO IL NUMERO PER 10000 E PRENDO SOLO LA PARTE DECIAMELE CONVERTITA IN CHAR PER NON PERDERE LO 0 INIZIALE!
	N_S := N_S/10000;

	:NEW.BADGE := SUBSTR(TO_CHAR(N_S,'9999.9999'),7,4);
END;
/


--TRIGGER CHE CONTROLLARE GLI ABBONAMENTI
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


CREATE OR REPLACE TRIGGER ISCRITTO_MINORENNE
BEFORE INSERT ON ISCRITTO
FOR EACH ROW 
DECLARE 
	MINORENNE EXCEPTION;

BEGIN
-- GLI ISCRITTI DEVONO ESSERE TUTTI MAGGIORENNI
	IF (((SYSDATE -:NEW.DATA_NASCITA)/365) < 18) THEN RAISE MINORENNE;
END IF;

EXCEPTION 
	WHEN MINORENNE THEN 
		RAISE_APPLICATION_ERROR(-20530,'ISCRITTO MINORENNE');
END;
/