
/*
Procedure Name : [dbo].[Employment_Verification_Details_For_Clients]
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Execution : EXEC [dbo].[Employment_Verification_Details_For_Clients] '08/01/2014', '09/09/2014', '10660, 10675, 10674, 10673, 10782, 10669, 10671, 10672, 10670'
*/

CREATE PROCEDURE [dbo].[Employment_Verification_Details_For_Clients]
@StartDate DateTime,
@EndDate DateTime ,
@Clno VARCHAR(MAX) = NULL
AS

SELECT A.APNO, A.ApDate, A.CLNO, C.Name AS ClientName, A.First, A.Last, E.Employer, E.From_A , E.To_A, S.Description SectStat_Description
FROM dbo.Appl AS A
INNER JOIN dbo.Empl AS E WITH(NOLOCK) ON E.Apno = A.APNO
INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = E.SectStat
WHERE (@Clno IS NULL OR A.CLNO IN (SELECT * from [dbo].[Split](',',@Clno)))
  and A.ApDate >= @StartDate
  and A.ApDate < @EndDate
  and E.IsOnReport = 1;