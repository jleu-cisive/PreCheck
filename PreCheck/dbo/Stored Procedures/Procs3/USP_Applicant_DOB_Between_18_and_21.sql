
-- =============================================
-- Author:		kiran miryala
-- Create date: 5/24/2012
-- Description:	select applicants between 18 and 21 based on there DOB for doing a selective service lookup
-- =============================================
CREATE PROCEDURE [dbo].[USP_Applicant_DOB_Between_18_and_21]
(
  @CLNO int,
  @StartDate datetime,
  @EndDate datetime
)
as

Select A.CLNO 'Client ID' , C.Name as 'Client Name' , APNO as 'Application Number' , ApDate as 'Report Date', Last as 'Applicant Last Name', First as 'Applicant First Name', CONVERT(varchar(10),DOB,101) as 'Date of Birth',(Year(getDate())-Year(DOB)) 'AGE'
from Appl A inner join Client C on A.CLNO = C.CLNo
where A.CLNO = @CLNO and ApDate between @StartDate and @EndDate
and ((Year(getDate())-Year(DOB))>= 18 and (Year(getDate())-Year(DOB)) <= 21)



--USP_Applicant_DOB_Between_18_and_21 2167,'5/1/2012','5/24/2012'