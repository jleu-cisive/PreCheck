-- =============================================
-- Author:		<Author - Vijay>
-- Create date: <Nov 01 2022>
-- Description:	<Description,,>
-- =============================================
/*
Exec ClientNotes_Active_Clients_In_Oasis 0,0,''

*/
Create Proc [PRECHECK\VAmishetti].ClientNotes_Active_Clients_In_Oasis
 @CLNO int = 0,
 @Affiliate  int = 0,
 @AccountSystemGroup varchar(Max) = ''
 As
Begin
SET NOCOUNT ON;
Select top 100 c.CLNO as ClientNumber,  c.Name as ClientName, cn.NoteType, cn.NoteText, cn.NoteBy, cn.NoteDate,cn.NoteID,ra.Affiliate,c.[Accounting System Grouping]
from Client c with (nolock)
inner join ClientNotes cn with (nolock)  on c.CLNO = cn.CLNO
INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID
where c.IsInactive = 0  and
c.CLNO= IIF(@CLNO =0,c.CLNO,@CLNO) And
c.AffiliateID = IIF(@Affiliate =0,c.AffiliateID,@Affiliate) And
c.[Accounting System Grouping] = IIF(@AccountSystemGroup ='',c.[Accounting System Grouping],@AccountSystemGroup)
order by c.CLNO
End

