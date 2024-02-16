

CREATE PROCEDURE [dbo].[ClientAffiliateAndWeight] 


AS

SELECT C.CLNO, C.Name, A.Affiliate, ISNULL(W.Weight, 50) AS Weight, (CASE WHEN C.IsInactive = 1 THEN 'Y' ELSE 'N' END) as IsInActive FROM dbo.Client C 
LEFT OUTER JOIN dbo.ClientWeight W ON C.CLNO = W.CLNO AND W.WeightType = 'Investigator' 
LEFT JOIN refAffiliate A ON C.AffiliateID = A.AffiliateID ORDER BY W.Weight DESC, C.Name

