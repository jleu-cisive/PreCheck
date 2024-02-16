CREATE  PROCEDURE dbo.sp_get_camEmail
	@clientid	int
AS


SELECT     u.EmailAddress, c.CAM, c.CLNO
FROM         Precheck..Users u INNER JOIN
                      Precheck..Client c ON u.UserID = c.CAM
WHERE     c.CLNO = @clientid
