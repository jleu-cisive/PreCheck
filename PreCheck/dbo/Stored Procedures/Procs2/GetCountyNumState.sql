-- Create Procedure GetCountyNumState

-- =============================================
-- Author:		Najma, Begum
-- Create date: 06/09/2012
-- Description:	get county, state and county number given city, state or zip.
--Updated by: NB, 03/2013 changed the dependency to Fips instead of county,state etc params of'course using
--			  those to arrive at Fips code.
--Updated by: NB, 05/03/2013 - to return countynum, state of highest percentage. This SP returns only one
--			  result/row. To get all the counties,have to do a distinct of FIPS instead of TOP 1 and then again
--			  have to get each countynum, state associated with that FIPS code. Or maybe rewrite or create a new SP
--			  to get multi resultset and leave this one for single result set.
-- =============================================
CREATE PROCEDURE [dbo].[GetCountyNumState] 
	-- Add the parameters for the stored procedure here
	@City varchar(16),
	@State varchar(5),
	@Zip varchar(5),
	@County nvarchar(50) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Declare @IsStateWide bit;
    Declare @ZState varchar(2);
	Declare @Fips varchar(10);

    
	if (LEN(@Zip) > 0)
	BEGIN
		SELECT TOP 1 @County= COUNTY, @ZState = [STATE], @Fips=Fips FROM [MainDB].[dbo].zipcode_county  WHERE ZIP = @Zip order by PERCENTAGE desc;
			if(@County is NULL and @ZState is NULL and LEN(@City)> 0 and LEN(@State) > 0)
				SELECT TOP 1 @County = COUNTY, @Fips=Fips FROM [MainDB].[dbo].zipcode_county  zc inner join [MainDB].[dbo].zipcode z on z.Zip = zc.Zip WHERE Z.City = @City AND Z.[STATE] = @State order by zc.PERCENTAGE desc;
			Else
				SET @State = @ZState;	
	END
	else if (LEN(@City)> 0 and LEN(@State) > 0)
		BEGIN
			SELECT TOP 1 @County = COUNTY,  @Fips=Fips  FROM [MainDB].[dbo].zipcode_county zc inner join [MainDB].[dbo].zipcode z on z.Zip = zc.Zip  WHERE Z.City = @City AND z.[STATE] = @State order by zc.PERCENTAGE desc;
		END
	else if (LEN(@County)> 0 and LEN(@State) > 0)
		BEGIN
			SELECT TOP 1 @Fips=Fips  FROM [MainDB].[dbo].zipcode_county  WHERE County = @County AND [STATE] = @State order by PERCENTAGE desc;
		END

	if(LEN(@Fips) > 0)
	BEGIN
		Select @IsStateWide = isnull(isStatewide,0) from dbo.TblCounties where Fips = @Fips
		if(@IsStateWide = 1)
			begin
				SELECT TOP 1 CNTY_NO , @IsStateWide as isStateWide, A_County as County, @State as State,isnull((Select CNTY_NO FROM dbo.TblCounties WHERE A_County ='**STATEWIDE**' AND State = @State), CNTY_NO) as CNTY_NoToOrder
				FROM dbo.TblCounties WHERE Fips = @Fips;
			end
		else
			begin
				SELECT TOP 1 CNTY_NO , isnull(isStatewide,0) as isStatewide, @County as County, @State as State, CNTY_NO as Cnty_NoToOrder FROM dbo.TblCounties WHERE Fips = @Fips;
			end
	END
	ELSE
	BEGIN
		Exec [dbo].[GetCountyNumStateNoFips] @State, @County;
 	END

END
