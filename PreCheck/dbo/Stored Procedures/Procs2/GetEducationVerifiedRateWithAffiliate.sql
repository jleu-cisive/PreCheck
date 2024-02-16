-- ==============================================================================================
-- Author:		Suchitra Yellapantula
-- Create date: 09/06/2016
-- Description:	Get the Client Verified Rate - Education Verifications with Affiliate information
-- ===============================================================================================
CREATE PROCEDURE [dbo].[GetEducationVerifiedRateWithAffiliate]
	-- Add the parameters for the stored procedure here
 @Startdate date ,
 @Enddate date,
 @Affiliate varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		Declare @sects table
		(
		 status varchar(1),
		 Affiliate varchar(50)
		)

		declare @results table
		(
			StatusType varchar(100),
			Affiliate varchar(50),
			Count int,
			Percentage decimal(12,2)
		)

		declare @totalcount int

		
		 insert into @sects
		 SELECT [t1].SectStat, [t3].Affiliate
		 FROM [Appl] as [t0], [Educat] as [t1], refAffiliate as [t3], Client as [t2]
		 where (convert(date,[t1].[Last_Worked]) >= @Startdate) AND (convert(date,[t1].[Last_Worked]) <= @Enddate) AND ([t1].[Apno] = [t0].[APNO]) AND  ([t1].IsOnReport = 1)
		 and ([t1].IsHidden=0)
		 AND (convert(date,[t1].[CreatedDate]) >= @Startdate) AND (convert(date,[t1].[CreatedDate]) <= @Enddate) 
		 and [t0].CLNO = [t2].clno and [t2].AffiliateID = [t3].AffiliateID
		-- and ([t3].Affiliate like '%'+@Affiliate +'%')
		and Affiliate = LTRIM(RTRIM(@Affiliate))
		
		
		--order by [t1].SectStat
		set @totalcount = (select count(*) from @sects)

		insert into @results (statustype, Affiliate, count, percentage)
		select s.Description, x.Affiliate, count(*),  (convert(decimal, count(*))/ convert(decimal, @totalcount)) * 100
		from SectStat s
		join @sects x on x.status = s.code
		group by s.Description, x.Affiliate

		insert into @results (statustype, Affiliate, count, percentage) select 'Total', '', @totalcount, 0

		select * from @results

END