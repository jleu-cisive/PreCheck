--====================================================================================================================== 
--Author:        Nazish Rehman
--Create Date:   05-04-2023
--Description:   Fetch record for sending reminder email  
--===========================================================================================================================

--exec [dbo].[GetRecordforReminderEmail] @defaultreminderdelay=24 ,@reminderAction='Reminder1'
CREATE PROC [dbo].[GetRecordforReminderEmail] (@defaultreminderdelay int = 48,
@reminderAction nvarchar(50) = 'Reminder1')
AS
BEGIN

  IF (@reminderAction = 'Reminder1')
  BEGIN
    SELECT
      AssociateSubscriptionActionLogId,
      ApplicantId,
      apno,
      First,
      Last,
      Email,
      CLNO,
      IsReminder,
	  DASubscriptionActionTypeID
    FROM (SELECT DISTINCT
      sal.ApplicantId,
      a.apno,
      a.First,
      a.Last,
      a.Email,
      a.CLNO,
	  DASubscriptionActionTypeID,
      (SELECT TOP 1
        AssociateSubscriptionActionLogId
      FROM Enterprise.Subscription.AssociateSubscriptionActionLog WITH (NOLOCK)
      WHERE ordernumber = a.apno
      AND Isactive = 1
      AND IsProcessed = 1)
      AssociateSubscriptionActionLogId,
      (CASE
        WHEN cc2.CLNO IS NOT NULL THEN 0
        ELSE 1
      END) AS 'IsReminder',
      (CASE
        WHEN EXISTS (SELECT
            OrderNumber
          FROM Enterprise.Subscription.AssociateSubscriptionActionLog WITH (NOLOCK)
          WHERE OrderNumber = a.APNO
          AND DASubscriptionActionTypeID = 9021
          AND Isactive = 1
          AND IsProcessed = 1) THEN '1'
        ELSE '0'
      END) AS FirstReminderSent,
      (CASE
        WHEN EXISTS (SELECT
            OrderNumber
          FROM Enterprise.Subscription.AssociateSubscriptionActionLog WITH (NOLOCK)
          WHERE OrderNumber = a.APNO
          AND DASubscriptionActionTypeID = 8779
          AND Isactive = 1
          AND IsProcessed = 1) THEN '1'
        ELSE '0'
      END) AS IsNoMatchSent -- 8779 no match Action Id
    FROM Enterprise.Subscription.AssociateSubscriptionActionLog sal WITH (NOLOCK)
    JOIN dbo.appl a
      ON a.apno = sal.ordernumber
    LEFT JOIN dbo.clientconfiguration cc WITH (NOLOCK)
      ON cc.clno = a.clno
      AND cc.configurationkey = 'VelocityReminderDelay'
    LEFT JOIN dbo.clientconfiguration cc2 WITH (NOLOCK)
      ON cc2.clno = a.clno
      AND cc2.configurationkey = 'DoNotSendReminder'
    LEFT JOIN velocity.claimedcredentialslog ccl WITH (NOLOCK)
      ON ccl.apno = sal.ordernumber
    WHERE sal.isprocessed = 1
    AND sal.isactive = 1
    AND sal.dasubscriptionactiontypeid = 8778
    AND ccl.apno IS NULL
    AND (cc2.clno IS NULL
    OR cc2.value = 'True') --8778 notification actionid
    AND ((cc.value IS NULL
    AND sal.modifydate < DATEADD(HOUR, -@defaultreminderdelay, CURRENT_TIMESTAMP))
    OR (cc.value IS NOT NULL
    AND sal.modifydate < DATEADD(HOUR, -CAST(cc.value AS int), CURRENT_TIMESTAMP)))) x
    WHERE x.FirstReminderSent = 0
    AND IsNoMatchSent = 0
  END
  ELSE
  IF (@reminderAction = 'Reminder2')
  BEGIN
    SELECT
      associatesubscriptionactionlogid,
      applicantid,
      apno,
      first,
      last,
      email,
      clno,
      IsReminder,
	  DASubscriptionActionTypeID

    FROM (SELECT DISTINCT
      sal.applicantid,
      a.apno,
      a.first,
      a.last,
      a.email,
      a.clno,
	  DASubscriptionActionTypeID,
      (SELECT TOP 1
        AssociateSubscriptionActionLogId
      FROM Enterprise.Subscription.AssociateSubscriptionActionLog WITH (NOLOCK)
      WHERE ordernumber = a.apno
      AND Isactive = 1
      AND IsProcessed = 1)
      AssociateSubscriptionActionLogId,
      (CASE
        WHEN cc2.clno IS NOT NULL THEN 0
        ELSE 1
      END) AS 'IsReminder',
      (CASE
        WHEN EXISTS (SELECT
            ordernumber
          FROM Enterprise.subscription.associatesubscriptionactionlog WITH (NOLOCK)
          WHERE ordernumber = a.apno
          AND dasubscriptionactiontypeid = 9022
          AND Isactive = 1
          AND IsProcessed = 1) THEN '1'
        ELSE '0'
      END) AS SecondReminderSent, --9022  Second Reminder ActionId
      (CASE
        WHEN EXISTS (SELECT
            OrderNumber
          FROM Enterprise.Subscription.AssociateSubscriptionActionLog WITH (NOLOCK)
          WHERE OrderNumber = a.APNO
          AND DASubscriptionActionTypeID = 8779
          AND Isactive = 1
          AND IsProcessed = 1) THEN '1'
        ELSE '0'
      END) AS IsNoMatchSent
    FROM Enterprise.subscription.associatesubscriptionactionlog sal
    JOIN dbo.appl a
      ON a.apno = sal.ordernumber
    LEFT JOIN dbo.clientconfiguration cc WITH (NOLOCK)
      ON cc.clno = a.clno
      AND cc.configurationkey = 'VelocityReminderDelay2'
    LEFT JOIN dbo.clientconfiguration cc2 WITH (NOLOCK)
      ON cc2.clno = a.clno
      AND cc2.configurationkey = 'DoNotSendReminder2'
    LEFT JOIN velocity.claimedcredentialslog ccl WITH (NOLOCK)
      ON ccl.apno = sal.ordernumber  --9021 first reminder actionid
    WHERE sal.dasubscriptionactiontypeid = 9021
    AND sal.isprocessed = 1
    AND sal.isactive = 1
    AND ccl.apno IS NULL
    AND (cc2.clno IS NULL
    OR cc2.value = 'True')
    AND ((cc.value IS NULL
    AND sal.modifydate < DATEADD(HOUR, -@defaultreminderdelay, CURRENT_TIMESTAMP)))) y
    WHERE y.secondremindersent = 0
    AND IsNoMatchSent = 0
  END
END