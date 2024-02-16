


CREATE PROCEDURE [dbo].[Client_BackgroundCheck_Pending_ReportDetails_CA] 
		-- Add the parameters for the stored procedure here
	@CLNO varchar(max) = NULL,
	@AffiliateID INT =0			--=	0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF		(@CLNO = '0' OR @CLNO = ''	OR LOWER(@CLNO) = 'null') SET @CLNO = NULL

    -- Insert statements for procedure here
	SELECT a.Apno as 'Report Number'
			, c.CLNO as 'Client ID'
			, c.Name as 'Client Name'
			, ra.Affiliate as 'Affiliate'
			, a.first as 'First Name'
			, a.last as 'Last Name'
			,FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt')  as 'Report Created Date', 
			 case when (dbo.elapsedbusinessdays_2( a.Apdate, a.Origcompdate) 
				   + dbo.elapsedbusinessdays_2(a.Reopendate, a.Compdate)) < 6 then (dbo.elapsedbusinessdays_2(a.Apdate, a.Origcompdate) 
				   + dbo.elapsedbusinessdays_2(a.Reopendate, a.Compdate))
		     else 6 end as 'Elapsed Business Days'
			 , Replace(REPLACE(a.Priv_Notes, char(10),';'),char(13),';') as 'Private Notes'
	FROM Appl a with (Nolock)
	INNER JOIN Client c with (Nolock) on c.clno = a.clno
	INNER JOIN refAffiliate ra with (Nolock) on ra.AffiliateID = c.AffiliateID
	WHERE a.Apstatus='P'
		AND  c.AffiliateID = IIF(@affiliateId=0,c.affiliateId, @affiliateId) 
		AND (@Clno IS NULL OR A.CLNO IN (SELECT * from [dbo].[Split](':',@Clno)))


END





