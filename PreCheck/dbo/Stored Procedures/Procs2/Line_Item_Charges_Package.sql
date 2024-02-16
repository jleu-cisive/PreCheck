-- =============================================  
-- Author:  Vairavan A 
-- Create date: 25/05/2023  
-- Description: Modify Existing QReport: Line Item Charges Package - Ala Carte
---Testing
/*
EXEC dbo.Line_Item_Charges_Package '0','2023-01-01' ,'2023-06-07' ,'0'
*/
-- =============================================  
CREATE PROCEDURE [dbo].Line_Item_Charges_Package
    @CLNO VARCHAR(MAX),  -- = '1307',  
	@StartDate DATETIME, --= '06/01/2019' ,  
    @EndDate DATETIME,   --='06/30/2019',  
	@AffiliateIDs VARCHAR(MAX) = '0'
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

    IF (@CLNO = '0' OR @CLNO = '' OR LOWER(@CLNO) = 'null')
    BEGIN
        SET @CLNO = NULL
    END;

	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END

	select ap.Clno,Inv.Apno,Inv.CreateDate Date,Description,Amount 
	from invdetail Inv WITH (NOLOCK) 
	inner join Appl Ap WITH (NOLOCK)
	on Inv.Apno = Ap.Apno
	INNER JOIN Client C  with (NOLOCK)  ON Ap.CLNO = C.CLNO
	where amount <> 0 
	and Inv.billed = 1 
	and type <> 0 
	and ap.clno  = isnull(@CLNO,ap.clno)
	and Inv.createdate >= @StartDate 
	and Inv.createdate < DATEADD(d,1,@EndDate) 
	and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))

END
