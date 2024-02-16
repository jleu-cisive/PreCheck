-- =============================================
-- Author:		<Amy Liu>
-- Create date: <09/27/2021>
-- Description:	<the report will deliver to client weekly on Wednesday morning at midnight>
-- =============================================
CREATE PROCEDURE [dbo].[SomatusWeeklyReport_13600]
AS
BEGIN

	SET NOCOUNT ON;


declare @EndDate datetime =  cast (Getdate() as date)
declare @StartDate datetime =cast(@EndDate -7 as date)

declare @CLNO int =13600
 select a.CreatedDate as [Report Date], a.APNO as [Report Number], af.Affiliate as [Affiliate], c.clno as [Client Number],c.Name as [Client Name],
 a.Last as [Candidate Last Name],a.First as [Candidate First Name], ss.Description [Status] , 
 pl.lic_Type as [License Type],pl.Lic_No as [License Number], pl.State as [License State], pl.Expire as [Expired Date], pl.status as [Status],
 pl.Lic_Type_V as [License Type Verified], pl.Lic_No_V as [License Number Verified], pl.Status_A [License Status], 

 pl.State_V as [License state verified], pl.NameOnLicense_V [Name on License],pl.Speciality_V [Specialty], pl.CreatedDate [Obtained Date], pl.Expire_V as [Expired Date Verified],
 pl.MultiState_V [MultiState Status], pl.BoardActions_V [Board Actions], pl.Organization as [Organization], pl.ContactMethod_V [Contact Method], pl.Contact_Name as [Contact Name],
 pl.Contact_Title as [Contact Title], pl.Contact_Date [Contact Date], pl.Pub_Notes [Public Notes],pl.BoardActions_V [Per Board], a.SSN
 from dbo.Appl a (nolock)
 inner join dbo.client c (nolock) on a.clno = c.clno
 inner join dbo.refAffiliate af(nolock) on c.AffiliateID = af.affiliateID
 inner join dbo.ProfLic pl (nolock) on pl.apno = a.apno
 inner join dbo.SectStat ss (nolock) on pl.SectStat = ss.Code
 LEFT join dbo.SectSubStatus sss (nolock) on pl.sectsubstatusID = sss.sectsubstatusId and sss.ApplSectionID=4 and ss.Code = sss.SectStatusCode

 where pl.SectStat= '4'
 --a.CreatedDate>=@StartDate and a.CreatedDate<@Enddate 
 and pl.Last_Updated>=@StartDate and pl.CreatedDate<@Enddate 
 and (a.CLNO = @CLNO)

END

