-- Alter Procedure GetCountyNames

CREATE PROCEDURE dbo.GetCountyNames
  @state varchar(25),
  @country varchar(25)
AS


SET NOCOUNT ON

SELECT DISTINCT A_County FROM dbo.TblCounties WHERE state=@state and country=@country and A_County IS NOT NULL ORDER BY A_County
--SELECT County FROM Counties ORDER BY County
