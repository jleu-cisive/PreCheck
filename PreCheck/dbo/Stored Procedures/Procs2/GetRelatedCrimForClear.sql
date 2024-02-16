-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetRelatedCrimForClear] @Apno int, @County varchar(40) 
AS
BEGIN
SELECT * 
FROM Crim
WHERE APNO = @Apno and County = @County and IsHidden = 0 and Clear = 'T'

END
