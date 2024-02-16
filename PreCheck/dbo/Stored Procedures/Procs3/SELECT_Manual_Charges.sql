-- This stored procedure returns all nonzero manual charges for unbilled applications from all active clients who are in the P billing cycle.
CREATE PROCEDURE dbo.SELECT_Manual_Charges
AS
SELECT I.*
FROM APPL A INNER JOIN INVDETAIL I ON A.APNO = I.APNO
WHERE A.CLNO IN
(
SELECT CLNO
FROM CLIENT
WHERE BILLINGCYCLEID = 6 AND ISINACTIVE = 0
)
AND I.TYPE = 1 AND I.BILLED = 0 AND I.AMOUNT > 0
ORDER BY I.INVDETID
