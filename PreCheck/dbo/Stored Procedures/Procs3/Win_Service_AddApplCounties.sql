
-- =============================================
-- Author:		Najma Begum	
-- Create date: 03/2013
-- Description:	insert counties returned by sources and update isactive
-- =============================================
-- =============================================
-- Author:		Yves Fernandes	
-- Create date: 08/28/2019
-- Description:	insert counties returned by sources and update isactive
-- =============================================
CREATE PROCEDURE [dbo].[Win_Service_AddApplCounties] 
	-- Add the parameters for the stored procedure here
	@Apno int, @County varchar(50), @SourceID int, @CntyNo int,
	@CntyNoToOrder int,@CountyCount int,@IsStateWide bit, @State varchar(2), @SourceIdntyColVal int--, @ReturnValue int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
--	IF(@ReturnValue = 0)
--	BEGIN
--	IF (EXISTS (SELECT * FROM dbo.ApplCounties WHERE Apno=@Apno))
--BEGIN
--	Update dbo.ApplCounties set IsActive =  0 where apno = @Apno;
--	SET @ReturnValue = 1;
--	--set @returnval = 1;
--END	
--END
if(@County is not null AND @County <> '')
BEGIN
Insert into dbo.ApplCounties(Apno,County,CNTY_NUM, CNTY_NUMToOrder, SourceID, CountyCount, IsStateWide, [State],SourceIdntyColValue, IsActive)
values(@Apno, @County,  @CntyNo,@CntyNoToOrder,@SourceID,@CountyCount,@IsStateWide, @State, @SourceIdntyColVal, CASE @SourceID WHEN 12 THEN 0 WHEN 13 THEN 0 ELSE 1 END);
END
--RETURN @returnval;
END
