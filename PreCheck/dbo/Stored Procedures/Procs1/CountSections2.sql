
CREATE PROCEDURE CountSections2
	@Apno int,
	@Empl smallint OUTPUT,
	@Educat smallint OUTPUT,
	@ProfLic smallint OUTPUT,
	@PersRef smallint OUTPUT,
	@Civil smallint OUTPUT,
	@Credit smallint OUTPUT,
	@DL smallint OUTPUT,
	@Social smallint OUTPUT
as
	SET NOCOUNT ON
	SELECT @Empl = count(*) FROM Empl WHERE Apno = @Apno
	select @Educat = count(*) from Educat where Apno = @Apno
	select @ProfLic = count(*) from ProfLic where Apno = @Apno
	select @PersRef = count(*) from PersRef where Apno = @Apno
	SELECT @Civil = COUNT(*) FROM Civil WHERE Apno = @Apno
	SELECT @Credit = COUNT(*) FROM Credit WHERE Apno = @Apno and RepType = 'C'
	SELECT @DL = COUNT(*) FROM DL WHERE Apno = @Apno
	SELECT @Social = COUNT(*) FROM Credit WHERE Apno = @Apno and RepType = 'S'
