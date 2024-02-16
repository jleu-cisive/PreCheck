




/****************************************************************************************
-- Created by Amy Liu on 05/22/2021
-- This view is used in Client Manager windows forms application for granting permission
*****************************************************************************************/

CREATE VIEW [dbo].[vwPrivilegeClientConfiguration]
AS

select c.clno, isnull(cc.value, 'false') as [ShowSecurityPrivileges],isnull(ecc.KeyValue,'false') as  [PrivilegeEnabled]
from dbo.client c (nolock)
left join dbo.ClientConfiguration cc (nolock) on c.clno = cc.CLNO and cc.ConfigurationKey='ShowSecurityPrivileges'
left join Enterprise.Config.CLientCOnfiguration  ecc on c.clno = ecc.ClientId  and ecc.ConfigurationId = 
			(select ec.ConfigurationId  from  Enterprise.config.Configuration ec (nolock) where ec.KeyName = 'Privilege.Enable')
--where c.CLNO=13126

