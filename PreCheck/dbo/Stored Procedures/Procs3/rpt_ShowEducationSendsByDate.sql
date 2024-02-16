CREATE procedure dbo.rpt_ShowEducationSendsByDate
(@datefrom varchar(30),@dateto varchar(30))
as
SET NOCOUNT ON
SET TRANSACTION ISOLATION   LEVEL READ UNCOMMITTED  
 
select distinct a.CLNO,a.APNO,ivt.VerificationCodeId as SchoolCode, SchoolName,a.ApDate as AppDate from dbo.Integration_Verification_Transaction ivt 
left join 
dbo.NCHList lst on ivt.VerificationCodeId = Replace(lst.SchoolCode,'_','') 
inner join dbo.Appl a on ivt.SSN = Replace(a.SSN,'-','') AND VerificationCodeIDType='Education' and IsComplete = 1
where 
 cast(apdate as date) between @datefrom and @dateto



