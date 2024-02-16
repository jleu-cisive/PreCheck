-- Create Procedure IRIS_AutoAssignVendors
CREATE PROCEDURE [dbo].[IRIS_AutoAssignVendors]
AS
DECLARE @CNTY_NO int, @apno int,@county varchar(40),@Clear varchar(1),@CRIM_SpecialInstr  varchar(8000)
DECLARE @crimid int
DECLARE Crim_Cursor CURSOR FOR
SELECT DISTINCT 
                       crim.crimid
FROM         dbo.TblCounties INNER JOIN
                      dbo.Crim ON dbo.TblCounties.CNTY_NO = dbo.Crim.CNTY_NO LEFT OUTER JOIN
                      dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Crim.vendorid IS NULL) AND (dbo.Crim.IRIS_REC = 'yes') and (crim.clear is null or crim.clear = 'R')
and (datediff(mi,dbo.crim.crimenteredtime,getdate()) >= 1);
OPEN Crim_Cursor;
FETCH NEXT FROM Crim_Cursor INTO @crimid;
WHILE @@FETCH_STATUS = 0
   BEGIN

	SELECT @CNTY_NO = CNTY_NO, @apno = apno,@county = county,@Clear = clear,@CRIM_SpecialInstr = CRIM_SpecialInstr from Crim where CrimId = @crimid
	
	IF @Clear is null or not @Clear = 'F' --added 7/9/07
		BEGIN
			EXEC testFaxing_DeleteCheck @apno,@county,@CNTY_NO,@crimid,@Clear,@CRIM_SpecialInstr;
		END

      FETCH NEXT FROM Crim_Cursor INTO @crimid;
   END;
CLOSE Crim_Cursor;
DEALLOCATE Crim_Cursor;
