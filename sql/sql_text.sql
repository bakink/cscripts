SET HEA ON LIN 500 PAGES 100 TAB OFF FEED OFF ECHO OFF VER OFF TRIMS ON TRIM ON TI OFF TIMI OFF;
SET SERVEROUT OFF;
SET LONG 5000 LONGC 500;

ACC sql_id PROMPT 'SQL_ID: ';

SELECT sql_text FROM v$sql WHERE sql_id = '&&sql_id' AND ROWNUM = 1
/

SELECT sql_text FROM dba_hist_sqltext WHERE sql_id = '&&sql_id' AND ROWNUM = 1
/
