CREATE  PROCEDURE CRIMnotDone
AS
SET NOCOUNT ON

SELECT CRIM.Apno,CrimID,Crimenteredtime,clear,Appl.UserID,Appl.InUse
	FROM CRIM
join Appl on Appl.apno=crim.apno
	WHERE iris_rec='yes' and (clear is null or Appl.InUse is not null)
Order by CRIM.APNO