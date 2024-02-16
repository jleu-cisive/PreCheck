/*
Procedure Name : Zc_Verifications_Assigned_Details
Requested By   : Michelle Paz
Developer      : Vairavan A
Created on     : 15-12-2023
Ticket no & Description : 119545 New Qreport SJV Qreports
Execution      : EXEC [Zc_Verifications_Assigned_Details] '12/14/2023', '12/15/2023'
*/

CREATE PROCEDURE [dbo].[Zc_Verifications_Assigned_Details]
	@StartDate DATETIME,
	@EndDate DATETIME
AS
Begin
set nocount on

	Declare @VendorName varchar(50) = 'EnterpriseSJV'  
 
	select 
		  E.DateOrdered as 'DateSent'
		, E.APNO
		, E.Employer as 'Employer Name'
		, S.Description [Status]
	from Empl E with(Nolock)
	inner join SectStat S with(Nolock) on S.Code = E.SectStat
	inner join Integration_VendorOrder_Submitted ivs with(Nolock) on E.EmplID = ivs.EmplID
	where ivs.SubmittedTo=@VendorName
		AND CAST(ivs.CreatedDate AS DATE) >= @StartDate
		AND CAST(ivs.CreatedDate AS DATE) <= @EndDate
	order by E.DateOrdered

set nocount off
END

