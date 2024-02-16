-- Alter Procedure Crims_pending_per_vendor
-- ======================================================================================================
-- Author:		Suchitra Yellapantula
-- Create date: August 10, 2016
-- Description:	Stored procedure for Q-Report 'Crims pending per Vendor'
-- Parameters: @StartDate, @EndDate, @VendorName --'08/01/2016', --'08/09/2016', --'Future Security Concepts'
-- ======================================================================================================
CREATE PROCEDURE [dbo].[Crims_pending_per_vendor]
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@EndDate date,
	@VendorName varchar(100)
	
AS
BEGIN
if(LTrim(Rtrim(lower(@StartDate)))='null' or lTrim(rtrim(lower(@StartDate)))='') begin set @StartDate=null; end
if(Ltrim(rtrim(lower(@EndDate)))='null' or ltrim(rtrim(lower(@EndDate)))='') begin set @EndDate=null; end

--The Start and End Dates should not be null. If the User has not passed in an input for either/both of these, set them here accordingly.

--If Start Date is null, set it to either the End Date or the current date based on the value of the End date
IF(@StartDate is null)
	BEGIN
		IF (@EndDate is not null AND @EndDate>GETDATE())
		  BEGIN SET @StartDate = GETDATE(); END
		ELSE IF (@EndDate = GETDATE())
			BEGIN SET @StartDate = dateadd(d,-1,GETDATE()); END
		ELSE IF(@EndDate is not null AND @EndDate<GETDATE())
			BEGIN SET @StartDate = dateadd(d,-1,@EndDate); END
		ELSE 
			BEGIN 
				SET @StartDate=dateadd(d,-1,GETDATE()); 
				SET @EndDate = GETDATE();
			END
	END
--If the End Date is null, set it to either the Start Date or the Current Date based on the value of the Start Date
IF(@EndDate is null and @StartDate<GETDATE())
	BEGIN SET @EndDate=GETDATE(); END
ELSE IF(@EndDate is null and @StartDate=GETDATE())
	BEGIN SET @EndDate = dateadd(d,1,@StartDate); END
ELSE IF (@EndDate is null and @StartDate>GETDATE())
	BEGIN SET @EndDate = dateadd(d,1,@StartDate); END


SELECT A.APNO, A.ApDate, CNT.County, CNT.Country, C.Pub_Notes as 'Public Notes', C.Priv_Notes as 'Private Notes', I.R_Name as 'Vendor Name', C.CreatedDate as 'Date Created'
FROM Appl A
	INNER JOIN Crim AS C ON A.APNO = C.APNO
	INNER JOIN Iris_Researchers AS I ON C.vendorid = I.id
	INNER JOIN dbo.TblCounties AS CNT ON C.CNTY_NO = CNT.CNTY_NO
WHERE A.ApDate BETWEEN @StartDate AND @EndDate
	  AND (@VendorName is null OR I.R_Name LIKE '%'+ @VendorName +'%');
END
