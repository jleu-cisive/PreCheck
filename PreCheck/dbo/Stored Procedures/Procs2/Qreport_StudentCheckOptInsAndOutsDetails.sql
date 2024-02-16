-- ===========================================================
-- Author:		Cameron DeCook
-- Create date: 11/7/2022
-- Description:	QReport that provides detail associated with 
--			    StudentCheck Opt-In data the Opt-Ins & Out Details (HDT#70653)
-- EXEC StudentCheckOptInsAndOuts '01/01/2023','01/31/2023'
-- ===========================================================
CREATE PROCEDURE [dbo].[Qreport_StudentCheckOptInsAndOutsDetails]
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN

    SELECT preA.APNO,
           COALESCE(preA.ApDate, A.CreateDate) AS [Application Date],
           A.FirstName AS [Applicant First Name],
           A.LastName AS [Applicant Last Name],
           preA.City AS [Applicant Address City],
           preA.State AS [Applicant Address State],
           CASE
               WHEN u.IsEnrollForEmployment = 1 THEN
                   'True'
               ELSE
                   'False'
           END AS [Opt-In],
           c.Name AS [Client Name],
           c.City AS [Client Address City],
           c.State AS [Client Address State],
           c.AffiliateID,
           c.[Accounting System Grouping]
    FROM [Enterprise].dbo.Applicant A WITH (NOLOCK)
        LEFT OUTER JOIN [Enterprise].Profile.[User] u WITH (NOLOCK)
            ON A.ProfileUserId = u.UserId
        LEFT OUTER JOIN PRECHECK.dbo.Appl preA WITH (NOLOCK)
            ON preA.APNO = A.ApplicantNumber
        LEFT OUTER JOIN PRECHECK.dbo.Client c WITH (NOLOCK)
            ON preA.CLNO = c.CLNO
    WHERE COALESCE(preA.ApDate, A.CreateDate)
          BETWEEN @StartDate AND @EndDate
          AND u.IsEnrollForEmployment IS NOT NULL;


END;