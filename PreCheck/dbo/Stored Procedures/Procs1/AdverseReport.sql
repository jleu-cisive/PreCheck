

--Modified by JC to add FirstPrintDate to handle reprint on 02-10-06  
CREATE PROCEDURE [dbo].[AdverseReport] @apno int AS


SELECT  dbo.Appl.APNO, dbo.Appl.CLNO, dbo.Appl.Attn, dbo.Appl.Alias, dbo.Appl.Alias2, dbo.Appl.Alias3, UPPER(dbo.AdverseAction.Name) AS tname, 
        dbo.Appl.Alias4, dbo.Appl.SSN, dbo.Appl.DOB, dbo.Appl.Sex, dbo.Appl.DL_State, dbo.Appl.DL_Number, dbo.Client.Name, dbo.Client.Addr1, 
        dbo.Client.Addr2, dbo.Client.Addr3, dbo.Client.Phone, dbo.Client.Fax, dbo.Client.Contact, dbo.AdverseAction.Address1+','+isnull(dbo.AdverseAction.Address2,'') as Address1, dbo.AdverseAction.City, 
        dbo.AdverseAction.State, dbo.AdverseAction.Zip, dbo.Appl.Pos_Sought, dbo.Appl.Pub_Notes, dbo.Appl.Priv_Notes, dbo.Appl.ApDate, 
        dbo.Appl.CompDate, dbo.Appl.ApStatus
	--Added here -------------------------------------------------------------------------------------
	,(SELECT CASE WHEN COUNT(1) = 0 THEN NULL ELSE MIN(DATE) END
    	    FROM APPL A with (nolock) LEFT OUTER JOIN ADVERSEACTION AA with (nolock) ON A.APNO=AA.APNO 
			LEFT OUTER JOIN ADVERSEACTIONHISTORY AAH with (nolock) ON AA.ADVERSEACTIONID=AAH.ADVERSEACTIONID
   	   WHERE A.APNO=@APNO AND AAH.AdverseChangeTypeID=1 AND AAH.STATUSID = 4 ) AS FirstPrintedDate
	--------------------------------------------------------------------------------------------------
FROM    dbo.Appl with (nolock) LEFT OUTER JOIN
        dbo.AdverseAction with (nolock) ON dbo.Appl.APNO = dbo.AdverseAction.APNO LEFT OUTER JOIN
        dbo.Client with (nolock) ON dbo.Appl.CLNO = dbo.Client.CLNO
        -- Added by JC for handling FirstPrintDate---------------------------------------------------
	inner join dbo.AdverseActionHistory h with (nolock) on h.AdverseActionID=dbo.AdverseAction.AdverseActionID
        --------------------------------------------------------------------------------------------
WHERE   (dbo.Appl.APNO = @apno)
-- Added by JC for handling FirstPrintDate --------------------------------------------
  and h.Date =(select min(date)from AdverseActionHistory h with (nolock) 
		right outer join AdverseAction a with (nolock) on h.AdverseActionID=a.AdverseActionID
  		where  h.AdverseChangeTypeID=1
  		  and a.apno=@apno)
---------------------------------------------------------------------------------------




