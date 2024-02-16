
-- =============================================
-- Author:		Prasanna
-- Create date: 8/22/2013
-- Description:	get the Release text for specific client for Online release
-- =============================================
CREATE  PROCEDURE [dbo].[sp_ReleaseText]
@clno int
As
Begin
if  ((select Count(*) from ReleaseText where clientType='online release'and  clno=@clno) > 0)
	begin
		select Top 1 * from ReleaseText where clientType='online release' and clno=@clno order by LastModifiedDate desc
	End
else
	begin
		select Top 1 * from ReleaseText where clientType='online release' and clno=0 order by LastModifiedDate desc
	End
End

