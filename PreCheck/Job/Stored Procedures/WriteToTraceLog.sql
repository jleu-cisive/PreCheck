
-- [Job].[WriteToTraceLog] 'BB', 'Insert Batch', 'Test', 'Normal'
CREATE PROCEDURE [Job].[WriteToTraceLog] 
-- =============================================
-- Author:		Gaurav Bangia
-- Create date: 10/26/2022
-- Description:	
-- =============================================
@Component VARCHAR(5),
@TaskName VARCHAR(50),
@Message VARCHAR(2000),
@TraceLevel VARCHAR(10)
AS

INSERT INTO [Job].[TraceLog]
(
[Component]
,[TaskName]
,[Message]
,[TraceLevel]
,[CreateDate])
VALUES(
@Component,
@TaskName,
@Message,
@TraceLevel,
GetDate()
)




