-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[AutoCreate_Import_temp]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    create table #tmpAppl (  id int identity,apno int, ApDate Datetime)

	insert into #tmpAppl
	Select Apno,ApDate 
	From DBO.Appl 
	where APNO in (SELECT    Apno
FROM         dbo.TCHAppno)

select * from #tmpAppl
 
--If @CreateCrim = 1 -- Loop through the apps created and create crim records for the counties specified and set them to pending
--	Begin
		declare @id int
		declare @apno int
		declare @crimid int
		
        select @id = 0
		while @id < (select max(id) from #tmpAppl)
                begin
					select @id = @id + 1

                    select 	@apno = apno
					from	#tmpAppl
					where	#tmpAppl.id = @id
					
					
						exec  createcrim  @apno, 2480, @crimid

					
						exec  createcrim  @apno, 2682, @crimid					
 
					
						exec  createcrim  @apno, 3519, @crimid	

				
              
                 end	

		--if @SetCrim_Pending = 1 --Set Crim records to Pending. This will be skipped if @SetCrim_Pending = 0
			Update Crim set Clear = 'R' 
			Where Apno in (Select Apno From #tmpAppl)
	--End

	DROP TABLE #tmpAppl 
END
