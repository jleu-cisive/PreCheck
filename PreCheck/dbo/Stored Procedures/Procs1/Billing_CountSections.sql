-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_CountSections]
	@Apno int
AS
BEGIN
--DECLARE @Empl smallint
--DECLARE @Educat smallint
--DECLARE @Proflic smallint
--DECLARE @PersRef smallint
--DECLARE @Civil smallint
--DECLARE @DL smallint
--DECLARE @Social smallint
	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--SELECT @Empl = count(*) FROM Empl WHERE Apno = @Apno
	--select @Educat = count(*) from Educat where Apno = @Apno
	--select @ProfLic = count(*) from ProfLic where Apno = @Apno
	--select @PersRef = count(*) from PersRef where Apno = @Apno
	--SELECT @Civil = COUNT(*) FROM Civil WHERE Apno = @Apno
	--SELECT @Credit = COUNT(*) FROM Credit WHERE Apno = @Apno and RepType = 'C'
	--SELECT @DL = COUNT(*) FROM DL WHERE Apno = @Apno
	--SELECT @Social = COUNT(*) FROM Credit WHERE Apno = @Apno and RepType = 'S'
SELECT CONVERT(varchar(2),(SELECT count(*) FROM Empl WHERE Apno = @Apno AND IsOnReport = 1 AND IsHidden = 0)) + ',' +
CONVERT(varchar(2),(SELECT count(*) from Educat where Apno = @Apno AND IsOnReport = 1 AND IsHidden = 0)) + ',' +
CONVERT(varchar(2),(SELECT count(*) from ProfLic where Apno = @Apno AND IsOnReport = 1 AND IsHidden = 0)) + ',' +
CONVERT(varchar(2),(SELECT count(*) from PersRef where Apno = @Apno AND IsOnReport = 1 AND IsHidden = 0)) + ',' +
CONVERT(varchar(2),(SELECT COUNT(*) FROM Civil WHERE Apno = @Apno)) + ',' +
CONVERT(varchar(2),(SELECT COUNT(*) FROM Credit WHERE Apno = @Apno and RepType = 'C' AND IsHidden = 0))+ ',' +
CONVERT(varchar(2),(SELECT COUNT(*) FROM DL WHERE Apno = @Apno  AND IsHidden = 0)) + ',' +
CONVERT(varchar(2),(SELECT COUNT(*) FROM Credit WHERE Apno = @Apno and RepType = 'S'  AND IsHidden = 0))

SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
