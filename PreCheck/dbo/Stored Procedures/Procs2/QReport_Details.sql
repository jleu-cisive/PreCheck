-- =============================================
-- Author:		Suchitra Yellapantula
-- Create date: 08/26/2016
-- Description:	Details of all the Q-Reports currently in the system
-- =============================================
CREATE PROCEDURE [dbo].[QReport_Details]

AS
BEGIN
DECLARE @t table(QReportID int, QReportName varchar(300),Requestor varchar(8), Users varchar(max))

INSERT INTO @t
SELECT Q.QReportID,QueryDesc,Q.UserID,U.UserID from QReport Q,QReportUserMap U 
WHERE Q.QReportID = U.QReportID


SELECT QReportID,QReportName,Requestor,
STUFF((SELECT ',' + CAST(T2.Users as Varchar(MAX)) FROM @t T2 where T1.QReportID = T2.QReportID AND T1.QReportName = T2.QReportName for XML PATH('')),1,1,'') Users
FROM @t T1 
GROUP BY QReportID, QReportName, Requestor

END
