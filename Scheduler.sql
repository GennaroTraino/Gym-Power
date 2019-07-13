-- JOB CHE CANCELLA ISCRITTI CHE NON HANNO RINNOVATO L'ABBONAMENTO DA PIU DI 6 MESI
BEGIN
DBMS_SCHEDULER.CREATE_JOB (
job_name			=> 'Cancella_Iscritto',
job_type			=> 'PLSQL_BLOCK',
job_action			=> 'BEGIN
							DELETE FROM ISCRITTO 
							WHERE CF_ISCRITTO IN (
								SELECT CF_ISCRITTO
    							FROM ISCRITTO JOIN ABBONAMENTO ON CF_ISCRITTO = CF_ISCRITTO_ABBONAMENTO
  								WHERE DATA_SCADENZA < SYSDATE - (30 * 6) );
						END;',
start_date        	=>  TO_DATE('01/12/2018', 'DD/MM/YYYY'),
repeat_interval		=> 'FREQ=MONTHLY', 
enabled				=>	TRUE,
comments			=> 'Cancella iscritti con abbonamenti non rinnovti da più di 6 mesi');
END;
/
