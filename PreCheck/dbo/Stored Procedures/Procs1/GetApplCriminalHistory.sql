-- =============================================
-- Author:		schapyala
-- Create date: 06/06/2012
-- Description:	Returns applicant's Criminal history based on SSN
-- =============================================
CREATE PROCEDURE [dbo].[GetApplCriminalHistory] 
@APNO INT, @SSN varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
	
	--DECLARE @TblSelfDisclosed AS TABLE( [id] INT IDENTITY(1,1) NOT NULL, Crim_SelfDisclosed BIT NULL, DisclosedDate DATETIME NULL);
	DECLARE @Crim_SelfDisclosed BIT, @DisclosedDate DATETIME
	
	--Insert Into @TblSelfDisclosed
	SELECT TOP 1  @Crim_SelfDisclosed = Crim_SelfDisclosed,@DisclosedDate = DateCreated
	FROM   dbo.ApplAdditionalData 
	WHERE  SSN = @SSN 
	AND DateDiff(YY,DateCreated,current_timestamp)<=10 
	ORDER BY DateCreated Desc
	
	--SELECT ISNULL(Crim_SelfDisclosed,0) Crim_SelfDisclosed, DisclosedDate
	--FROM @TblSelfDisclosed
	
	SELECT ISNULL(@Crim_SelfDisclosed,0) Crim_SelfDisclosed, @DisclosedDate DisclosedDate
	
	IF(Select count(1) FROM dbo.ApplicantCrim WHERE  APNO = @APNO)>0
		SELECT City, State,Country,CrimDate,Offense
		FROM   dbo.ApplicantCrim 
		WHERE  APNO = @APNO
	ELSE
		SELECT Distinct City, State,Country,CrimDate,Offense
		FROM   dbo.ApplicantCrim 
		WHERE  SSN = @SSN
	
	SELECT distinct County, CaseNo,Date_Filed,Disp_Date,Offense,CNTY_NO
	FROM   dbo.Appl A inner join dbo.Crim C ON A.APNO = C.APNO
	WHERE  (A.SSN = @SSN) --or C.SSN = @SSN)
	AND    [Clear] 	= 'F'
	AND    IsHidden = 0	
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED 


END
