
/*===========================================
Requested By: Maxine
Developer: Prasanna
Execution : EXEC [dbo].[UnlockReportAudit]  '' , '10/20/2016'
=============================================*/

CREATE Procedure [dbo].[UnlockReportAudit]
	@apno int,
	@UnlockDate datetime = null
As

Begin

   If ((@apno != '' or @apno != 0) and (@UnlockDate != '' or @UnlockDate != null))
      select * from [dbo].[AppLockInfo] where apno = @apno and convert(varchar(12),convert(datetime,[date],103),101) = @UnlockDate;

   else if ((@apno != '' or @apno != 0) and (@UnlockDate = '' or @UnlockDate = null))
       select * from [dbo].[AppLockInfo] where apno = @apno;

  else if ((@apno = '' or @apno = 0) and (@UnlockDate != '' or @UnlockDate != null))
       select * from [dbo].[AppLockInfo] where convert(varchar(12),convert(datetime,[date],103),101) = @UnlockDate;
  else 
       select * from [dbo].[AppLockInfo];

End