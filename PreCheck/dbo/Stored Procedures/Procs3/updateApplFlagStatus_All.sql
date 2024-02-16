


-- =============================================
-- Author:		<Bhavana Bakshi>
-- Create date: <04/25/2008>
-- Description:	<To update applicaton's flag status from OASIS for all the final apps>
--  Flag  Description
--  1      Clear
--  2      Needs Review
-- =============================================

CREATE PROCEDURE [dbo].[updateApplFlagStatus_All]
	AS
BEGIN
	SET NOCOUNT OFF;

DECLARE @apno int


DECLARE My_Cursor Cursor FOR 
SELECT apno FROM appl WHERE apstatus='F' 
and apno < 100000 and apno >=50000
OPEN My_Cursor
FETCH NEXT FROM My_Cursor INTO @apno

WHILE @@FETCH_STATUS <>-1
		BEGIN			
			
		   exec updateApplFlagStatus @apno
            FETCH NEXT FROM My_Cursor INTO @apno
		END


CLOSE My_Cursor
DEALLOCATE My_Cursor
END


