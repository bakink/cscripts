CREATE OR REPLACE PACKAGE &&1..iod_sess AUTHID CURRENT_USER AS
/* $Header: iod_sess.pks.sql &&library_version. carlos.sierra $ */
/* ------------------------------------------------------------------------------------ */
--
-- Purpose:     Lock related API(s)
--
-- Author:      Carlos Sierra (based on prior work from Ashish Shanbhag)
--
-- Usage:       Execute from CDB$ROOT.
--
--              AUDIT_AND_DISCONNECT
--                  AUDITs INACTIVE sessions.
--                  Kills inactive sessions holding a lock on an application table for 
--                  over N seconds. (e.g. KievTransactions).
--                  Kills also sniped sessions.
--
-- Example:     Execute 120 times, 30 seconds apart, during a 1hr interval.
--              Interval must be consistent with OEM job frequency (e.g. 1h, or 4h, or 1d)
--              (For 1h interval, 30s apart, you need 60m x 2pm = 120 executions.)
--              (For 24h interval, 20s appart, you need 1440m x 3pm = 4320 executions.)
--  
-- Note:        Parameter expire date is to allow short executions of API(s), so a 
--              potential new version of this library can be compiled between two
--              consecutive calls when the gap between them is short (e.g. 30 secs).
-- 
/* ------------------------------------------------------------------------------------ */
gk_package_version            CONSTANT VARCHAR2(30)  := '&&library_version.'; -- used to circumvent ORA-04068: existing state of packages has been discarded
gk_table_name                 CONSTANT VARCHAR2(30)  := 'KIEVTRANSACTIONS'; -- table for TM and TX locks
gk_lock_secs_thres            CONSTANT NUMBER        := 30; -- kill inactive sessions with TM or TX locks on gk_table_name over this time (in secs)
gk_inac_secs_thres            CONSTANT NUMBER        := 3600; -- kill inactive sessions over this time (in secs)
gk_snip_secs_thres            CONSTANT NUMBER        := 300; -- seconds for an inactive session to become snip candidate
gk_snip_idle_profile          CONSTANT VARCHAR2(30)  := 'APP_PROFILE'; -- application profile with idle_time set to gk_snip_secs_thres (in mins)
gk_snip_candidates            CONSTANT VARCHAR2(1)   := 'Y'; -- include snip candidates
gk_sniped_sessions            CONSTANT VARCHAR2(1)   := 'Y'; -- include snipped sessions regardless of lock type and object
gk_tm_locks                   CONSTANT VARCHAR2(1)   := 'Y'; -- include TM (DML) locks
gk_tx_locks                   CONSTANT VARCHAR2(1)   := 'Y'; -- include TX (Transaction) locks
gk_kill_locked                CONSTANT VARCHAR2(1)   := 'Y'; -- kill sessions holding TX/TM lock
gk_kill_idle                  CONSTANT VARCHAR2(1)   := 'N'; -- kill sessions waiting long or sniped
gk_expire_date                CONSTANT DATE          := SYSDATE + (1/24); -- execute api only if its call has not expired
gk_date_format                CONSTANT VARCHAR2(30)  := 'YYYY-MM-DD"T"HH24:MI:SS';
/* ------------------------------------------------------------------------------------ */
FUNCTION get_package_version -- used to circumvent ORA-04068: existing state of packages has been discarded
RETURN VARCHAR2;
/* ------------------------------------------------------------------------------------ */
PROCEDURE audit_and_disconnect (
  p_table_name        IN VARCHAR2 DEFAULT gk_table_name, -- kill session holding TM and TX locks on this table
  p_lock_secs_thres   IN NUMBER   DEFAULT gk_lock_secs_thres, -- if the lock has been held for this many sconds
  p_inac_secs_thres   IN NUMBER   DEFAULT gk_inac_secs_thres, -- if the session has been inactive for this many sconds
  p_snip_secs_thres   IN NUMBER   DEFAULT gk_snip_secs_thres, -- snip candidate if inactive for this many sconds
  p_snip_idle_profile IN VARCHAR2 DEFAULT gk_snip_idle_profile, -- application user profile with idle_time set
  p_snip_candidates   IN VARCHAR2 DEFAULT gk_snip_candidates, -- optionally include or exclude snip candiates
  p_sniped_sessions   IN VARCHAR2 DEFAULT gk_sniped_sessions, -- optionally include or exclude user snipped sessions regardless of lock type or object
  p_tm_locks          IN VARCHAR2 DEFAULT gk_tm_locks, -- optionally include or exclude TM locks
  p_tx_locks          IN VARCHAR2 DEFAULT gk_tx_locks, -- optionally include or exclude TX locks
  p_kill_locked       IN VARCHAR2 DEFAULT gk_kill_locked, -- kill sessions holding TX/TM lock on p_table_name
  p_kill_idle         IN VARCHAR2 DEFAULT gk_kill_idle, -- kill sessions waiting long or sniped
  p_expire_date       IN DATE     DEFAULT gk_expire_date -- execute this api only if SYSDATE < p_expire_date
);
/* ------------------------------------------------------------------------------------ */
END iod_sess;
/
