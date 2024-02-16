-- ================================================
-- Author:		Suchitra Yellapantula
-- Create date: 08/29/2016
-- Description:	Returns the list of clients by CAM
-- ================================================
CREATE PROCEDURE Client_List_By_CAM 
	-- Add the parameters for the stored procedure here
	@CAMInput varchar(8)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @CAMInput = LTRIM(RTRIM(@CAMInput));

	SELECT C.CLNO, C.Name as 'Client Name', A.Affiliate, C.CAM
	FROM Client C 
	INNER JOIN refAffiliate A ON C.AffiliateID = A.AffiliateID
	WHERE (@CAMInput is null) or (@CAMInput ='') or (C.CAM like '%'+@CAMInput +'%');

END
