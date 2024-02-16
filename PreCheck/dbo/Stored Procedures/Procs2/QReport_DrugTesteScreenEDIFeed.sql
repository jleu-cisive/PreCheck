-- =============================================  
-- Author:      Prasanna  
-- Create date: 03/12/2021  
-- Description: Pull drug testing results from the Screen EDI Feed and pair with the Cost Center associated with the order  
-- Execution:  EXEC dbo.[QReport_DrugTesteScreenEDIFeed] '4/1/2019','4/30/2019','',7519,null  
-- 7519, 11625  
-- =============================================  
/*
ModifiedBy		ModifiedDate	TicketNo	Description
Shashank Bhoi	10/13/2022		67226		#67226 Update Affiliate ID Parameter Parent HDT#56320
											Modify existing q-reports that have affiliate ids in their search parameters  
											Details:   
											Change search parameters for the Affiliate Id field  
											     * search by multiple affiliate ids (ex 4:297)  
											     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates  
											     * multiple affiliates to be separated by a colon    
											Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0) 
											EXEC [QReport_DrugTesteScreenEDIFeed] '4/25/2019','4/25/2019','17085',7519,null 

*/
CREATE PROCEDURE [dbo].[QReport_DrugTesteScreenEDIFeed]  
       @StartDate Datetime,  
       @EndDate DateTime,  
       @CLNO int,  
       @ParentCLNO int,  
    @Location varchar(100) = null,
	@AffiliateIDs varchar(MAX) = '0'--Code added by vairavan for ticket id -67226 
  
AS  
BEGIN  
		
       --Set @EndDate = DateAdd(dd,1,@EndDate)  

	--Code added by Shashank for ticket id -67226 starts
	SET NOCOUNT ON;
	IF(@AffiliateIDs = '' OR LOWER(@AffiliateIDs) = 'null' OR @AffiliateIDs = '0')  
	  SET @AffiliateIDs = NULL;  
	--Code added by Shashank for ticket id -67226 ends 
  
    IF(@clno is null or @clno='')  
    begin  
      set @clno=0  
    END  
  
    if(@ParentCLNO is null or @ParentCLNO='')   
    begin  
      set @ParentCLNO=0  
    end  
  
  ----Code Commented for Performance issue against ticket id -67226 start
  --  SELECT Config.Customer  as [CustomerNumber], R.FirstName + ' ' + R.LastName as [Donor Name],  
  --         R.DateReceived, CI.CostCenter, R.CoC as COC#, R.TID as [OCHS Transaction ID]  
  --  FROM OCHS_ResultDetails R(NOLOCK)  
  --  LEFT JOIN OCHS_CandidateInfo CI (NOLOCK) ON (R.OrderIDOrApno = cast(CI.apno as varchar) or R.OrderIDOrApno = cast(CI.OCHS_candidateInfoId as varchar))    
  --  LEFT JOIN ClientConfiguration_Drugscreening config(NOLOCK) on CI.[ClientConfiguration_DrugScreeningID] = config.[ClientConfiguration_DrugScreeningID]  
  --  INNER JOIN Client C (NOLOCK) on Config.CLNO = C.CLNO    
  --     WHERE convert(date, R.DateReceived) between @startdate and DATEADD(d,1,@EndDate)  
  --AND ( c.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)  
  --  OR c.WeborderparentCLNO = IIF(@ParentCLNO=0,C.WeborderparentCLNO,@ParentCLNO)  
  -- )  
  --OR config.Location = IIF(@Location=null,config.Location,@Location)  
  ----Code Commented for Performance issue against ticket id -67226 End

--Code added for Performance issue against ticket id -67226 Starts
;WITH CteR AS (
	SELECT	R.FirstName + ' ' + R.LastName as [Donor Name],CI.CostCenter, R.DateReceived,R.CoC as COC#, 
			R.TID as [OCHS Transaction ID],CI.[ClientConfiguration_DrugScreeningID]
	FROM	dbo.OCHS_ResultDetails					AS R(NOLOCK)  
			INNER JOIN dbo.OCHS_CandidateInfo		AS CI (NOLOCK) ON R.OrderIDOrApno = cast(CI.apno as varchar)
	WHERE	convert(date, R.DateReceived) between @startdate and DATEADD(d,1,@EndDate)
	UNION ALL
	SELECT	R.FirstName + ' ' + R.LastName as [Donor Name],CI.CostCenter, R.DateReceived,R.CoC as COC#, 
			R.TID as [OCHS Transaction ID],CI.[ClientConfiguration_DrugScreeningID]
	FROM	dbo.OCHS_ResultDetails					AS R(NOLOCK)  
			INNER JOIN dbo.OCHS_CandidateInfo		AS CI (NOLOCK) ON R.OrderIDOrApno = cast(CI.OCHS_candidateInfoId as varchar)
	WHERE	convert(date, R.DateReceived) between @startdate and DATEADD(d,1,@EndDate)
	)
		SELECT	Config.Customer  as [CustomerNumber], CI.[Donor Name],  
				CI.DateReceived, CI.CostCenter, CI.COC#, CI.[OCHS Transaction ID]  
		FROM	CteR												AS CI  
				INNER JOIN dbo.ClientConfiguration_Drugscreening	AS config(NOLOCK) on CI.[ClientConfiguration_DrugScreeningID] = config.[ClientConfiguration_DrugScreeningID]  
				INNER JOIN dbo.Client								AS C (NOLOCK) on Config.CLNO = C.CLNO 

       WHERE 
				(@AffiliateIDs IS NULL OR C.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) --Code added by Shashank for ticket id -67226  
				AND ( 
						c.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)  
						OR 
						c.WeborderparentCLNO = IIF(@ParentCLNO=0,C.WeborderparentCLNO,@ParentCLNO)  
					)  
   UNION ALL

	SELECT	Config.Customer  as [CustomerNumber], R.FirstName + ' ' + R.LastName as [Donor Name],  
			R.DateReceived, CI.CostCenter, R.CoC as COC#, R.TID as [OCHS Transaction ID]
    FROM dbo.OCHS_ResultDetails									AS R(NOLOCK)  
			INNER JOIN dbo.OCHS_CandidateInfo					AS CI (NOLOCK) ON (R.OrderIDOrApno = cast(CI.apno as varchar) or R.OrderIDOrApno = cast(CI.OCHS_candidateInfoId as varchar))    
			INNER JOIN dbo.ClientConfiguration_Drugscreening	AS config(NOLOCK) on CI.[ClientConfiguration_DrugScreeningID] = config.[ClientConfiguration_DrugScreeningID]  
			INNER JOIN dbo.Client								AS C (NOLOCK) on Config.CLNO = C.CLNO 
	WHERE config.Location = IIF(@Location=null,config.Location,@Location)
--Code added for Performance issue against ticket id -67226 Ends
  
   
END  
