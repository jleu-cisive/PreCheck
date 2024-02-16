-- =============================================
-- Author:		<Amy Qing Liu>
-- Create date: <05/26/2020>
-- Description:	<Search for SJV Response from apno or EmplID or OrderID for project: IntranetModule-Status-SubStatus phase2 UAT test >
-- Modified By:	Joshua Ates
-- Modify Date: 2/9/2021
-- Description: Optomized and cleaned query to be faster and more readable. 
-- parameters: '0' for all apnos; 0 for all OrderID; 0 for all emplID.
-- exec [dbo].[QReport_GetSJVCompletedOrderStatusFromOrderIDAPNO] @APNO=5200723,@OrderID='0'
-- exec [dbo].[QReport_GetSJVCompletedOrderStatusFromOrderIDAPNO] @APNO=5331982,@OrderID='0'

-- =============================================

CREATE PROCEDURE [dbo].[QReport_GetSJVCompletedOrderStatusFromOrderIDAPNO]
@APNO int = 0,
@OrderID varchar(20) = ''
AS
BEGIN

	SET NOCOUNT ON;

	--DECLARE 
	--	@APNO INT = 5200723,
	--	@OrderID VARCHAR(20)  ='0'

		 
	DECLARE 
		@OrderIDs TABLE 
		( 
			 OrderID VARCHAR(20) 
			,APNO INT
			,EmplID INT
		)
	IF (ISNULL(NULLIF(@OrderID,'0'),'')='' AND ISNULL(NULLIF(@APNO,'0'),'')<>'')
	BEGIN

		INSERT INTO @OrderIDs
		SELECT  
			 e.OrderID 
			,e.Apno
			,e.EmplID
		FROM 
			empl e WITH(NOLOCK)
		INNER JOIN 
			appl a WITH(NOLOCK) 
			ON a.Apno =e.apno
		WHERE
			(e.APNO=@APNO) 
		AND e.OrderId IS NOT NULL
			
		SELECT
			 o.APNO
			,o.EmplID
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
		ORDER BY 
			ivo.Integration_VendorOrderId DESC
	END
	ELSE
	BEGIN
		SELECT 
			 e.APNO
			,e.EmplID
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
		WHERE 
			ivo.VendorName='SJV' 
		AND VendorOperation='Completed' 
		AND e.OrderId = @OrderID
		AND ivo.CreatedDate>= DATEADD(YEAR, -1, GETDATE())
		ORDER BY 
			ivo.Integration_VendorOrderId DESC
    END

END

