
create procedure p_error_handling 
    @command varchar(4000)
as
DECLARE @error_number int
DECLARE @error_severity int
DECLARE @error_state int
DECLARE @error_line int
DECLARE @error_message varchar(4000)
DECLARE @error_procedure varchar(200)
DECLARE @time_stamp datetime

SELECT @error_number = isnull(error_number(),0),
        @error_severity = isnull(error_severity(),0),
        @error_state = isnull(error_state(),1),
        @error_line = isnull(error_line(), 0),
        @error_message = isnull(error_message(),'NULL Message'),
        @error_procedure = isnull(error_procedure(),''),
        @time_stamp = GETDATE();

INSERT INTO dbo.sql_errors (command, error_number, error_severity, error_state, error_line, error_message, error_procedure, time_stamp)
SELECT @command, @error_number, @error_severity, @error_state, @error_line, @error_message, @error_procedure, @time_stamp

