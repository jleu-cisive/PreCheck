
/************************************************************************************
--EXEC CriminalRecords_ByClient_ByDate 0,10,'01/01/2016','04/01/2017'
--EXEC CriminalRecords_ByClient_ByDate 0,10,'01/01/2016','04/01/2017'
--  EXEC CriminalRecords_ByClient_ByDate 2167,0,'03/01/2020','02/01/2021'
-- Modified by Amy Liu for HDT84585 on 02/22/2021
--  EXEC CriminalRecords_ByClient_ByDate 0,253,'01/01/2020','12/31/2020'   ---Brian
-- =============================================
-- Modified By: Vairavan A
-- Modified Date: 08/26/2022
-- Description: Ticketno-60560 Modify Qreport: Criminal Records Found by Client By Date
--EXEC CriminalRecords_ByClient_ByDate 0,253,'01/01/2020','12/31/2020' 
************************************************************************************/

CREATE Procedure [dbo].[CriminalRecords_ByClient_ByDate] 
@CLNO varchar(max),
@AffiliateID int = 0,
@StartDate Datetime,
@EndDate DateTime

AS
SET NOCOUNT ON

BEGIN
--declare @CLNO varchar(max)='0' ,--'13880:13883',
--@AffiliateID int = 253,  --0,
--@StartDate Datetime='03/01/2020',
--@EndDate DateTime='02/01/2021'

if(@CLNO = '' OR LOWER(@CLNO) = 'null')
	Begin 
		SET @CLNO = '0' 
	END

--Modified by Humera Ahmed for HDT - 47128 on 2/21/2019. - Please add "Applicant DOB" before "DOB on Record" and please add "Search Vendor" preferred vendor in IRIS associated with the search after "County" 

SELECT distinct Appl.APNO, Appl.ApDate, Appl.CLNO, Appl.ssn as [BackgroundReport SSN],
Client.Name AS FacilityName, Crim.County, ir.R_Name [Search Vendor],
Crim.Clear, Crim.Name AS [Name On Record], appl.DOB [Applicant DOB],
Crim.DOB AS [DOB On Record], Crim.SSN AS [SSN On Record], Crim.CaseNo, Crim.Date_Filed,
Crim.Offense, RefCrimDegree.Description AS [Degree], Crim.Sentence, Crim.Fine, Crim.Disp_Date,
--Crim.Disposition,--code commented for ticket id - 60560
Crim.Disposition as [Returned Disposition],--code added for ticket id - 60560
r.Disposition  [Final Disposition],--code added for ticket id - 60560
REPLACE(REPLACE(Crim.Pub_Notes, CHAR(13), ''), CHAR(10), '') [Public Notes], raff.Affiliate
FROM  Crim  WITH (NOLOCK) 
left join dbo.RefDisposition r on r.RefDispositionID=Crim.RefDispositionID
INNER JOIN Appl  WITH (NOLOCK) ON Crim.APNO = Appl.APNO 
INNER JOIN Client  WITH (NOLOCK) ON Appl.CLNO = Client.CLNO
INNER JOIN RefCrimDegree WITH (NOLOCK) ON Crim.Degree = RefCrimDegree.refCrimDegree
inner join refAffiliate raff on raff.AffiliateID = client.AffiliateID
INNER JOIN IRIS_Researcher_Charges irc WITH (NOLOCK) ON Crim.vendorid = irc.Researcher_id AND dbo.Crim.CNTY_NO = irc.cnty_no AND irc.Researcher_Default = 'Yes'
INNER JOIN dbo.Iris_Researchers ir WITH (nolock) ON irc.Researcher_id = ir.R_id
WHERE (Crim.Clear IN ('P', 'F')) 
 AND (isnull(@CLNO,'0')='0' OR Client.clno IN (SELECT * from [dbo].[Split](':',@CLNO)))
AND raff.AffiliateID = IIF(@AffiliateID=0, raff.AffiliateID, @AffiliateID)
AND Crim.ishidden = 0
AND Appl.APDATE >= @StartDate
and Appl.APDATE < DATEADD(d,1,@EndDate)
AND Appl.clno NOT IN (2135, 3468)
order by appl.apno


END

