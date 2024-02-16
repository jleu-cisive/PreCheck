-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].ReleaseNotificationEmail_InOasis
AS
BEGIN
      select ccr.CLNO,c.Name from ClientConfig_Release ccr
	  inner join Client c on  ccr.CLNO = c.CLNO where ccr.ReleaseNotificationEmail in('PrecheckApplications@precheck.com','Applications@Precheck.com');
END
