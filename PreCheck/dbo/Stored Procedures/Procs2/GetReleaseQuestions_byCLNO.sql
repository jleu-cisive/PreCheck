-- =============================================
-- Author:		Prasanna
-- Create date: 03/13/2017
-- Description:	Get ReleaseQuestions by CLNO
-- Exec GetReleaseQuestions_byCLNO 2135
-- =============================================
CREATE PROCEDURE [dbo].[GetReleaseQuestions_byCLNO]
	@CLNO int
AS
BEGIN

	select ccr.CLNO,   (CASE ccr.ContactPresentEmployer WHEN 1 THEN 'True' else 'False' END) as ContactPresentEmployer,rq.Question as ReleaseQuestions
   from [dbo].[ClientConfig_Release] ccr
   inner join [dbo].[ReleaseQuestions] rq on ccr.CLNO = rq.CLNO where rq.clno = @CLNO

END
