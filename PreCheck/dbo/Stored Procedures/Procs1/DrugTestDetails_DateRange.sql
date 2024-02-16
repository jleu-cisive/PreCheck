-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Execution:  exec dbo.[DrugTestDetails_DateRange] '01/01/2022','09/30/2022','','','177:294'
-- Modified : Humera Ahmed 5/31/2018 for HDT 52896
-- Modified : Deepak Vodethela 06/04/2019 for HDT 52896m
-- Modified : Doug DeGenaro 6/17/2019 for HDT 53387
/* Modified By: Vairavan A
-- Modified Date: 10/28/2022
-- Description: Main Ticketno-67221 - Update Affiliate ID Parameter Parent HDT#56320
*/
-- =============================================
CREATE PROCEDURE [dbo].[DrugTestDetails_DateRange]
	-- Add the parameters for the stored procedure here
	@StartDate Date,
	@EndDate Date,
	@CLNO varchar(max),
	@ParentCLNO varchar(max),
	@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -67221
    --@AffiliateName varchar(max) = NULL

AS
BEGIN

--SET @StartDate = '--7/1/2014--';
--SET @EndDate = '--9/1/2015--';
--SET @CLNO = '--11045:3079:9041--';t

--code added by vairavan for ticket id -67221 starts
IF @AffiliateIDs = '0' 
BEGIN  
	SET @AffiliateIDs = NULL  
END
--code added by vairavan for ticket id -67221 ends

	Set @EndDate = DateAdd(dd,1,@EndDate)
	if(@clno is null or Ltrim(rtrim(@clno))='')
	begin
	  set @clno=0
	END

	if(@ParentCLNO is null or Ltrim(rtrim(@ParentCLNO))='') --Humera Ahmed 5/31/2018 for HDT 52896
	begin
	  set @ParentCLNO=0
	end

	SELECT  C.OCHS_CandidateInfoID,
			config.CLNO as [Client ID], -- Modified 6/17/2019 by Doug DeGenaro for HDT 53387
			CLT.[Name] as [Client Name], -- Added 6/17/2019 by Doug DeGenaro for HDT 53387
			RA.Affiliate,
			Case when Isnull(C.APNO,0)=0 then  [OCHS_CandidateInfoID] else C.APNO end OCHS_TransactionID
			,C.[LastName]
			,C.[FirstName]
			,C.[Middle]
			,C.Email
			,Description [TestReason]
			,[CostCenter]
			,[ClientIdent]
			,FORMAT(C.[CreatedDate],'MM/dd/yyyy hh:mm tt') as CreatedDate, -- Modified 6/17/2019 by Doug DeGenaro for HDT 53387
			Location,
			ProdCat,
			ProdClass,
			SpecType,
			IsNull(Customer,'201754') Customer,
			--OCHS_CandidateInfoScheduleByName as ScheduledBy,
			--a.Attn as [Requested By] 
			ISNULL(a.Attn,ISNULL(c.ClientIdent,CSref.OCHS_CandidateInfoScheduleByName)) as [Requested By] -- Modified 6/17/2019 by Doug DeGenaro for HDT 53387
	FROM [PreCheck].[dbo].[OCHS_CandidateInfo] C (NOLOCK)
	left join clientconfiguration_Drugscreening config(NOLOCK) on c.[ClientConfiguration_DrugScreeningID] = config.[ClientConfiguration_DrugScreeningID] 
	left join refTestReason r(NOLOCK) On C.TestReason = r.TestReasonID
	LEFT JOIN dbo.OCHS_CandidateSchedule CS(NOLOCK) ON C.OCHS_CandidateInfoID = CS.OCHS_CandidateID
	LEFT JOIN dbo.refOCHS_CandidateInfoSchedule CSref(NOLOCK) ON CS.ScheduledByID = CSref.refOCHS_CandidateInfoScheduleByID
	INNER JOIN dbo.Client CLT(NOLOCK) on CLT.CLNO = config.CLNO
	INNER JOIN [dbo].[refAffiliate] AS RA WITH(NOLOCK) ON CLT.AffiliateID = RA.AffiliateID
	LEFT JOIN dbo.Appl a on a.APNO = c.APNO
	 Left JOIN dbo.Client e with(nolock) ON a.CLNO = e.CLNO--code added by vairavan for ticket id - 67221
	Where C.CreatedDate >= @StartDate 
	  and C.CreatedDate < @EndDate 
	  and (config.CLNO in (Select value from dbo.fn_Split(@CLNO,':')) or @CLNO ='0')
	  AND (clt.WebOrderParentCLNO IN (Select value from dbo.fn_Split(@ParentCLNO,':')) or @ParentCLNO ='0') --Humera Ahmed 5/31/2018 for HDT 52896
	--AND (@AffiliateName IS NULL OR RA.Affiliate = @AffiliateName)
	 and (@AffiliateIDs IS NULL OR e.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221
	order by CreatedDate
END

