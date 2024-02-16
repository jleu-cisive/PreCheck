





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_SearchStatus]
 @CLNO	int,
 
 @First	nvarchar(50),
 @Last nvarchar(50),
 @SSN varchar(11),
 @begdate Datetime,
 @enddate Datetime,
 @divisionid int,
 @lofbusiness int,
@Billable int
	
AS

if (@begdate='') 
set @begdate = '01/01/1900'
if (@enddate='') 
set @enddate = getdate()

--if (@Billable = 2)
--set @Billable = ''
If (@Billable = 3)
BEGIN
Select a.apno,c.Name,a.last,a.first,replace(a.SSN,'-','') as SSN,convert(char(10),a.ApDate,101)as ApDate,a.attn,a.apstatus,isnull(CvoD.PassFailFlag,3)as PassFailFlag, 
isnull(af.FlagStatus,0) as FlagStatus, CvD.DivisionName,CvLD.LineOfBusinessName, CvoD.Billable
FROM appl a 
inner join client c on  a.CLNO = c.CLNO 
left join applflagstatus af on af.apno = a.apno
Inner Join WebOrder_PRX..CvoData CvoD on a.apno = CvoD.appNo  
Inner Join WebOrder_PRX..CvoData_Division CvD on CvoD.DivisionID = CvD.DivisionID  
Inner Join WebOrder_PRX..CvoData_LineOfBusiness CvLD on CvoD.LineOfBusinessID = CvLD.LineOfBusinessID
where 
(
	a.CLNO = @CLNO 
	OR
	c.WebOrderParentCLNO = @CLNO
) 
AND
(
	a.First = @First
	OR
	@First = ''
)
AND
(
	a.Last =@Last
	OR
	@Last = ''
)
AND
(
	replace(a.SSN,'-','') = replace(@SSN,'-','')
	OR
	@SSN = ''
)
AND
(
	a.apdate between ISNULL(@begdate,'01/01/1900') and ISNULL(dateadd(d,1,@enddate),getdate())
)
AND
(
	CvoD.DivisionID = @divisionid
	OR
	@divisionid = 0
)
AND
(
	CvoD.LineOfBusinessID = @lofbusiness
	OR
	@lofbusiness = 0
)
END
Else
Select a.apno,c.Name,a.last,a.first,replace(a.SSN,'-','') as SSN,convert(char(10),a.ApDate,101)as ApDate,a.attn,a.apstatus,isnull(CvoD.PassFailFlag,3)as PassFailFlag, 
isnull(af.FlagStatus,0) as FlagStatus, CvD.DivisionName,CvLD.LineOfBusinessName, CvoD.Billable
FROM appl a 
inner join client c on  a.CLNO = c.CLNO 
left join applflagstatus af on af.apno = a.apno
Inner Join WebOrder_PRX..CvoData CvoD on a.apno = CvoD.appNo  
Inner Join WebOrder_PRX..CvoData_Division CvD on CvoD.DivisionID = CvD.DivisionID  
Inner Join WebOrder_PRX..CvoData_LineOfBusiness CvLD on CvoD.LineOfBusinessID = CvLD.LineOfBusinessID
where 
(
	a.CLNO = @CLNO 
	OR
	c.WebOrderParentCLNO = @CLNO
) 
AND
(
	a.First = @First
	OR
	@First = ''
)
AND
(
	a.Last =@Last
	OR
	@Last = ''
)
AND
(
	replace(a.SSN,'-','') = replace(@SSN,'-','')
	OR
	@SSN = ''
)
AND
(
	a.apdate between ISNULL(@begdate,'01/01/1900') and ISNULL(dateadd(d,1,@enddate),getdate())
)
AND
(
	CvoD.DivisionID = @divisionid
	OR
	@divisionid = 0
)
AND
(
	CvoD.LineOfBusinessID = @lofbusiness
	OR
	@lofbusiness = 0
)
AND
(
	CvoD.Billable = @Billable
)    



SET ANSI_NULLS ON

