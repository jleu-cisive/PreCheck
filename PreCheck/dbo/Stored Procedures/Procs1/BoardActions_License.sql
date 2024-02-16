
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/28/2016
-- Description: QReport for BoardActions taken for license, for HCA client and Status is '7' - Alert/SeeAttached 'B'- Alert/BoardActions between a data range
-- Updated: 4/12/2017 Suchitra: Added CLNO, Affiliate input params, renamed column names, added IsOnReport, IsHidden columns, per HDT 13423 from Valerie K. Salazar
-- Modified bY - Radhika Dereddy on 09/11/2017 to include CLNO =0 and AffiliateiD=0 and return all the results.
-- Modified by - Humera Ahmed on 9/17/2018 for HDT# - 39415
-- EXEC [BoardActions_License] '01/01/2017', '08/31/2017', 0, 0
-- =============================================
/* Modified By: Sunil Mandal A
-- Modified Date: 06/29/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*

EXEC [dbo].[BoardActions_License] '02/01/2015','07/28/2016',0,0
EXEC [dbo].[BoardActions_License] '02/01/2015','07/28/2016',0,'4:30:158'
*/

CREATE PROCEDURE [dbo].[BoardActions_License]
	-- Add the parameters for the stored procedure here
@StartDate Datetime,
@EndDate DateTime,
@CLNO int,
-- @AffiliateID int --code added by Sunil Mandal for ticket id -53763
@AffiliateIDs varchar(MAX) = '0'--code added by Sunil Mandal for ticket id -53763
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

if(@CLNO is null)
begin
 set @Clno=0
end

/*
if(@AffiliateID is null or @AffiliateID='')
begin
set @AffiliateID=0
end
*/
	--code added by Sunil Mandal for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
     --code added by Sunil Mandal for ticket id -53763 Ends	

    -- Insert statements for procedure here
Select  p.APNO [Report Number], a.CLNO [Client Number], C.Name as [Client Name],rf.Affiliate, rf.AffiliateID, a.Apdate [Created Date], a.First [First Name], A.last [Last Name], 
CASE p.IsOnReport WHEN 1 THEN 'Yes' ELSE 'Unused' End AS [Is On Report],
CASE p.IsHidden WHEN 1 THEN 'Unused' ELSE 'On Report' End AS [Is Hidden],
p.Lic_Type [License Type],s.Description as 'Status', 

--HAhmed 9/7/2018 HDT#39415 - Requester Brian Silver requested to remove Public Notes and add Private notes
--Replace(REPLACE(p.Pub_Notes, char(10),';'),char(13),';') as Pub_Notes
Replace(REPLACE(p.Priv_Notes, char(10),';'),char(13),';') as 'Private Notes',

--HAhmed 9/7/2018 HDT#39415 - Requester Brian Silver requested to add new column for License Status
p.Status as 'License Status'

from ProfLic p
inner join Appl a on a.apno = p.apno
inner join Client c on c.clno = a.clno
inner join refAffiliate rf on c.affiliateId = rf.AffiliateID
inner join SectStat s on s.code = p.SectStat
where (a.Apdate between @StartDate and dateadd(d,1,@EndDate)) and (p.Pub_Notes like '%Board Actions%' ) 

--HAhmed 9/7/2018 HDT#39415 - Requester Brian Silver requested to filter by SectStat description Alert/Board Action
--and p.SectStat in ('7', 'B')
and p.SectStat ='B'

and C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)
-- and rf.AffiliateID = IIF(@AffiliateID=0,rf.AffiliateID,@AffiliateID) --code added by Sunil Mandal for ticket id -53763
AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Sunil Mandal for ticket id -53763
order by 1 Desc

END




