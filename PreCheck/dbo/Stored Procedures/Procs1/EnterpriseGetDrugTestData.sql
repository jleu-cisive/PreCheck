-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[EnterpriseGetDrugTestData]  @tnCLNO INT, @tnAPNO INT, @tcFN varchar(50), @tcLN varchar(50), @tcSSN varchar(11)
AS
BEGIN
   SET NOCOUNT on	
   DECLARE @DTPackageID INT
   DECLARE @lnOCHSCandidateInfoID INT
   DECLARe @temp1 TABLE (OCHS_CandidateInfoID INT ,ClientConfiguration_DrugScreeningID INT ,CLNO INT, APNO INT )

   SET @lnOCHSCandidateInfoID = 0

   -- Do we find a hit on APNO
   INSERT into @temp1
	  SELECT OCHS_CandidateInfoID,ClientConfiguration_DrugScreeningID,CLNO,@tnAPNO
	      FROM OCHS_CandidateInfo with (nolock)
	      WHERE APNO = @tnAPNO and CLNO = @tnCLNO
   	
    -- IF NOT Found try by Name, SSN, CLNO
   IF @@RowCount = 0
	    INSERT INTO @temp1
		   SELECT OCHS_CandidateInfoID,ClientConfiguration_DrugScreeningID,CLNO,@tnAPNO
		   FROM OCHS_CandidateInfo with (nolock) WHERE CLNO = @tnCLNO and LastName = @tcLN and FirstName = @tcFN and SSN = @tcSSN 

      
   -- Next get the Results
	SELECT TID,OCHS_CandidateInfoID,OrderStatus,TestResult,LastUpdate,ZipCrimClientPackageID
		FROM OCHS_ResultDetails RD with (nolock) join @temp1 T1 on OrderIDOrApno = cast(T1.OCHS_CandidateInfoID as varchar(20))
												 join ClientConfiguration_DrugScreening CCDS with (NOLOCK) on T1.CLNO = CCDS.CLNO  and T1.ClientConfiguration_DrugScreeningID = CCDS.ClientConfiguration_DrugScreeningID   
												 join ClientPackages CP with (NOLOCK) on CCDS.PackageID = CP.PackageID and CCDS.CLNO = CP.CLNO
	    --WHERE OrderStatus = 'Completed'
	UNION
		SELECT TID,OCHS_CandidateInfoID,OrderStatus,TestResult,LastUpdate,ZipCrimClientPackageID
			FROM OCHS_ResultDetails RD with (nolock) join @temp1 T1 on OrderIDOrApno = cast(T1.APNO as varchar(20))
													 join ClientConfiguration_DrugScreening CCDS with (NOLOCK) on T1.CLNO = CCDS.CLNO  and T1.ClientConfiguration_DrugScreeningID = CCDS.ClientConfiguration_DrugScreeningID   
													 join ClientPackages CP with (NOLOCK) on CCDS.PackageID = CP.PackageID and CCDS.CLNO = CP.CLNO
		  --  WHERE OrderStatus = 'Completed'
		ORDER BY LastUpdate DESC 
END

