-- Alter Procedure GetCountryNames

CREATE PROCEDURE dbo.GetCountryNames
AS
SET NOCOUNT ON

SELECT Distinct Country FROM dbo.TblCounties WHERE country IS NOT NULL ORDER BY Country
