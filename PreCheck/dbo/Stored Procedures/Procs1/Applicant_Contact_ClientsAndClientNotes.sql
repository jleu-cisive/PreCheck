/*-----------------------------------------------------------------------------------------------
Procedure Name : [dbo].[Applicant_Contact_ClientsAndClientNotes]
Requested By: Dana
Developer: Prasanna
Execution : EXEC [dbo].[Applicant_Contact_ClientsAndClientNotes] 
Modified By: Radhika Dereddy on 06/01/2016
*/-----------------------------------------------------------------------------------------------


--EXEC Applicant_Contact_ClientsAndClientNotes '01/01/2016', '05/31/2016'

CREATE PROCEDURE [dbo].[Applicant_Contact_ClientsAndClientNotes] 
	@StartDate DateTime, 
    @EndDate DateTime
AS
BEGIN
	
	SELECT c.clno as 'ClientNo', c.Name as 'ClientName', c.OKToContact, c.CAM,
	 Replace(REPLACE(cast(cn.Notetext as varchar(max)), char(10),';'),char(13),';') as NoteText, 
	 Replace(REPLACE(cn.NoteDate, char(10),';'),char(13),';') as NoteDate,
	 ra.Affiliate, Reports
	 FROM Client c 
	 inner join ClientNotes cn on c.CLNO = cn.CLNO
	 inner join refAffiliate ra on ra.AffiliateID = c.AffiliateID 
	 inner join (select CLNO, Count(Apno) as Reports from Appl where (ApDate>= @StartDate and ApDate< = dateadd(s,-1,dateadd(d,1,@EndDate))) Group by CLNO) a on a.CLNO = c.CLNO
	 WHERE c.OKToContact = 1 

END

