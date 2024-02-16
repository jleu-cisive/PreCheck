-- =============================================
-- Author: Prasanna
-- Create date: <03/09/2022>
-- Description:	 Query of SJV Employment Payload Returns
-- parameters: '0' for all apnos; 0 for all OrderID; 0 for all emplID.
-- exec [dbo].[QReport_GetSJVEmploymentPayloadReturns] @APNO=6436924,@OrderID='124272234',@startdate='',@enddate=''
-- =============================================

CREATE PROCEDURE [dbo].[QReport_GetSJVEmploymentPayloadReturns]
@APNO int = 0,
@OrderID varchar(20) = '',
@startdate datetime = NULL,
@enddate datetime = NULL
AS
BEGIN

	SET NOCOUNT ON;
		 
	DECLARE 
		@OrderIDs TABLE 
		( 
			OrderID VARCHAR(20) 
			,APNO INT
			,EmplID INT
			,EmployerName varchar(100)
			,CLNO int
			,ClientName varchar(100)
			,Affiliate varchar(100)
			,ApplicantLastName varchar(100)
			,ApplicantFirstName varchar(100)
		)
	IF (ISNULL(NULLIF(@OrderID,'0'),'')='' AND ISNULL(NULLIF(@APNO,'0'),'')<>'')
	BEGIN

		INSERT INTO @OrderIDs
		SELECT  
			 e.OrderID 
			,e.Apno
			,e.EmplID
			,e.Employer
			,c.CLNO
			,c.[Name]
			,ra.Affiliate
			,a.[first]
			,a.[Last]
		FROM 
			empl e WITH(NOLOCK)
		INNER JOIN 
			appl a WITH(NOLOCK) 
			ON a.Apno =e.apno
		INNER JOIN 
			client c WITH(NOLOCK) 
			ON a.CLNO = c.CLNO
		INNER JOIN 
			refAffiliate ra WITH(NOLOCK) 
			ON c.AffiliateID = ra.AffiliateID
		WHERE
			(e.APNO=@APNO) 
		AND e.OrderId IS NOT NULL

		
		SELECT 
			 o.APNO
			,o.CLNO
			,o.ClientName as [Client Name]
			,o.Affiliate as [Client Affiliate]
			,o.ApplicantFirstName as [Applicant First Name]
			,o.ApplicantLastName as [Applicant Last Name]
			,o.EmplID
			,o.EmployerName as [Employer Name]
			,o.OrderID
			,ivo.Integration_VendorOrderId
			,ivo.VendorName
			,ivo.VendorOperation
			,ivo.Request
			,ivo.Response
			,ivo.CreatedDate
		FROM 
			Integration_VendorOrder ivo WITH(NOLOCK) 
		INNER JOIN 
			@OrderIDs o
			ON  response.value('(//SubjectCtyID)[1]','varchar(max)') = o.OrderID
		WHERE 
			ivo.VendorName='SJV' 
		AND VendorOperation='Completed' 
		AND ivo.CreatedDate>= DATEADD(YEAR,-1,GETDATE())
		AND (ivo.CreatedDate >= IIF(@startdate='',ivo.CreatedDate,@startdate) and ivo.CreatedDate <= IIF(@enddate='',ivo.CreatedDate,@enddate))
		ORDER BY 
			ivo.Integration_VendorOrderId DESC
	END
	ELSE
	BEGIN
		SELECT 
			 e.APNO
			,c.CLNO
			,c.[Name] as [Client Name]
			,ra.affiliate as [Client Affiliate]
			,a.[First] as [Applicant First Name]
			,a.[Last] as [Applicant Last Name]
			,e.EmplID
			,e.Employer as [Employer Name]
			,e.OrderID
			,ivo.Integration_VendorOrderId
			,ivo.VendorName
			,ivo.VendorOperation
			,ivo.Request
			,ivo.Response
			,ivo.CreatedDate
		FROM 
			Integration_VendorOrder ivo WITH(NOLOCK) 
		INNER JOIN
			empl e 
			ON  response.value('(//SubjectCtyID)[1]','varchar(max)') = e.OrderID
		INNER JOIN 
			appl a WITH(NOLOCK) 
			ON a.Apno = e.apno
		INNER JOIN 
			client c WITH(NOLOCK) 
			ON a.CLNO = c.CLNO
		INNER JOIN 
			refAffiliate ra WITH(NOLOCK) 
			ON c.AffiliateID = ra.AffiliateID
		WHERE 
			ivo.VendorName='SJV' 
		AND VendorOperation='Completed' 
		AND e.OrderId = @OrderID
		AND ivo.CreatedDate>= DATEADD(YEAR,-1,GETDATE())
		--AND (ivo.CreatedDate >= @startdate and ivo.CreatedDate <= @enddate)
		AND (ivo.CreatedDate >= IIF(@startdate='',ivo.CreatedDate,@startdate) and ivo.CreatedDate <= IIF(@enddate='',ivo.CreatedDate,@enddate))
		ORDER BY 
			ivo.Integration_VendorOrderId DESC  
   
   END

END

