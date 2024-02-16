
-- =============================================
-- Author:		Humera Ahmed
-- Create date: 2/5/2018
-- Description:	Create a QReport for Company Employment Verification Status Performance that excludes a client and its affiliates
-- =============================================
CREATE PROCEDURE [dbo].[Company_Empl_Verf_Stat_Exlcude_Affliate] 
	-- Add the parameters for the stored procedure here
	@StartDate DateTime, 
	@EndDate DateTime,
	@AffliateId nvarchar(max) = '0'
	AS
BEGIN
	-- Insert statements for procedure here
	
	DECLARE @AFFILIATETABLE TABLE(AFFILIATEID int)
	SET NOCOUNT ON;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
   
	IF @AffliateId ='0'
		Select --'Totals' Total, 
			(Select count(1) From dbo.Empl J (NoLock) where  (InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate))) ) [Verifications Assigned],
			(Select count(1) From dbo.Empl A (NoLock)  where web_Updated is not null and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)))  [Verifications - Updated WebStatus],
			(Select count(1) From dbo.Empl B (NoLock)  where sectstat = '4' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [VERIFIED],
			(Select count(1) From dbo.Empl C (NoLock)  where sectstat = '5'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [VERIFIED/SEE ATTACHED],
			(Select count(1) From dbo.Empl D (NoLock)  where sectstat = '6' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [UNVERIFIED/SEE ATTACHED],
			(Select count(1) From dbo.Empl E (NoLock)  where sectstat = '8' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [SEE ATTACHED],
			(Select count(1) From dbo.Empl F (NoLock)  where sectstat = '7' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [ALERT/SEE ATTACHED],
			(Select count(1) From dbo.Empl G (NoLock)  where sectstat = '3' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE/SEE ATTACHED],
			(Select count(1) From dbo.Empl H (NoLock)  where sectstat = '2' and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))) [COMPLETE],
			(Select count(1) From dbo.Empl I (NoLock)  where sectstat = '9'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [Pending - Assigned],
			(Select count(1) From dbo.Empl I (NoLock)  where sectstat = 'C'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [ALERT],
			(Select count(1) From dbo.Empl I (NoLock)  where sectstat = 'U'and Last_Worked>= @StartDate and Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) ) [UNVERIFIED],

		    (Select count(1) From dbo.Empl E (NoLock) inner JOin Appl A (NoLock) on E.APNO = A.APNO  where sectstat = '9' and  A.ApStatus not in ('F') ) [Pending - Overall]
   	ELSE
		INSERT INTO @AFFILIATETABLE( AFFILIATEID )
		SELECT Item FROM dbo.Split(':', @AffliateId)
	   
		Select --'Totals' Total, 
			(Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
				LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
				WHERE
				(InvestigatorAssigned>= @StartDate and InvestigatorAssigned< = dateadd(s,-1,dateadd(d,1,@EndDate)))  --[Verifications Assigned],
				AND af.AFFILIATEID IS NULL
			) [Verifications Assigned],

		 (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		  LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		  WHERE 
				e.web_Updated is not null 
				AND e.Last_Worked>= @StartDate 
				AND e.Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) 
				AND af.AFFILIATEID IS NULL
		  ) [Verifications - Updated WebStatus],

		  (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		  LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		  WHERE  
				sectstat = '4'
				AND Last_Worked>= @StartDate
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) 
				AND af.AFFILIATEID IS null
		  ) [VERIFIED],

		   (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = '5'
				AND Last_Worked>= @StartDate
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) 
				AND af.AFFILIATEID IS null
			) [VERIFIED/SEE ATTACHED],

		  (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = '6' 
				AND Last_Worked>= @StartDate
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))
				AND af.AFFILIATEID IS null
			) [UNVERIFIED/SEE ATTACHED],

		   (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = '8'
				AND Last_Worked>= @StartDate 
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))
				AND af.AFFILIATEID IS null
			)[SEE ATTACHED],

		   (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = '7' 
				AND Last_Worked>= @StartDate 
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))
				AND af.AFFILIATEID IS null
			) [ALERT/SEE ATTACHED],

		   (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = '3'
				AND Last_Worked>= @StartDate 
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))
				AND af.AFFILIATEID IS null
			) [COMPLETE/SEE ATTACHED],

		   (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = '2' 
				AND Last_Worked>= @StartDate
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate))
				AND af.AFFILIATEID IS null
			) [COMPLETE],

		   (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = '9'
				AND Last_Worked>= @StartDate 
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) 
				AND af.AFFILIATEID IS null
			)  [Pending - Assigned],

			(Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = 'C'
				AND Last_Worked>= @StartDate 
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) 
				AND af.AFFILIATEID IS null
			)  [ALERT],

			(Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = 'U'
				AND Last_Worked>= @StartDate 
				AND Last_Worked< = dateadd(s,-1,dateadd(d,1,@EndDate)) 
				AND af.AFFILIATEID IS null
			)  [UNVERIFIED],

		   (Select count(1) From dbo.Empl e (NoLock) join dbo.Appl a (NOLOCK) on e.Apno=a.APNO JOIN dbo.Client c (NOLOCK) ON c.clno=a.CLNO 
		   LEFT OUTER JOIN @AFFILIATETABLE af	ON af.AFFILIATEID = isnull(c.AffiliateID,0)
		   WHERE 
				sectstat = '9'
				AND A.ApStatus not in ('F') 
				AND af.AFFILIATEID IS null
			)  [Pending - Overall]
END
