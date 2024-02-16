-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllRecordsFromCrim] @APNO INT
AS
BEGIN
SELECT * 
FROM Crim
WHERE APNO = @APNO
END
