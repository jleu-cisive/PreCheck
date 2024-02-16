--[dbo].[Integration_OrderMgmt_GetClientConfigSettings] 2569


CREATE procedure [dbo].[Integration_OrderMgmt_GetClientConfigSettings]

(@CLNO int)



AS

Select Config.CLNO ,cast(IsNull(ConfigSettings,'') as varchar(max)) as ConfigSettings,cast(IsNull(xfc.XsltFileData,'') as varchar(max)) as XsltFileData,URL_CallBack_Acknowledge,URL_CallBack_Final

From dbo.ClientConfig_Integration Config 

left join dbo.XLATECLNO  Client on Config.CLNO = isnull(Client.CLNOin,0) 
--and IntegrationMethod = 'OrderMgmt'

left join dbo.XSLFileCache xfc on isnull(Client.CLNO_XSLT,0) = xfc.CLNO 

Where Client.CLNOin = (@CLNO) or Config.CLNO = 0
order by CLNO desc




