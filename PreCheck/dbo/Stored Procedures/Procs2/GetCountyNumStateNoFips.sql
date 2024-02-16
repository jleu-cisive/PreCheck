-- Alter Procedure GetCountyNumStateNoFips


-- =============================================
-- Author:		Najma, Begum
-- Create date: 3/21/2013
-- Description:	get county, state and county number given state and county without using FIPS code.
-- Modified By: Deepak Vodethela
-- Modified Date: 07/03/2018
-- Description: Added a condition to check for "*DPS STATEWIDE*, TX"
/*
 EXEC [dbo].[GetCountyNumStateNoFips] 'TX','*DPS STATEWIDE*'
 EXEC [dbo].[GetCountyNumStateNoFips] 'TX','**STATEWIDE**'
 EXEC [dbo].[GetCountyNumStateNoFips] 'UT','SALT LAKE'
 EXEC [dbo].[GetCountyNumStateNoFips] 'MD','ANNE ARUNDEL'
 */
-- =============================================
CREATE PROCEDURE [dbo].[GetCountyNumStateNoFips] 
	-- Add the parameters for the stored procedure here
	@State varchar(2),
	@County nvarchar(50) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Declare @IsStateWide bit;
    Declare @ZState varchar(2);
	   
	
	if(LEN(@County) > 0 AND LEN(@State) > 0)
		BEGIN
		if((select  Count(*) from dbo.TblCounties where A_County = @County AND State = @State) > 0)
			BEGIN
				Select @IsStateWide = isnull(isStatewide,0) from dbo.TblCounties where A_County = @County AND State = @State;
				if(@IsStateWide = 1)
					begin
						SELECT TOP 1 CNTY_NO , @IsStateWide as isStateWide, A_County as County, @State as State,isnull((Select CNTY_NO FROM dbo.TblCounties WHERE A_County ='**STATEWIDE**' AND State = @State), CNTY_NO) as CNTY_NoToOrder
						FROM dbo.TblCounties WHERE A_County = @County AND State = @State;
					end

				else if(@IsStateWide = 0)
						begin
						SELECT TOP 1 CNTY_NO , isnull(isStatewide,0) as isStatewide, @County as County, @State as State, CNTY_NO as Cnty_NoToOrder FROM dbo.TblCounties WHERE A_County = @County AND State = @State;
						end
	
				END
		  Else
				BEGIN
					SET @County = (@County + ', ' + @State);
					SELECT @IsStateWide = isnull(isStatewide,0) FROM dbo.TblCounties WHERE County = @County;
	
					if(@IsStateWide = 1)
						BEGIN
							-- VD: 07/03/2018 - Whenever a "**STATEWIDE**, TX" Past Cconviction was getting transferred, it was updating it to "*DPS STATEWIDE*, TX". This behaviour is wrong, therefore applied a fix.
							--SELECT TOP 1 CNTY_NO , @IsStateWide as isStateWide, A_County as County, @State as State,isnull((Select CNTY_NO FROM dbo.Counties WHERE A_County ='**STATEWIDE**' AND State = @State), CNTY_NO) as CNTY_NoToOrder
							IF (@County = '*DPS STATEWIDE*, TX')
							BEGIN
								SELECT TOP 1 CNTY_NO , @IsStateWide as isStateWide, A_County as County, @State as State,isnull((Select CNTY_NO FROM dbo.TblCounties WHERE County LIKE '%' + @County + '%' AND State = @State), CNTY_NO) as CNTY_NoToOrder
								FROM dbo.TblCounties WHERE County = @County AND State = @State;
							END
							ELSE
							BEGIN
								SELECT TOP 1 CNTY_NO , @IsStateWide as isStateWide, A_County as County, @State as State,isnull((Select CNTY_NO FROM dbo.TblCounties WHERE A_County ='**STATEWIDE**' AND State = @State), CNTY_NO) as CNTY_NoToOrder
								FROM dbo.TblCounties WHERE County = @County AND State = @State;
							END
						END
					ELSE IF(@IsStateWide = 0)
					BEGIN
						SELECT TOP 1 CNTY_NO , isnull(isStatewide,0) as isStatewide, @County as County, @State as State, CNTY_NO as Cnty_NoToOrder FROM dbo.TblCounties WHERE County = @County AND State = @State;
					END
				END
		END
END
