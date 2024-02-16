



-- This stored procedure sets all nonzero manual charges for unbilled applications from all active clients who are in the S billing cycle to zero.
CREATE PROCEDURE [dbo].[UPDATE_Manual_Charges]
AS
SET NOCOUNT ON

UPDATE DBO.INVDETAIL
SET AMOUNT = 0
WHERE INVDETID IN
(
	SELECT I.INVDETID
	FROM DBO.APPL A INNER JOIN DBO.INVDETAIL I ON A.APNO = I.APNO
	WHERE A.CLNO IN
	(
		SELECT CLNO
		FROM DBO.CLIENT
		WHERE BILLINGCYCLEID = 10 AND ISINACTIVE = 0
	)
	AND I.TYPE = 1 AND I.BILLED = 0 AND I.AMOUNT > 0 AND (description not like 'Service%')
)
--zero out sex offender charges
update DBO.invdetail set amount = 0 where invdetid 
in
(select invdetid from DBO.invdetail where type = 2 and amount > 0 and description like '%sex offender%'
and billed = 0)

