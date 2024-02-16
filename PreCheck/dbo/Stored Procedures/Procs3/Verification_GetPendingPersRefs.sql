
/***************************************************************************
* Procedure Name: [dbo].[Verification_GetPendingPersRefs] 'ARefChex'
* Created By: Amy Liu
* Created On: 11/09/2020
*****************************************************************************/


CREATE PROCEDURE [dbo].[Verification_GetPendingPersRefs]
@vendor varchar(30) =null
AS
BEGIN
	SET NOCOUNT ON;  
	SET FMTONLY OFF
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	CREATE TABLE #tmpOrders(	
	SectionKeyId int	
	)

	CREATE CLUSTERED INDEX IX_tmpOrders_01 ON #tmpOrders(SectionKeyId);

		--re-run the new order submission when it failed with dateordered left inside.
		--select pr.*
	update pr set pr.DateOrdered= null
	FROM dbo.PersRef pr  WITH (NOLOCK) INNER JOIN dbo.appl a WITH (NOLOCK) 
		ON a.apno = pr.apno
	INNER JOIN dbo.client c on c.CLNO = a.CLNO
	inner join dbo.Websectstat wss on pr.Web_Status = wss.code 
	WHERE 
	pr.sectstat in ('9')  
	and wss.description =isnull(@vendor,'Research')   --94 or 95
	and pr.dateordered is not null
	and pr.orderId is null 
	and a.apstatus in ('p','w')
	and IsNull(pr.IsOnReport,0) = 1 
	and datediff( hour, pr.web_updated, GETDATE())>1
		
		insert into #tmpOrders
--  declare @vendor varchar(30) =null
	select distinct pr.PersRefID 
	FROM dbo.PersRef pr  WITH (NOLOCK) INNER JOIN dbo.appl a WITH (NOLOCK) 
		ON a.apno = pr.apno
	INNER JOIN dbo.client c on c.CLNO = a.CLNO
	inner join dbo.Websectstat wss on pr.Web_Status = wss.code 
	WHERE 
	pr.sectstat in ('9')  
	and wss.description = isnull(@vendor,'ARefChex')   --94 or 95
	and pr.dateordered is null 
	and pr.orderId is null 
	and a.apstatus in ('p','w')
	and IsNull(pr.IsOnReport,0) = 1 

	UPDATE pr	  
	  SET pr.dateordered = cast(replace(CURRENT_TIMESTAMP, datepart(year,CURRENT_TIMESTAMP),1900) as datetime) --SY (DD put SYs change in on 10/4/2017): updated to include time information
	  FROM dbo.PersRef pr
	  INNER JOIN  #tmpOrders T ON pr.PersRefID= T.SectionKeyId



	
select pr.APNO as  PrecheckAPNO,a.CLNO as PrecheckCLNO, a.PackageID as PrecheckPckgID, pr.PersRefID as PrecheckRefID,  
		isnull(a.First,'') as ApplicantFirstName, isnull(a.Last,'') as ApplicantLastName, isnull(a.Phone,'') as ApplicantPhone, isnull(a.Email,'') as ApplicantEmail,
		pr.Name as ReferenceName,
 isnull(pr.Email,'') as ReferenceEmail, isnull(pr.Phone,'') as ReferencePhone, pr.JobTitle as ReferencePosition, 'Personal' as ReferenceType, 
 '' as ReferenceCompanyName, '' as ArefChexRefID, '' as CallBackURL
     FROM dbo.PersRef pr
       inner join #tmpOrders o  on pr.PersRefID = o.SectionKeyId
       INNER JOIN dbo.appl a ON a.apno = pr.apno
       INNER JOIN dbo.Client c ON a.CLNO = c.CLNO
	
Drop table #tmpOrders

END
