
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 12/12/2013
-- Description:	Billing check for Education verification
-- Test:
-- dbo.Verification_GetBillingInformation 2215313 
/*  SELECT TOP 10 a.apstatus,id.Description,inm.InvoiceNumber,e.*
	FROM educat e 
	INNER JOIN dbo.Appl a ON e.APNO = a.APNO 
	INNER JOIN dbo.InvDetail id ON id.APNO = e.APNO
	LEFT JOIN dbo.InvMaster inm ON inm.InvoiceNumber = id.InvoiceNumber
	WHERE ApStatus NOT IN ('p','w','m') and IsNull(id.Description,'') <> ''
	and charindex('Educat',id.Description) > 0  
	ORDER BY e.APNO DESC
*/
-- 2188058   
-- 2391802
--2215313
-- delete from dbo.InvDetail where apno = 2391802
-- =============================================
CREATE PROCEDURE [dbo].[Verification_GetBillingInformation] 
	-- Add the parameters for the stored procedure here
	@apno int 	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL Read uncommitted 

--[Verification_GetBillingInformation] 2188058

Declare @TempTable Table ( [Status] varchar(20),InvoiceDate DateTime,[Description] varchar(100))

Insert into @TempTable
--SELECT  case when [a].[ApStatus] in ('p','w','m') then 'Pending' else 'Completed' end [Status],m.InvDate InvoiceDate,d.Description		
--FROM appl a inner join invdetail d on a.apno = d.apno
--			left join invmaster m on d.InvoiceNumber = m.InvoiceNumber
--			inner join dbo.Educat e on e.APNO = a.APNO 
--where a.apno = @apno 
SELECT  distinct case when [a].[ApStatus] in ('p','w','m') then 'Pending' else 'Completed' end [Status],m.InvDate InvoiceDate,d.Description		
FROM appl a inner join invdetail d on a.apno = d.apno
			left join invmaster m on d.InvoiceNumber = m.InvoiceNumber		
where a.apno = @apno and Isnull(d.Description,'') <> '' and charindex('Education',Description) > 0

IF (Select count(1) from @TempTable Where InvoiceDate is Not Null)>=1
	Select Distinct [Status],InvoiceDate,[Description]from @TempTable Where InvoiceDate is Not Null Order By InvoiceDate Desc
ELSE
	Select Distinct [Status],InvoiceDate,[Description] from @TempTable 

SET TRANSACTION ISOLATION LEVEL Read committed
SET NOCOUNT OFF;
	
END

