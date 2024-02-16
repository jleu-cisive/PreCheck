CREATE Procedure [dbo].[ClientCertifiedInfo]
(@apno int)
as
SELECT  isnull(apno, 0) as APNO, ClientCertReceived, isnull(ClientCertBy, ''), ClientCertUpdated from [dbo].[ClientCertification] WHERE apno = @apno 