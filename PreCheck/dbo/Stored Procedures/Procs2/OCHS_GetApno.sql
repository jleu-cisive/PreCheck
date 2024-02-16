


-- =============================================
-- Author:		Najma Begum
-- Create date: 09/26/2012
-- Description:	Get Apno from SSN/CLNO/FN/LN
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_GetApno]
	-- Add the parameters for the stored procedure here
	@SSN varchar(11)='', @Clno int = '',@FN varchar(20)='',@LN varchar(20)='', @Org varchar(17)='',@FileName varchar(100) OUTPUT,
	@IsApno bit = 0 OUTPUT, @HasConfig bit = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	if(@Clno is not NULL and @Clno <> '')
	BEGIN
		select @HasConfig = IsNull([Value], 0) from ClientConfiguration where ConfigurationKey = 'WO_Merge_DrugScreeningRequired' and clno = @clno
	
		-- Insert statements for procedure here
		if(@HasConfig = 1)
			BEGIN
				Declare @Count int;
				Declare @SSNCount int;

	
				if(@Org <> '' and @Org is not NULL)
				begin
					SET @Org = '_' + @Org;
				end
	
				if(@Clno is NULL)
					SET @Clno = '';
	
				if(@SSN is NULL)
					SET @SSN = '';
	
	
				if(@SSN <> '' and @Clno <> '')
					begin
						--REPLACE(pid.ssn, '-', '')
						select @SSNCount = count(*) from appl where LTrim(RTRIM(REPLACE(SSN,'-',''))) = REPLACE(@SSN, '-','');
						select @Count = count(*) from appl where LTrim(RTRIM(REPLACE(SSN,'-',''))) = REPLACE(@SSN, '-','') and Clno = @Clno;
						if((@Count = 0 Or @Count > 1) AND(@FN <> '' and @LN <> ''))
							BEGIN
								select @Count = count(*) from appl where First = @FN and Last = @LN and clno = @Clno and LTrim(RTRIM(REPLACE(SSN,'-',''))) = REPLACE(@SSN, '-','');
								if(@Count = 1)
									BEGIN
										select @FileName = Cast(apno as varchar(20)) from appl where First = @FN and Last = @LN and clno = @Clno and LTrim(RTRIM(REPLACE(SSN,'-',''))) = REPLACE(@SSN, '-','');
										SET @IsApno = 1;
									END
								ELSE
									begin
									--if(@SSNCount > 0)
									--	BEGIN
									--		select @FileName = @SSN ;
									--	END
									--	ELSE
									--	BEGIN
											select @FileName = @LN + ',' + @FN + '_' + @SSN + @Org;
									--	END
									end
		
							END
		
						ELSE
							BEGIN
							 select @FileName = Cast(apno as varchar(20)) from appl where LTrim(RTRIM(REPLACE(SSN,'-',''))) = REPLACE(@SSN, '-','') and Clno = @Clno;
							 SET @IsApno = 1;
							END

						if(@FileName is null or @FileName = '')
							select @FileName =  @SSN;
					END
		
				ELSE if (@SSN <> '' and @Clno = '')
					BEGIN
						select @Count = count(*) from appl where LTrim(RTRIM(REPLACE(SSN,'-',''))) = REPLACE(@SSN, '-','');
						if((@Count > 1 or @Count = 0) AND (@FN <> '' and @LN <> ''))
							BEGIN
								select @Count = count(*) from appl where First = @FN and Last = @LN and LTrim(RTRIM(REPLACE(SSN,'-',''))) = REPLACE(@SSN, '-','');
								if(@Count = 1)
									BEGIN
										select @FileName = apno from appl where First = @FN and Last = @LN and LTrim(RTRIM(REPLACE(SSN,'-',''))) = REPLACE(@SSN, '-','');
										SET @IsApno = 1;
									END
								ELSE
									BEGIN
									--select @FileName = @FN + ', ' + @LN + @Org;
									--select @FileName = @SSN;
									--if(@Count > 0)
									--	BEGIN
									--		select @FileName = @SSN ;
									--	END
									--	ELSE
									--	BEGIN
											select @FileName = @LN + ',' + @FN + '_' + @SSN + @Org;
									--	END
		
									END
		
							END
						ELSE if(@Count = 1)
							BEGIN
							 select @FileName = Cast(apno as varchar(20)) from appl where LTrim(RTRIM(REPLACE(SSN,'-',''))) = REPLACE(@SSN, '-','');
							END

						if(@FileName is null or @FileName = '')
							select @FileName =  @SSN;
					END


				Else if(@SSN = '' and @Clno <> '' AND (@FN <> '' and @LN <> ''))
					BEGIN
						select @Count = count(*) from appl where First = @FN and Last = @LN and clno = @Clno;
						if(@Count = 1)
							Begin
								select @FileName = Cast(apno as varchar(20)) from appl where First = @FN and Last = @LN and clno = @Clno;
							End
						Else
							begin
								select @FileName = @LN + ', ' + @FN + @Org;
							end
					END
		
				else if(@SSN = '' and @Clno = '' and @FN <> '' and @LN <> '')
					begin
					select @FileName = @LN + ', ' + @FN + @Org;
					end
		END
	END
	
END

