



CREATE PROCEDURE [dbo].[Employment_Status_ByClient_ByDate] 
@clno int,
@SDate datetime,
@EDate datetime

AS

SELECT   'Employment' as Section ,a.APNO,ApStatus ,Description as status , CLNO ,Employer,e.city,e.state,e.zipcode , e.Priv_Notes , e.Pub_Notes,a.ssn
FROM         dbo.Appl a (NOLOCK) inner join dbo.Empl e (NOLOCK) on a.APNO = e.APNO
inner join SectStat s (NOLOCK) on e.SectStat = s.code
WHERE     (CLNO = @clno) and (ApDate between @SDate and DATEADD(d,1,@EDate)) and e.ishidden = 0


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON


