CREATE PROCEDURE [dbo].[AdverseGetStudentReject] 
 @ClientID varchar(10)
AS

Select APNO, AdverseActionID
FROM AdverseAction
WHERE AdverseActionID in
(

Select AdverseActionID
FROM AdverseActionHistory 
WHERE  (StatusID = 6 or  StatusID = 7 or  StatusID = 10 or  StatusID = 13) AND AdverseActionID in
(
SELECT AdverseActionID
FROM dbo.AdverseAction  
WHERE 
--StatusID = 6 or  StatusID = 7 or  StatusID = 10 or  StatusID = 13 or StatusID = 18)  and 
Hospital_CLNO =  @ClientID
)
)