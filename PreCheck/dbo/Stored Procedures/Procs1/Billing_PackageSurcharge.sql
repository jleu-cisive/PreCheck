
-- =============================================
-- Author:		cchaupin
-- Create date: 3/30/09
-- Description:	adds client specific package surcharges
-- =============================================
CREATE PROCEDURE [dbo].[Billing_PackageSurcharge] 
	@MODE int,@APNO int = null, @CLNO int = null
AS
BEGIN
	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--batch
if(@MODE = 1)
BEGIN
INSERT INTO dbo.InvDetail (APNO, [Type], Subkey, SubkeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
select a.apno,12,null,null,0,null,getdate(),cs.description,cs.amount 
from appl a(NOLOCK) 
inner join invdetail i(NOLOCK) on i.apno = a.apno
inner join clientpackages cp(NOLOCK) on cp.clno = isnull((select parentclno from clienthierarchybyservice(NOLOCK) where refhierarchyserviceid = 3 and clno = a.clno),a.clno)
inner join clientpackagesurcharge cs(NOLOCK) on cp.clientpackagesid = cs.clientpackagesid
where i.type = 0 
and i.subkey is not null and i.billed = 0
and cp.packageid = i.subkey
and a.billed = 0
END

--single client
IF(@MODE = 2)
BEGIN
INSERT INTO dbo.InvDetail (APNO, [Type], Subkey, SubkeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
select a.apno,12,null,null,0,null,getdate(),cs.description,cs.amount 
from appl a(NOLOCK) 
inner join invdetail i(NOLOCK) on i.apno = a.apno
inner join clientpackages cp(NOLOCK) on cp.clno = isnull((select parentclno from clienthierarchybyservice(NOLOCK) where refhierarchyserviceid = 3 and clno = a.clno),a.clno)
inner join clientpackagesurcharge cs(NOLOCK) on cp.clientpackagesid = cs.clientpackagesid
where i.type = 0 
and i.subkey is not null and i.billed = 0
and cp.packageid = i.subkey
and a.billed = 0
and a.clno = @CLNO
END

--single app
IF(@MODE = 3)
BEGIN
INSERT INTO dbo.InvDetail (APNO, [Type], Subkey, SubkeyChar, Billed, InvoiceNumber, CreateDate, Description, Amount)
select a.apno,12,null,null,0,null,getdate(),cs.description,cs.amount 
from appl a(NOLOCK) 
inner join invdetail i(NOLOCK) on i.apno = a.apno
inner join clientpackages cp(NOLOCK) on cp.clno = isnull((select parentclno from clienthierarchybyservice(NOLOCK) where refhierarchyserviceid = 3 and clno = a.clno),a.clno)
inner join clientpackagesurcharge cs(NOLOCK) on cp.clientpackagesid = cs.clientpackagesid
where i.type = 0 
and i.subkey is not null and i.billed = 0
and cp.packageid = i.subkey
and a.billed = 0
and a.apno = @APNO
END

SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END

