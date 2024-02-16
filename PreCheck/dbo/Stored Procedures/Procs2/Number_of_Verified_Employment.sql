﻿-- =============================================
-- Author:		Radhika dereddy
-- Create date: 07/20/2017
-- Description:	Number of Verified Employment
-- =============================================
CREATE PROCEDURE Number_of_Verified_Employment
	 @CLNO int,
	 @StartDate datetime,
	@EndDate datetime


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


		SELECT A.APNO,S.Description,Count(*) As SubTotal,
			AND Appl.CLNO = @CLNO 
			AND Appl.ApDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate) 
			AND Empl.IsOnReport = 1
		) AS Total
		FROM Client C 
		inner join Appl A on C.CLNO = A.CLNO 
		inner join Empl E on E.APNO = A.APNO 
		inner join SectStat S on E.SectStat = S.Code 
		WHERE C.CLNO = @CLNO 
		AND A.ApDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate) 
		AND E.IsOnReport = 1
		GROUP BY A.APNO, S.DESCRIPTION
		order by A.APNO

END