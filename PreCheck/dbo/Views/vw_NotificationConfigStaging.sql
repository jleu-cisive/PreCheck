/***************************************
Date Created: 8/17/2015
Author: Gaurav Bangia
select * from vw_NotificationConfigStaging
****************************************/
CREATE VIEW [dbo].[vw_NotificationConfigStaging]
as
SELECT        NotificationConfigID, CLNO, Email, First, Last, ContactTitle, refNotificationTypeID, OnRequest
FROM            Precheck_Staging.dbo.NotificationConfig