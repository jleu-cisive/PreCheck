
-- =============================================
-- Author:		Radhika Dereddy
-- Description:	TMH TAT Report for Robert Perez
-- EXEC Education_Status_ByClient_ByDate '10/01/2017','12/01/2017','5751'
-- Modified By : Radhika Dereddy on 12/4/2017 to include Attended Dates From and To
-- =============================================

CREATE PROCEDURE [dbo].[Education_Status_ByClient_ByDate] 
@clno int,
@SDate datetime,
@EDate datetime

AS

SELECT   'Education' as Section ,a.APNO,ApStatus,Description as status , CLNO , School , e.Priv_Notes , e.Pub_Notes,a.ssn,Degree_V, E.From_V as 'Attended From', E.To_V as 'Attended To'
FROM         dbo.Appl a (NOLOCK)   inner join dbo.Educat e (NOLOCK)  on a.APNO = e.APNO
inner join SectStat s (NOLOCK) on e.SectStat = s.code
WHERE     (CLNO = @clno) and (ApDate between @SDate and DATEADD(d,1,@EDate)) and e.ishidden = 0


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON



