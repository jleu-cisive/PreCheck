
/****** Object:  StoredProcedure [dbo].[EZVerify_UpdateEmplVerificationInfo]    Script Date: 06/22/2011 11:08:48 ******/

-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-16-2008
-- Description:	 Gets app info for the client when search by SSN
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_ClientReportBySSN]
	@CLNO  INT,
	@SSN varchar(11)
	
As
SELECT a.apno,a.last,a.first,a.ssn,a.apdate,a.attn,
apstatus = case  when a.apstatus = 'F' then 'Completed' when a.apstatus = 'P' then 'In Progress' when a.apstatus = 'W' and a.apno > 1200000 then 'In Progress (A)' else 'On Hold' end,
c.Name AS expr1 
,af.flagstatus,a.Pos_Sought
	,Convert(varchar(10),a.DOB,101) as DOB
	,a.Phone
	FROM appl a
	Inner Join  client c ON a.CLNO = c.CLNO 
	LEFT OUTER JOIN applflagstatus af  ON a.apno=af.apno
where 
(a.CLNO = @CLNO or c.WebOrderParentCLNO = @CLNO) 
AND 
(
replace(a.SSN,'-','') = replace(@SSN,'-','')
or
replace(a.SSN,'-','') like  ( Replace(@SSN,'unknown9','')+ '%')
)

SET ANSI_NULLS ON


