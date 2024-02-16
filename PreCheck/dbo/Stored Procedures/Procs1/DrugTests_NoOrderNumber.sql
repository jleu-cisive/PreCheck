
CREATE PROCEDURE DrugTests_NoOrderNumber (@NumberofHours int = 12) AS
SELECT CLNO,C.FirstName,C.LastName,C.SSNOrOtherID,C.OrderStatus,C.DateReceived,C.TestResult,C.TestResultDate,C.LastUpdate,Coc FROM dbo.OCHS_ResultDetails C (NOLOCK)
WHERE (ISNULL(OrderIDOrApno,'0') ='0' OR LTRIM(RTRIM(OrderIDOrApno))='')  AND C.LastUpdate>DATEADD(HOUR,-@NumberofHours,CURRENT_TIMESTAMP)
