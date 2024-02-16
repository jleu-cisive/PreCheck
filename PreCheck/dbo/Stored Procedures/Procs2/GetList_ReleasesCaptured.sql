CREATE procedure [dbo].[GetList_ReleasesCaptured] (@ParentCLNO INT,@additionalCLNO INT = 0,@startDate Datetime =NULL,@NumberofDays INT = 1,@MaskSSN bit = 1) AS

SET NOCOUNT ON
SET TRAN ISOLATION LEVEL READ UNCOMMITTED

declare  @EndDate datetime 

IF  @startDate is null 
	Set @startDate = Dateadd(d,-@NumberofDays,getdate())
	
	set  @EndDate = getdate()

	--select @startDate,@EndDate

Select R.clno,	last,	first,	SSN=CASE WHEN @MaskSSN =1 THEN 'xxx-xx-' + RIGHT(ssn,4) else ssn end,	dob = CASE WHEN @MaskSSN =1 THEN NULL ELSE dob END , date	datecaptured

  FROM dbo.ReleaseForm R inner join [PreCheck].[dbo].[ClientHierarchyByService] H on R.clno = H.CLNO where 
  
 (parentclno =@ParentCLNO) AND [refHierarchyServiceID] = 2 and date between @startDate and @EndDate

 UNION ALL

 SELECT CLNO,last,first,SSN = CASE WHEN @MaskSSN =1 THEN 'xxx-xx-' + RIGHT(ssn,4) else ssn end,	dob = CASE WHEN @MaskSSN =1 THEN NULL ELSE dob END , date	datecaptured
 FROM dbo.ReleaseForm
 WHERE CLNO = @additionalCLNO AND date between @startDate and @EndDate


SET TRAN ISOLATION LEVEL READ COMMITTED 
SET NOCOUNT OFF