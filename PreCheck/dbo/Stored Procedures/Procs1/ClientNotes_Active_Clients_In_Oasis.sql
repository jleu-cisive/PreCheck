-- =============================================  
-- Author:  <Author - Vijay>  
-- Create date: <Nov 01 2022>  
-- Description: <Description,,>  
-- =============================================  
/*  
Exec ClientNotes_Active_Clients_In_Oasis 0,4,'HCA Healthcare'  
 */
-- =============================================  
-- Modify By:  YSharma  
-- Create date: 07/11/2022  
-- Description: As HDT #56320 required Multipule Affiliate IDs in Qreport So I am making changes in the same. 
-- Execution:   
/*  
Exec ClientNotes_Active_Clients_In_Oasis 0,'4:257','HCA Healthcare'  
Exec ClientNotes_Active_Clients_In_Oasis 0,0,'HCA Healthcare'
*/  
-- ============================================= 
CREATE Proc ClientNotes_Active_Clients_In_Oasis  
 @CLNO int = 0,  
 @AffiliateID  Varchar(Max)='' ,  -- Added on the behalf for HDT #56320   ;  
 @AccountSystemGroup varchar(Max) = ''  
 As  
Begin  
SET NOCOUNT ON; 

  IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #56320  
	 BEGIN      
	  SET @AffiliateID = NULL      
	 END 
SELECT c.CLNO as ClientNumber,  c.Name as ClientName, cn.NoteType, cn.NoteText, cn.NoteBy, cn.NoteDate,cn.NoteID,ra.Affiliate,c.[Accounting System Grouping]  
FROM dbo.Client c with (nolock)  
INNER join dbo.ClientNotes cn with (nolock)  on c.CLNO = cn.CLNO  
INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID  
where c.IsInactive = 0  and  
c.CLNO= IIF(@CLNO =0,c.CLNO,@CLNO)   
AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320  
AND c.[Accounting System Grouping] = IIF(@AccountSystemGroup ='',c.[Accounting System Grouping],@AccountSystemGroup)  
order by c.CLNO  
End  
  
  
