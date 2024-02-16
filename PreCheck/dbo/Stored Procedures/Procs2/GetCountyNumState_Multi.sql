-- Alter Procedure GetCountyNumState_Multi


-- =============================================
CREATE PROCEDURE [dbo].[GetCountyNumState_Multi] 
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

	Declare @Counties Table (CNTY_NO int,IsStateWide Bit,County varchar(50),Fips varchar(10),State char(2),Cnty_NoToOrder Int)

    
	if (LEN(@Zip) > 0)
	BEGIN
		Insert Into @Counties (County,[State],Fips)
		Select COUNTY,[STATE],Fips FROM [MainDB].[dbo].zipcode_county  WHERE ZIP = @Zip order by PERCENTAGE desc

		IF (Select count(1) from @Counties) = 0 
			Insert Into @Counties (County,[State],Fips)
			Select COUNTY,Z.[STATE],Fips 
			FROM [MainDB].[dbo].zipcode_county  zc inner join [MainDB].[dbo].zipcode z on z.Zip = zc.Zip 
			WHERE Z.City = @City AND Z.[STATE] = @State 
			order by zc.PERCENTAGE desc	
			

		--SELECT TOP 1 @County= COUNTY, @ZState = [STATE], @Fips=Fips FROM [MainDB].[dbo].zipcode_county  WHERE ZIP = @Zip order by PERCENTAGE desc;
		--	if(@County is NULL and @ZState is NULL and LEN(@City)> 0 and LEN(@State) > 0)
		--		SELECT TOP 1 @County = COUNTY, @Fips=Fips FROM [MainDB].[dbo].zipcode_county  zc inner join [MainDB].[dbo].zipcode z on z.Zip = zc.Zip WHERE Z.City = @City AND Z.[STATE] = @State order by zc.PERCENTAGE desc;
		--	Else
		--		SET @State = @ZState;	
	END
	else if (LEN(@City)> 0 and LEN(@State) > 0)
		BEGIN
			Insert Into @Counties (County,[State],Fips)
			Select COUNTY,Z.[STATE],Fips 
			FROM [MainDB].[dbo].zipcode_county  zc inner join [MainDB].[dbo].zipcode z on z.Zip = zc.Zip 
			WHERE Z.City = @City AND Z.[STATE] = @State 
			order by zc.PERCENTAGE desc

			--SELECT TOP 1 @County = COUNTY,  @Fips=Fips  FROM [MainDB].[dbo].zipcode_county zc inner join [MainDB].[dbo].zipcode z on z.Zip = zc.Zip  WHERE Z.City = @City AND z.[STATE] = @State order by zc.PERCENTAGE desc;
		END
	else if (LEN(@County)> 0 and LEN(@State) > 0)
		BEGIN
			Insert Into @Counties (County,[State],Fips)
			SELECT  COUNTY,[STATE],Fips 
			FROM [MainDB].[dbo].zipcode_county  
			WHERE County = @County AND [STATE] = @State 
			order by PERCENTAGE desc
			--SELECT TOP 1 @Fips=Fips  FROM [MainDB].[dbo].zipcode_county  WHERE County = @County AND [STATE] = @State order by PERCENTAGE desc;
		END

	--if(LEN(@Fips) > 0)
	--BEGIN
	--	Select @IsStateWide = isnull(isStatewide,0) from dbo.Counties where Fips = @Fips
	--	if(@IsStateWide = 1)
	--		begin

	--			SELECT TOP 1 CNTY_NO , @IsStateWide as isStateWide, A_County as County, @State as State,isnull((Select CNTY_NO FROM dbo.Counties WHERE A_County ='**STATEWIDE**' AND State = @State), CNTY_NO) as CNTY_NoToOrder
	--			FROM dbo.Counties WHERE Fips = @Fips;
	--		end
	--	else
	--		begin
	--			SELECT TOP 1 CNTY_NO , isnull(isStatewide,0) as isStatewide, @County as County, @State as State, CNTY_NO as Cnty_NoToOrder FROM dbo.Counties WHERE Fips = @Fips;
	--		end
	--END
	--ELSE
	--BEGIN
	--	Exec [dbo].[GetCountyNumStateNoFips] @State, @County;
 --	END

	Update tmp
	Set CNTY_NO = C.CNTY_NO ,isStateWide = ISNULL(C.isStateWide,0),County = A_County, CNTY_NoToOrder = Case when isnull(C.isStatewide,0) = 1 then (Select CNTY_NO FROM dbo.TblCounties WHERE A_County ='**STATEWIDE**' AND State = @State) else C.CNTY_NO end 
	from @Counties tmp left join dbo.TblCounties C on tmp.Fips is Not Null and tmp.Fips = C.Fips

	Update tmp
	Set CNTY_NO = C.CNTY_NO ,isStateWide = ISNULL(C.isStateWide,0), CNTY_NoToOrder = Case when isnull(C.isStatewide,0) = 1 then (Select CNTY_NO FROM dbo.TblCounties WHERE A_County ='**STATEWIDE**' AND State = @State) else C.CNTY_NO end 
	from @Counties tmp inner join dbo.TblCounties C on tmp.County = C.A_County  AND tmp.State = C.State

	Update tmp
	Set CNTY_NO = C.CNTY_NO ,isStateWide = ISNULL(C.isStateWide,0),County = A_County, CNTY_NoToOrder = Case when isnull(C.isStatewide,0) = 1 then (Select CNTY_NO FROM dbo.TblCounties WHERE A_County ='**STATEWIDE**' AND State = @State) else C.CNTY_NO end  
	from @Counties tmp left join dbo.TblCounties C on (tmp.County  + ', ' + tmp.State) = C.County  AND tmp.State = C.State
	Where tmp.CNTY_No is null

	SELECT * FROM @Counties

END
