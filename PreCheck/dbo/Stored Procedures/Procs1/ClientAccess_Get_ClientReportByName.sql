

-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-16-2008
-- Description:	 Gets app info for the client when search by Firstname & Lastname.
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_ClientReportByName]
	@CLNO  INT,
	@FirstName varchar(20),
	@LastName varchar(20)
As
	

SELECT 
a.apno,a.last,a.first,a.ssn,a.apdate,a.attn,
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
--a.first like ( Replace(@FirstName,'unknown9','')+ '%') 
(
 a.first = @FirstName
OR
a.first like ( Replace(@FirstName,'unknown9','')+ '%')
OR
@FirstName = ''
)
AND 
--a.last like (Replace(@LastName,'unknown9','') + '%') 
(
a.last = @LastName
OR
a.last like (Replace(@LastName,'unknown9','') + '%')
OR
@LastName = ''
)
order by a.apno DESC

SET ANSI_NULLS ON
