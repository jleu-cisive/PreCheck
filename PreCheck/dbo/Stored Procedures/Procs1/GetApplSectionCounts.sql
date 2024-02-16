-- =============================================
-- Author:		schapyala
-- Create date: 06/06/2012
-- Description:	This SP returns the section counts for a given app.
-- =============================================
CREATE PROCEDURE [dbo].[GetApplSectionCounts] 
	@APNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	DECLARE @EmplCount int,  @EducatCount int, @ProfLicenseCount int, @PersRefCount int, @DLCount int, @CreditCount int

	SELECT @EmplCount = count(1) 
	FROM   dbo.Empl
	WHERE  APNO = @APNO
	
	SELECT @EducatCount = count(1) 
	FROM   dbo.Educat
	WHERE  APNO = @APNO
	
	SELECT @ProfLicenseCount = count(1) 
	FROM   dbo.ProfLic
	WHERE  APNO = @APNO
	
	SELECT @PersRefCount = count(1) 
	FROM   dbo.PersRef
	WHERE  APNO = @APNO
	
	SELECT @DLCount = count(1) 
	FROM   dbo.DL
	WHERE  APNO = @APNO
	
	SELECT @CreditCount = count(1) 
	FROM   dbo.Credit
	WHERE  APNO = @APNO	
	AND    RepType = 'C'	
	
	SELECT 	@APNO APNO, @EmplCount Empl_Count,  @EducatCount Educat_Count, @ProfLicenseCount ProfLic_Count, @PersRefCount PersRef_Count, @DLCount DL_Count, @CreditCount Credit_Count	
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED 	
END
