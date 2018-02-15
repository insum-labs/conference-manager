create or replace package ks_error_handler
AS

/*
 * Use with:
 * ks_error_handler.error_handler_logging_session
 *
 */
  --============================================================================
  -- B A S I C   E R R O R   D U M P
  --============================================================================
FUNCTION basic_error_dump(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result;
  --============================================================================
  -- B A S I C   E R R O R   H A N D L E R
  --============================================================================
FUNCTION basic_error_handler(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result;
  --============================================================================
  -- B A S I C   E R R O R   H A N D L E R   W I T H   L O O K U P
  --============================================================================
FUNCTION basic_error_lookup(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result;
  --============================================================================
  -- E R R O R   H A N D L E R  -  L O G G I N G
  --============================================================================
FUNCTION error_handler_logging(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result;
  --============================================================================
  -- E R R O R   H A N D L E R  -  L O G G I N G  &  S E S S I O N   S T A T E
  --============================================================================
FUNCTION error_handler_logging_session(
    p_error IN apex_error.t_error )
  RETURN apex_error.t_error_result;
    --============================================================================
  -- F O R C E   P L / S Q L   E R R O R   
  --============================================================================
PROCEDURE force_plsql_error;
END ks_error_handler;
/
