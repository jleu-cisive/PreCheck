CREATE PROCEDURE crimnumber 
--@nuserid varchar(20),
--@nfirstname varchar(40),
--@nlastname varchar(40),
--@nmidname varchar(40) ,
@confirmednumber int OUT
AS
Set NoCount On
declare @mid integer
declare @dnext_id integer
begin transaction
  update crimctrlnum
      set crimcontrolnumber = crimcontrolnumber  + 1
      select @dnext_id = crimcontrolnumber FROM crimctrlnum
select @mid =  (select * from crimctrlnum)
  commit transaction
Set @confirmednumber = @mid
