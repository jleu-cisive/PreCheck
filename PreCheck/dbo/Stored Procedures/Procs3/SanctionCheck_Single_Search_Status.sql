-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 08/27/2019
-- Description:	Report to show the status of SanctionCheck Single Searches (Online Resolutions)
-- Execution: EXEC SanctionCheck_Single_Search_Status
-- =============================================
CREATE PROCEDURE [dbo].[SanctionCheck_Single_Search_Status] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT T.CLNO, C.[Name] AS [Client Name], T.[First], T.Middle, T.[Last],T.Username, T.CreatedDate, R.[Status]
	FROM Precheck_NHDB.[dbo].[NHDBWeb_Transaction] AS T
	INNER JOIN Precheck_NHDB.[dbo].[NHDBWeb_Resolution] AS R ON T.NHDBWeb_TransactionID = R.NHDBWeb_TransactionID
	INNER JOIN PRECHECK.dbo.Client AS C ON T.CLNO = C.CLNO
	WHERE (R.[STATUS] IN ('Further Review','Pending','In Progress') OR R.[STATUS] IS NULL)
	  AND T.CLNO NOT IN (2135)

END
