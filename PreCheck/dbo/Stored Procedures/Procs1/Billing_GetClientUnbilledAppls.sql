
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- added ApStatus and Apdate in where Condition on 6/1/2011 -- kiran
-- added UserID to include CAM Name in ExceptionReport on 10/5/2013 --Radhika Dereddy
--Modified By Radhika Dereddy 10/02/2017 to remove 3468 Bad Apps and 3668 Zee demo
-- Modifed by Lalit on 31 october-2023 to exclude Zipcrim Client
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetClientUnbilledAppls]
@Clno smallint
AS
SET NOCOUNT ON
SELECT Apno, UserID FROM Appl --'UserID' Added by Radhika Dereddy to include CAM Name in ExceptionReport 
WHERE (CLNO = @CLNO) and ApStatus ='F' and Apdate>'1/1/2010'--Apdate>'1/1/2010' is used to eliminate old reports which are not billed. date is used as a hard cut off date. -- kiran
  AND (Billed = 0) AND CLNO NOT IN (3468,3668,2135,17480)







