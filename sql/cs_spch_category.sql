----------------------------------------------------------------------------------------
--
-- File name:   cs_spch_category.sql
--
-- Purpose:     Changes category for a SQL Patch for given SQL_ID
--
-- Author:      Carlos Sierra
--
-- Version:     2018/08/06
--
-- Usage:       Connecting into PDB.
--
--              Enter SQL_ID and name when requested.
--
-- Example:     $ sqlplus / as sysdba
--              SQL> @cs_spch_category.sql
--
-- Notes:       Accesses AWR data thus you must have an Oracle Diagnostics Pack License.
--
--              Developed and tested on 12.1.0.2.
--
---------------------------------------------------------------------------------------
--
@@cs_internal/cs_primary.sql
@@cs_internal/cs_cdb_warn.sql
@@cs_internal/cs_set.sql
@@cs_internal/cs_def.sql
@@cs_internal/cs_file_prefix.sql
--
DEF cs_script_name = 'cs_spch_category';
--
PRO 1. SQL_ID: 
DEF cs_sql_id = '&1.';
--
SELECT '&&cs_file_prefix._&&cs_sql_id._&&cs_file_date_time._&&cs_reference_sanitized._&&cs_script_name.' cs_file_name FROM DUAL;
--
@@cs_internal/cs_signature.sql
--
@@cs_internal/cs_plans_performance.sql
@@cs_internal/cs_spch_internal_list.sql
--
PRO
PRO 2. NAME (req):
DEF cs_name = '&2.';
PRO
--
PRO 3. Enter CATEGORY (opt) [{DEFAULT}|DISABLED|<string>]:
DEF category_passed = "&3.";
--
COL cs_category NEW_V cs_category;
SELECT CASE WHEN UPPER(NVL('&&category_passed.','DEFAULT')) IN ('DEF', 'DEFAULT') THEN 'DEFAULT' ELSE UPPER('&&category_passed.') END cs_category FROM DUAL;
--
@@cs_internal/cs_spool_head.sql
PRO SQL> @&&cs_script_name..sql "&&cs_sql_id." "&&cs_name." "&&cs_category."
@@cs_internal/cs_spool_id.sql
--
PRO SQL_ID       : &&cs_sql_id.
PRO SIGNATURE    : &&cs_signature.
PRO SQL_HANDLE   : &&cs_sql_handle.
PRO NAME         : &&cs_name.
PRO CATEGORY     : &&cs_category.
--
SET HEA OFF;
PRINT :cs_sql_text
SET HEA ON;
--
@@cs_internal/cs_plans_performance.sql
@@cs_internal/cs_spch_internal_list.sql
--
PRO
PRO Changes category on "&&cs_name." to "&&cs_category."
BEGIN
  FOR i IN (SELECT name 
              FROM dba_sql_patches 
             WHERE signature = :cs_signature
               AND name = NVL('&&cs_name.', name)
             ORDER BY name)
  LOOP
    DBMS_SQLDIAG.alter_sql_patch(name => i.name, attribute_name => 'CATEGORY', value => '&&cs_category.');
  END LOOP;
END;
/
--
@@cs_internal/cs_spch_internal_list.sql
--
PRO
PRO SQL> @&&cs_script_name..sql "&&cs_sql_id." "&&cs_name." "&&cs_category."
--
@@cs_internal/cs_spool_tail.sql
@@cs_internal/cs_undef.sql
@@cs_internal/cs_reset.sql
--
