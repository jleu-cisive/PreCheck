
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[FreeReportletter] @apno int AS


SELECT  dbo.Appl.APNO, dbo.Appl.CLNO, dbo.Appl.Attn, dbo.Appl.Alias, dbo.Appl.Alias2, dbo.Appl.Alias3, 
		UPPER(dbo.FreeReport.Name) AS tname, 
        dbo.Appl.Alias4, dbo.Appl.SSN, dbo.Appl.DOB, dbo.Appl.Sex, dbo.Appl.DL_State, dbo.Appl.DL_Number, dbo.Client.Name, dbo.Client.Addr1, 
        dbo.Client.Addr2, dbo.Client.Addr3, dbo.Client.Phone, dbo.Client.Fax, dbo.Client.Contact, dbo.FreeReport.Address1+','+isnull(dbo.FreeReport.Address2,'') as Address1, dbo.FreeReport.City, 
        dbo.FreeReport.State, dbo.FreeReport.Zip, dbo.Appl.Pos_Sought, dbo.Appl.Pub_Notes, dbo.Appl.Priv_Notes, dbo.Appl.ApDate, 
        dbo.Appl.CompDate, dbo.Appl.ApStatus
	--Added here -------------------------------------------------------------------------------------
	,null AS FirstPrintedDate
	--------------------------------------------------------------------------------------------------
FROM    dbo.Appl LEFT OUTER JOIN
        dbo.FreeReport ON dbo.Appl.APNO = dbo.FreeReport.APNO LEFT OUTER JOIN
        dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO
        -- Added by JC for handling FirstPrintDate---------------------------------------------------
	--inner join dbo.AdverseActionHistory h on h.AdverseActionID=dbo.FreeReport.FreeReportID
        --------------------------------------------------------------------------------------------
WHERE   (dbo.Appl.APNO = @apno)
-- Added by JC for handling FirstPrintDate --------------------------------------------
--  and h.Date =(select min(date)from AdverseActionHistory h 
--		right outer join FreeReport a on h.AdverseActionID=a.FreeReportID
--  		where  h.AdverseChangeTypeID=1
--  		  and a.apno=@apno)
---------------------------------------------------------------------------------------
