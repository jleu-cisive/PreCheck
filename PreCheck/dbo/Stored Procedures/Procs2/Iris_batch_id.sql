CREATE PROCEDURE Iris_batch_id
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
  update iris_nextresearcherid
      set crimcontrolnumber = crimcontrolnumber  + 1
      select @dnext_id = crimcontrolnumber FROM iris_nextresearcherid
select @mid =  (select * from iris_nextresearcherid)
  commit transaction
Set @confirmednumber = @mid
