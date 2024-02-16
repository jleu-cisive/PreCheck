-- =============================================
-- Author:		<Liel Alimole>
-- Create date: <05/20/2013>
-- Description:	<Gets change log of employer>
-- =============================================
-- Updated By : Doug DeGenaro
-- Update date : 06/14/2019
-- Description: Ticket #53300 - Please add following columns to Get Employer Change Log report.  Date/time transmitted to SJV, Date/time Results Found status returned by SJV ,SJV integration's "Results Found" status 
--[dbo].[GetEmployerChangeLog_Doug] '07/10/2019','07/11/2019'
CREATE PROCEDURE [dbo].[GetEmployerChangeLog_Doug]
	-- Add the parameters for the stored procedure here
	@StartDate DateTime = getdate,
	@EndDate DateTime = getdate
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Region Parameters
DECLARE @filter VarChar(1000) = '%Empl.SectStat%'
DECLARE @sectstat char(1) = '9'
DECLARE @webstatus VarChar(1000) = '0'


--select e2.Emplid,UPPER(ivo.Request.value('(//Search/@ResultFound)[1]','varchar(max)')) as SJVResultStatus
--into #tmpResulFound
-- from
--			Integration_VendorOrder_Log il inner join dbo.Empl e2 on il.OrderId = e2.OrderId
--			inner join dbo.integration_vendororder ivo on ivo.Integration_VendorOrderId = il.Integration_VendorOrderId			
--			and (CAST(ivo.[CreatedDate] as DATE) >= CAST(@StartDate as DATE)) AND (CAST(ivo.[CreatedDate] as DATE) <= CAST(@EndDate as DATE)) 
--			and VendorName = 'SJV' and VendorOperation='Listener'
--			order by il.CreatedDate desc

-- EndRegion
SELECT 
		a.[APNO],
		a.[ApDate], 
		c.[Name] AS [ClientName], 
		a.[CLNO] AS [ClientID], 
		e.[Employer],
		e.EmplID as ID, 
		e.web_status, (
    SELECT [t5].[Description]
    FROM (
        SELECT TOP (1) sect.[Description]
        FROM [SectStat] AS sect
        WHERE (CONVERT(NVarChar(1),sect.[Code])) = cl.[NewValue]
        ) AS [t5]
    ) AS [FinalStatus], 
	 e.[Investigator] AS [UserModuleIn],
	 cl.[UserID] AS [ClosedBy],
	 cl.[ChangeDate] AS [ChangedDate],
	 (
		SELECT tbl.NewValue 
		FROM
		(
		  SELECT 
			TOP 1 cl2.NewValue 
		  FROM 
			dbo.ChangeLog cl2 
		  WHERE 
			cl2.TableName = 'Empl.DateOrdered' 
			and cl2.ID = e.EmplID
		 ) as tbl
	) as  [SJV Ordered Date],
	(
		SELECT FORMAT(tbl.ChangeDate,'MM/dd/yyyy hh:mm:ss tt') 
		FROM
		(
		  SELECT 
			TOP 1 cl3.ChangeDate 
		  FROM 
			dbo.ChangeLog cl3 
		  WHERE 
			cl3.TableName = 'Empl.Web_Status' and cl3.UserID='SJV'
			and cl3.ID = e.EmplID
		 ) as tbl
	) as [SJV Result Found Date],
	(
		select tbl5.SJVResultStatus
		from (select top 1 UPPER(ivo.Request.value('(//Search/@ResultFound)[1]','varchar(max)')) as SJVResultStatus from
			Integration_VendorOrder_Log il inner join dbo.Empl e2 on il.OrderId = e.OrderId
			inner join dbo.integration_vendororder ivo on ivo.Integration_VendorOrderId = il.Integration_VendorOrderId
			where e2.EmplId = e.EmplId 
			and VendorName = 'SJV' and VendorOperation='Listener'
			and (CAST(ivo.[CreatedDate] as DATE) >= CAST(@StartDate as DATE)) AND (CAST(ivo.[CreatedDate] as DATE) <= CAST(@EndDate as DATE)) 
			order by il.CreatedDate desc) tbl5
	) as [SJV Result Found]
	
	--case when cl.TableName = 'Empl.DateOrdered' and cl.UserID='SJV' then cl.NewValue else 'N/A' end as [SJV Ordered Date],
	--case when IsNull(e.DateOrdered,'') = '' then 'N/A' else cast(e.DateOrdered as varchar(100)) end as [SJV Ordered Date],
	--case when cl.UserID = 'SJV' then cast(cl.ChangeDate as varchar(100)) else 'N/A' end as [SJV Result Found Date]
FROM [ChangeLog] AS cl, [Empl] AS e, [Appl] AS a, [Client] AS c
WHERE ((cl.[TableName] LIKE @filter) AND ((cl.[OldValue] = @sectstat) OR (cl.[OldValue] = @webstatus))) AND (cl.[NewValue] <> @webstatus) 
AND (cl.[NewValue] <> @sectstat) AND
(CAST(cl.[ChangeDate] as DATE) >= CAST(@StartDate as DATE)) AND (CAST(cl.[ChangeDate] as DATE) <= CAST(@EndDate as DATE)) 
AND ((e.[EmplID]) = cl.[ID]) AND (a.[APNO] = e.[Apno]) AND (c.[CLNO] = a.[CLNO])
END

