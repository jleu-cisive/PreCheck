--=================================================================================
--Procedure Name :  SJV_Completed_Orders_Detail
--Requested By: Milton Robins
--Developer: Doug, Prasanna
--Execution : EXEC [SJV_Completed_Orders_Detail] 4537106, '04/02/2019','04/02/2019'
--==================================================================================

CREATE PROCEDURE [dbo].[SJV_Completed_Orders_Detail]	

    @apno int,
	@startddate datetime=null,
	@endddate datetime = null
AS

BEGIN
	;WITH cte as
	(
		SELECT e.apno,e.OrderId, e.From_V AS CurrentFromDate, e.To_V AS CurrentToDate, e.Position_V AS CurrentPosition,
		Tbl.Employments.value('(DateEmployedFromVerified)[1]','varchar(10)') AS FromDateFlag,  
		Tbl.Employments.value('(DateEmployedFromVerifiedComments)[1]','varchar(8000)') AS DateEmployedFromVerified,  
		Tbl.Employments.value('(DateEmployedToVerified)[1]','varchar(10)') AS ToDateFlag,
		Tbl.Employments.value('(DateEmployedToVerifiedComments)[1]','varchar(8000)') AS DateEmployedToVerified,
		Tbl.Employments.value('(JobTitleVerified)[1]','varchar(10)') AS PositionFlag,
		Tbl.Employments.value('(JobTitleVerifiedComments)[1]','varchar(8000)') AS PositionVerified,
		Tbl.Employments.value('(//Result[@SType = "EmploymentVerification"]/@ResultFound)[1]','varchar(100)') AS ResultFound,
		ivo.CreatedDate AS [Created Date]
		from dbo.integration_vendororder ivo(nolock)
		CROSS APPLY ivo.Response.nodes('(//Result)') AS Tbl(Employments) 
		INNER JOIN dbo.empl e(nolock) ON Tbl.Employments.value('(SubjectCtyID[1])', 'varchar(20)') = e.OrderId
		where VendorOperation='Completed' and VendorName='SJV' and e.apno = @apno 
		and (ivo.createddate BETWEEN COALESCE(ivo.createddate,@startddate) AND COALESCE(ivo.createddate,@endddate)) 
	) 

	SELECT * FROM cte

END