CREATE PROCEDURE Iris_BatchPrint 
--@nuserid varchar(20),
--@nfirstname varchar(40),
--@nlastname varchar(40),
--@nmidname varchar(40) ,
@outconfirmednumber int OUT
AS
Set NoCount On
declare @mid integer
declare @dnext_id integer
begin transaction
  update iris_printbatch
      set batchprintnumber = batchprintnumber  + 1
      select @dnext_id = batchprintnumber FROM iris_printbatch
select @mid =  (select * from iris_printbatch)
  commit transaction
Set @outconfirmednumber = @mid
