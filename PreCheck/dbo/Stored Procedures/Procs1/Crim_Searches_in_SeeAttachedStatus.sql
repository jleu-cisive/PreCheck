-- Alter Procedure Crim_Searches_in_SeeAttachedStatus
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/02/2020
-- Requester: Misty Smallwood
-- Description: Please create a Qreport for any criminal search in a "See Attached" status.  
-- No date parameters necessary. Mirror the Qreport "Crim Searches in More Info Needed status" 
-- but add 2 columns for Client Name and Client Affiliate please. 
-- Modified by Doug DeGenaro on 08/04/2020 to add CrimID 
-- Modified by Radhika on 01/12/2021 to add Crim Public Notes
-- EXEC [Crim_Searches_in_SeeAttachedStatus]
 -- =============================================
CREATE PROCEDURE [dbo].[Crim_Searches_in_SeeAttachedStatus]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	  
 SELECT  c.CrimID, a.APNO, a.CLNO, cl.Name as ClientName, ra.Affiliate, a.UserID, a.ApDate,a.Apstatus, a.[Last], a.[First],   
 TblCounties.A_County + ', ' + TblCounties.State AS county, c.Clear as CrimStatus,c.Ordered as [Ordered Date], c.IsHidden,
 a.Priv_Notes as 'MainPrivateNotes', c.Priv_Notes as 'CrimPrivateNotes' , c.Pub_Notes as 'CrimPublicNotes' 
    FROM Crim c   
 INNER JOIN Appl a ON c.APNO = a.APNO  
 INNER JOIN Client cl on a.clno = cl.clno  
 INNER JOIN refAffiliate ra on cl.affiliateID = ra.AffiliateID  
 INNER JOIN dbo.TblCounties ON c.CNTY_NO = TblCounties.CNTY_NO  
 WHERE Apstatus in ('P', 'W', 'F')  
 AND  c.Clear = 'S' 

END
