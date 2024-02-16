-- Create Procedure GetPreCheckCountyFromZipCrimLead
/*
EXEC [dbo].[GetPreCheckCountyFromZipCrimLead] 'ABUSE', NULL, 'OH', NULL
EXEC [dbo].[GetPreCheckCountyFromZipCrimLead] 'FELMSD', NULL, 'OH', 'STATEWIDE'
EXEC [dbo].[GetPreCheckCountyFromZipCrimLead] 'FELMSD', NULL, 'SD', 'WALWORTH'
EXEC [dbo].[GetPreCheckCountyFromZipCrimLead] 'FELMSD', NULL, 'TX', 'STATEWIDE'
EXEC [dbo].[GetPreCheckCountyFromZipCrimLead] 'FELMSD', null, 'az', 'YUMA'
EXEC [dbo].[GetPreCheckCountyFromZipCrimLead] 'FELMSD', '01085', 'Al', 'LOWNDES'
*/
CREATE PROCEDURE [dbo].[GetPreCheckCountyFromZipCrimLead]
	@leadType varchar(6), @fips varchar(5), @subType varchar(20), @subType2 varchar(100), @reportType varchar(20) = NULL
AS
	DECLARE @specialCounties TABLE(cnty_no int, cntyToOrder int, state varchar(2) NULL, leadType varchar(6) NULL)
	INSERT INTO @specialCounties
	(
	    cnty_no,cntyToOrder
	)
	VALUES
	(
	    1, -- STATEWIDE, TX
	    2682 -- DPS STATEWIDE, TX,
	),
	(
	    3348, -- STATEWIDE, SC
	    4167 -- STATEWIDE(SLED), SC	
	)
	--INSERT ABUSE AND OFFENDER COUNTIES
	INSERT INTO @specialCounties
	(
	    cnty_no,
	    cntyToOrder,
	    [state],
	    leadType
	)
	SELECT CNTY_NO, CNTY_NO, LTRIM(RTRIM([State])), 'ABUSE' FROM dbo.Counties WHERE CNTY_NO IN (5295)	
	UNION ALL
	SELECT CNTY_NO, CNTY_NO, LTRIM(RTRIM([State])), 'OFFNDR' FROM dbo.Counties WHERE cnty_no IN (5098)
	
	IF (@leadType = 'ABUSE' OR @leadType = 'OFFNDR')
	BEGIN
		SELECT sc.cntyToOrder FROM @specialCounties sc WHERE sc.leadType = @leadType AND sc.[state] = @subType
		RETURN 0
	END

	IF (@leadType = 'BNKRPT')
	BEGIN
		SELECT c.CNTY_NO FROM dbo.Counties c WHERE c.A_County = 'FEDERAL BANKRUPTCY'
		RETURN 0
	END 
	
	IF (@leadType = 'FEDCRM' AND @subType = 'NATIONWIDE')
	BEGIN
		SELECT c.CNTY_NO FROM dbo.Counties c WHERE c.A_County = 'DISTRICT COURT FEDERAL'
		RETURN 0
	END
	
	IF (@leadType = 'FEDCRM')
	BEGIN
		SELECT 
			cpj.CNTY_NO
		FROM dbo.County_PartnerJurisdiction cpj
		WHERE cpj.[State] = @subType 
			AND cpj.JurisdictionName = @subType2
			AND cpj.IsActive = 1
			AND cpj.LeadType = @leadType
		GROUP BY cpj.CNTY_NO, cpj.LeadType, cpj.[State], cpj.JurisdictionName
		RETURN 0
	END
	
	IF @leadType = 'FELMSD'
	BEGIN
		IF @fips IS NOT NULL
		BEGIN
			--modified by schapyala on 06/23/2020			
			declare @cnty int
			SELECT @cnty = [dbo].[GetPreCheckCountyFromFIPS](@fips, @reportType)

			--added logic to look by subtype and subtype2 in case FIPS does not return the county
			IF @cnty is null
				SELECT @cnty = CNTY_NO FROM dbo.Counties c
				WHERE C.[State] = @subType AND C.A_County = @subType2
			
			Select @cnty
			--end --modified by schapyala on 06/23/2020	
			RETURN 0;
		END
		IF @subType = 'TX DPS'
		BEGIN
			SELECT CNTY_NO FROM dbo.Counties c
			WHERE C.[State] = 'TX' AND C.A_County = 'TEXAS DPS STATEWIDE'
			RETURN 0;
		END
		IF @subType2 = 'GCIC'
		BEGIN
			SELECT cnty_no FROM dbo.Counties c
			WHERE c.[State] = 'GA' AND a_county = '**STATEWIDE GCIC STAMP**'
			RETURN 0;
		END

		IF @subType2 = 'STATEWIDE'
		BEGIN
			--SELECT coalesce(sc.cntyToOrder, c.CNTY_NO) AS CNTY_NO FROM dbo.Counties c
			--LEFT JOIN @specialCounties sc ON sc.cnty_no = c.CNTY_NO
			--WHERE c.refCountyTypeID = 2 
			--AND c.[State] = @subType
			--AND (COUNTY = ('**STATEWIDE**, ' + c.[STATE]) OR A_County = '**STATEWIDE**')
			--AND c.CNTY_NO NOT IN (4163,15,4198)
			--RETURN 0;

			IF (@subType = 'SC')
			BEGIN
				SELECT coalesce(sc.cntyToOrder, c.CNTY_NO) AS CNTY_NO FROM dbo.Counties c
				LEFT JOIN @specialCounties sc ON sc.cnty_no = c.CNTY_NO
				WHERE c.refCountyTypeID = 2 
				AND c.[State] = @subType
				AND (COUNTY = ('**STATEWIDE**, ' + c.[STATE]) OR A_County = '**STATEWIDE (SLED)**')
				AND c.CNTY_NO NOT IN (4163,15,4198)
				RETURN 0;
			END 
			ELSE IF (@subType = 'TX') -- VD: 03/10/2020 - TPID#86752 - Need the TX DPS Statewide Search configured
			BEGIN
				SELECT CNTY_NO FROM dbo.Counties c
				WHERE C.[State] = 'TX' AND C.A_County = 'TEXAS DPS STATEWIDE'
				RETURN 0;
			END
			ELSE IF (@subType = 'OH') -- kiran - 02/15/2023  need to add special county for OH Statewide
			BEGIN
				SELECT coalesce(sc.cntyToOrder, c.CNTY_NO) AS CNTY_NO FROM dbo.Counties c
				LEFT JOIN @specialCounties sc ON sc.cnty_no = c.CNTY_NO
				WHERE c.refCountyTypeID = 2 
				AND c.[State] = @subType
				AND (COUNTY = ('**STATEWIDE ZIPCRIM**, ' + c.[STATE]) OR A_County = '**STATEWIDE ZIPCRIM**')
				AND c.CNTY_NO NOT IN (4163,15,4198)
				RETURN 0;
			END
			ELSE
			BEGIN
				SELECT coalesce(sc.cntyToOrder, c.CNTY_NO) AS CNTY_NO FROM dbo.Counties c
				LEFT JOIN @specialCounties sc ON sc.cnty_no = c.CNTY_NO
				WHERE c.refCountyTypeID = 2 
				AND c.[State] = @subType
				AND (COUNTY = ('**STATEWIDE**, ' + c.[STATE]) OR A_County = '**STATEWIDE**')
				AND c.CNTY_NO NOT IN (4163,15,4198)
				RETURN 0;
			END
		END
		--catch all added by schapyala on 06/23/2020
		SELECT CNTY_NO FROM dbo.Counties c
		WHERE C.[State] = @subType AND C.A_County = @subType2
		Return 0
	END
