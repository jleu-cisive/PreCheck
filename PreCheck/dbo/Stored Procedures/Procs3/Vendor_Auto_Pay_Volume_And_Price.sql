-- Alter Procedure Vendor_Auto_Pay_Volume_And_Price
-- =============================================
-- Author: Deepak Vodethela
-- Requester: Charles Sours
-- Create date: 02/12/2016
-- Description:	To get the details of Vendors and their Auto Pay Volume and Price
-- Execution: EXEC [dbo].[Vendor_Auto_Pay_Volume_And_Price]  '02/01/2016', '02/12/2016','Baxter Research','TUOLUMNE','','0'
--			  EXEC [dbo].[Vendor_Auto_Pay_Volume_And_Price]  '02/01/2016', '03/12/2016','Baxter',NULL,NULL,'0'
--			  EXEC [dbo].[Vendor_Auto_Pay_Volume_And_Price]  '02/10/2016', '02/12/2016','Baxter Research','SAN FRANCISCO','CA','3135790'
-- =============================================
CREATE PROCEDURE [dbo].[Vendor_Auto_Pay_Volume_And_Price]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@VendorName varchar(100),
	@County varchar(40),
	@State varchar(25),
	@Apno int
AS
SET NOCOUNT ON

IF LEN(LTRIM(RTRIM(@County))) = 0 
	SET @County = NULL

IF LEN(LTRIM(RTRIM(@State))) = 0 
	SET @State = NULL

SELECT DISTINCT IR.R_Name AS VendorName, A.APNO , A.First, A.Last,C.Last_Updated AS CompletionDate,CC.County AS County,CC.[State] AS [State],IRC.Researcher_CourtFees ,IRC.Researcher_other AS VendorFee
FROM dbo.Crim AS C WITH(NOLOCK)
INNER JOIN [dbo].[Iris_Researchers] AS IR WITH(NOLOCK) ON IR.R_id = C.vendorid
INNER JOIN [dbo].[Appl] AS A WITH(NOLOCK) ON A.APNO = C.APNO
INNER JOIN [dbo].[Iris_Researcher_Charges] AS IRC WITH(NOLOCK) ON IRC.[Researcher_id] = IR.R_id AND c.CNTY_NO = IRC.cnty_no
INNER JOIN dbo.TblCounties AS CC WITH(NOLOCK) ON CC.cnty_no = C.cnty_no
WHERE C.Clear IN ('T','F')
  AND IRC.Researcher_Default = 'Yes'
  AND C.Last_Updated BETWEEN @StartDate and DATEADD(d,1,@EndDate)
  AND IR.R_Name LIKE '%'+ @VendorName +'%'
  AND (A.Apno = IIF(@Apno = 0, A.Apno, @Apno))
  AND (@County IS NULL OR C.County LIKE '%' + @County + '%')
  AND (@State IS NULL OR CC.[State] = @State)
ORDER BY A.APNO, C.Last_Updated
