

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_Status]
 
@CLNO	int,
@Status varchar(3)
 
	
AS
IF (@Status= 'f')
Begin
SELECT a.apno,a.last,a.first,a.ssn,convert(char(10),a.ApDate,101)as ApDate,a.attn,a.apstatus,c.Name AS expr1,isnull(CvoD.PassFailFlag,3)as PassFailFlag, isnull(af.FlagStatus,0) as FlagStatus,
CvD.DivisionName,CvLD.LineOfBusinessName, CvoD.Billable 
FROM appl a 
inner join client c on  a.CLNO = c.CLNO 
left join applflagstatus af on af.apno = a.apno 
Inner Join WebOrder_PRX..CvoData CvoD on a.apno = CvoD.appNo 
Inner Join WebOrder_PRX..CvoData_Division CvD on CvoD.DivisionID = CvD.DivisionID  
Inner Join WebOrder_PRX..CvoData_LineOfBusiness CvLD on CvoD.LineOfBusinessID = CvLD.LineOfBusinessID 
where 
(a.CLNO = @CLNO or c.WebOrderParentCLNO = @CLNO) 
and a.apstatus = 'f' 
and a.compdate between getdate() - 7 and getdate() 
order by a.apno 
End
Else
SELECT a.apno,a.last,a.first,a.ssn,convert(char(10),a.ApDate,101)as ApDate,a.attn,a.apstatus,c.Name AS expr1,isnull(CvoD.PassFailFlag,3)as PassFailFlag,isnull(af.FlagStatus,0) as FlagStatus,
CvD.DivisionName,CvLD.LineOfBusinessName, CvoD.Billable 
FROM appl a 
inner join client c on  a.CLNO = c.CLNO 
left join applflagstatus af on af.apno = a.apno 
Inner Join WebOrder_PRX..CvoData CvoD on a.apno = CvoD.appNo 
Inner Join WebOrder_PRX..CvoData_Division CvD on CvoD.DivisionID = CvD.DivisionID  
Inner Join WebOrder_PRX..CvoData_LineOfBusiness CvLD on CvoD.LineOfBusinessID = CvLD.LineOfBusinessID 
where 
(a.CLNO = @CLNO or c.WebOrderParentCLNO = @CLNO) 
and a.apstatus = @Status
order by a.apno 


SET ANSI_NULLS ON
