
-- =============================================
-- Author:		Amy Liu
-- Create date:02/01/2018
-- Description:	MVR Report which queries the state to show MVR current status in the time frame.
-- EXEC [dbo].[MVR_Worksheet_StatusReport] 'GA','1/1/1998', '1/28/2018',0
-- =============================================
CREATE PROCEDURE [dbo].[MVR_Worksheet_StatusReport]
 @DateFrom DateTime  =null,
 @DateTo DateTime  =null,
 @State char(2)  ='',
 @CLNO int =0 
AS
BEGIN

	SET NOCOUNT ON;
  --Declare @DateFrom DateTime  =null
  --Declare @DateTo DateTime  =null
  --Declare @State char(2)=''  
  --Declare @CLNO int  =0
  -- Set @State ='GA'
  --Set @DateFrom ='1/1/1998'  
  --Set @DateTo ='1/28/2018' 
  --Set @CLNO =0 --'2139'--

 IF OBJECT_ID('tempdb..#tempWorkSheet1') IS NOT NULL
    DROP TABLE #tempWorkSheet1
 IF OBJECT_ID('tempdb..#tempWorkSheet2') IS NOT NULL
    DROP TABLE #tempWorkSheet2

  select a.clno,r.Affiliate,d.ordered,d.dateordered,d.CreatedDate RecordCreatedOn, d.apno,a.last, a.first, a.middle, a.dob, a.dl_state, a.dl_number,sc.Description
  INTO #tempWorkSheet1
  from dl d with(nolock) 
  inner join appl a with(nolock) on d.apno = a.apno         
  inner join client c  with(nolock) on a.clno = c.clno          
  left join refaffiliate r  with(nolock) on c.affiliateid = r.AffiliateID 
  LEFT join [dbo].[SectStat] sc with(nolock) ON d.sectstat=sc.code
  where (a.CLNO = @CLNO or @CLNO = 0) and IsHidden=0 
  AND  IsNumeric(d.ordered) = 0 and IsDate(d.ordered) = 1  --- using d.ordered column datetime for the time range
  and (a.dl_state = @State or ISNULL(@State,'') = '')
  --AND  Convert(datetime,isnull(d.ordered,'1/1/1900' ))>='1/1/2017'  --Convert(datetime,'1/1/2017') 
 AND (  isnull(@DateFrom,'')='' OR ( Convert(datetime,d.ordered)>=Convert(datetime,@DateFrom)) )
 AND ( isnull(@DateTo,'')='' OR  (Convert(datetime,d.ordered)<=Convert(datetime,@DateTo)))

  select a.clno,r.Affiliate,d.ordered,d.dateordered,d.CreatedDate RecordCreatedOn, d.apno,a.last, a.first, a.middle, a.dob, a.dl_state, a.dl_number,sc.Description 
 INTO #tempWorkSheet2
  from dl d with(nolock) 
  inner join appl a with(nolock) on d.apno = a.apno         
  inner join client c  with(nolock) on a.clno = c.clno          
  left join refaffiliate r  with(nolock) on c.affiliateid = r.AffiliateID  
  LEFT join [dbo].[SectStat] sc with(nolock) ON d.sectstat=sc.code
  where (a.CLNO = @CLNO or @CLNO = 0) and IsHidden=0 
  AND ( IsNumeric(d.ordered) =1 or IsDate(d.ordered) = 0)  --- using d.ordered column datetime for the time range
  and (a.dl_state = @State or ISNULL(@State,'') = '')
  AND (  isnull(@DateFrom,'')='' OR ( isnull(nullif(d.dateOrdered,''),'1/1/1900') >=@DateFrom) )
  AND ( isnull(@DateTo,'')='' OR ( isnull(nullif(d.dateOrdered,''),'1/1/1900') >=@DateTo) )

	select ws.clno,ws.Affiliate,
	OrderedDate= CASE WHEN ( IsNumeric(ws.ordered) = 0 and IsDate(ws.ordered) = 1) THEN ws.ordered ELSE ws.dateordered end,
	--ws.ordered,ws.dateordered,
	ws.RecordCreatedOn, ws.apno,ws.last, ws.first, ws.middle, ws.dob, ws.dl_state, ws.dl_number,ws.Description AS status
	FROM
	(
		SELECT * 
		FROM #tempWorkSheet1
		UNION
		SELECT * 
		FROM #tempWorkSheet2
	) ws
	ORDER BY ws.dl_state,ws.apno

	 IF OBJECT_ID('tempdb..#tempWorkSheet1') IS NOT NULL
		DROP TABLE #tempWorkSheet1
	 IF OBJECT_ID('tempdb..#tempWorkSheet2') IS NOT NULL
		DROP TABLE #tempWorkSheet2

END
