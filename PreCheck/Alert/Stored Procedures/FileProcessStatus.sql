-- =============================================
-- Author:		Suresh Reddy
-- Create date: 04/21/2017
-- Description:	File processing job status
-- =============================================


CREATE PROCEDURE [Alert].[FileProcessStatus]
AS

	SELECT  TOP 1
		ApplicantId=1,
		   CandidateName = FF.FileNameOriginal,
		   Email= 'sureshreddy@precheck.com',
		   ClientName=(CONVERT(VARCHAR(10),FC.ClientID)),
		   CreateDate=FF.ReceivedDate, --CM.Last_Updated,
		   RecruiterEmail='sureshreddy@precheck.com',
		   HourSinceInitialNotification = 0,
		   MaxDate=CONVERT(VARCHAR(12),CONVERT(DATE,DATEADD(DAY,10,CURRENT_TIMESTAMP)),101),
		   HasBackground=0,
		   HasDrugTest=0,
		   HasImmunization=0
	
	FROM            [HEVN].DBO.FtpFileProcess AS FFP INNER JOIN
                [HEVN].DBO.FtpFiles AS FF ON FFP.FilesID = FF.FilesID INNER JOIN
                [HEVN].DBO.FtpClient AS FC ON FF.ClientID = FC.ClientID 
				INNER JOIN
				[HEVN].DBO.FtpFileQueue AS FQ ON FFP.ftpFileQueueID = FQ.ftpFileQueueID
	WHERE (FFP.ProcessEndDateTime > DateAdd(Hour,-3,GetDate())) 


