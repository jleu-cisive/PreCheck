CREATE PROCEDURE Iris_Autosend_Fileid 

@confirmednumber int OUT
AS
Set NoCount On
declare @mid integer
declare @dnext_id integer
begin transaction
  update iris_autosend_faxes
      set fileid = fileid  + 1
      select @dnext_id = fileid FROM iris_autosend_faxes
select @mid =  (select * from iris_autosend_faxes)
  commit transaction
Set @confirmednumber = @mid