-- Alter Procedure Win_Service_UpdateCrimClearStatus

-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 04/30/2020
-- Description: Update Clear status to Pending ("R")
-- =============================================
 CREATE PROCEDURE [dbo].[Win_Service_UpdateCrimClearStatus] 
	-- Add the parameters for the stored procedure here
	@Apno int, 
	@ClearValue varchar(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*Auto-Clear Lead Step Start - schapyala on 05/19/2020 */
	If @ClearValue = 'R' --AutoClear service only for AutoOrdered APNOs. Anything routed to AI should be handled after the fact
		Begin
			Declare @SkipAutoClear Bit = 0 

			--Skip AutoClear if Admitted Record
			Select @SkipAutoClear = Case When isnull(D.Crim_SelfDisclosed,0) = 1 then cast(1 as bit) else cast(0 as bit) end
			From dbo.ApplAdditionalData D 
			Where APNO =@Apno

			--Skip AutoClear if ZipCrim clients
			Select @SkipAutoClear = Case When AffiliateID IN (249) --249 (everifile/zipcrim)
												  Then cast(1 as bit) else cast(0 as bit) End
			From DBO.APPL A inner Join dbo.CLient C on A.CLNO = C.CLNO
			Where APNO = @Apno
	
			--Skip AutoClear if Past Convictions Exist
			IF (select count(1) from ApplCounties Where APNO =@Apno and SourceID = 4) > 0 --Past Convictions
				Set @SkipAutoClear = 1

			--Qualify for AutoClears only when there is [no Self-Disclosure or Past COnvictions] and for NON-ZipCrim Clients
			--IF @SkipAutoClear = 0
				--Logic for setting Clear status to Y - "Auto Clear - Intellicorp" for qualified counties by partner (5 - Intellicorp) table configuration
				UPDATE C Set [Clear] = Case When (PJ.County IS NULL OR @SkipAutoClear = 1) then @ClearValue else 'Y' end,
				Priv_Notes = Case When (PJ.County IS NULL OR @SkipAutoClear = 1) then Priv_Notes else (CAST( CURRENT_TIMESTAMP as varchar) + ' - Jurisdiction Qualified after Appl-PreProcess Lead-Step for Intellicorp AutoClear service;  ' + isnull(Priv_Notes,'')) End
				FROM dbo.Crim C LEFT JOIN dbo.County_PartnerJurisdiction PJ on C.CNTY_NO = PJ.CNTY_NO 
				AND   PartnerID in (4) -- Intellicorp and Crim Db
				WHERE APNO = @APNO 
				
		End
	/*Auto-Clear Lead Step END - schapyala on 05/19/2020 */

	/* schapyala - COVID RELATED BLURBS AND SETTING THE STATUS*/
		Declare @IsBusinessContinuityRelated Bit = 0
		If (Select c.affiliateid from dbo.Appl a inner join dbo.client c on a.clno = c.clno 
											 inner join dbo.refAffiliate r on c.AffiliateID = r.AffiliateID
								 Where a.APNO = @APNO) not in (147,149,200,252,253) --exclude CHI, Dignity and Common spirit			
		BEGIN	
			SET @IsBusinessContinuityRelated = 1
		END

	  --Add Blurbs 	  
      Update t Set Pub_Notes = Pub_Notes + '; ' + char(9) + char(13)+  CONVERT (VARCHAR(10), current_timestamp, 103) + ' - ' + CountyBlurb
	  ,[Clear] = case when (C.IsBusinessContinuityRelated = 1 and @IsBusinessContinuityRelated = 1)  then 'S' else @ClearValue end
	  From  dbo.Crim t inner join dbo.refCountyBlurb C on t.CNTY_NO = C.CNTY_NO 
	  Inner Join  dbo.Counties  on t.CNTY_NO = Counties.CNTY_NO
	  WHERE Apno = @Apno AND ISNULL([CLEAR],'') <> 'Y' 
	  AND (
			  C.CNTY_NO IS NOT NULL --specific county
			  OR isnull(C.refCountyTypeID,0) = 5 --international
			  OR (C.CountyState IS NOT NULL AND    isnull(Counties.refCountyTypeID,0) <> (Case When ExcludeStateWide =1 then 2 else 0 end)) --2 is statewide ----State level counties excluding statewide for some
	      )
	 


	--UPDATE Crim SET [Clear] = @ClearValue WHERE Apno = @Apno;
END
