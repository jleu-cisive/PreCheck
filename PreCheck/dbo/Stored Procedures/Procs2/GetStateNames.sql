-- Alter Procedure GetStateNames

CREATE PROCEDURE dbo.GetStateNames
   @Country varchar(25)
AS
SET NOCOUNT ON
SELECT DISTINCT State FROM dbo.TblCounties WHERE Country=@Country and State Is NOT NULL ORDER BY State
