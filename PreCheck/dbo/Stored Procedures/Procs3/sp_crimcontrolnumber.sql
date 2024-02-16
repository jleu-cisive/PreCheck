CREATE PROCEDURE sp_crimcontrolnumber
AS
declare @next_id integer
begin transaction
update crimctrlnum
set crimcontrolnumber = crimcontrolnumber + 1
select @next_id = crimcontrolnumber FROM crimctrlnum
select crimcontrolnumber from crimctrlnum
commit transaction
