/*
Created By: Dongmei
Modified By: Deepak Vodethela
Requested By: Matthew Celoria 
Description: Tex DPS Name Audit Report be updated to include case number(s) or cause numbers in the results.
Execution: EXEC [dbo].[TexDPSNameAuditReport] 'barrows','ruth','dawn','11/07/1960'
*/

CREATE PROCEDURE [dbo].[TexDPSNameAuditReport] 
 @First VARCHAR(50),
 @Last VARCHAR(50),
 @Middle VARCHAR(50),
 @DOB DATE
AS

Declare @FullName VARCHAR(250)

SET @FullName = @Last + ',' + @First + ' ' + @Middle
SELECT N.NAM_IDN as [Name ID], N.PER_IDN as [Person ID], N.NAM_TXT as Name, LNA_TXT as [Last Name], FNA_TXT as [First Name], B.DOB_DTE as DOB , Court.CAU_NBR as CauseNo
from TexDPS.DBO.[name] N 
       inner join TexDPS.DBO.brthdate B ON N.PER_IDN = B.PER_IDN 
       inner join TexDPS.DBO.Person P ON B.PER_IDN = P.PER_IDN
       inner join TexDPS.DBO.TRN ON P.IND_IDN = TRN.IND_IDN
       inner join TexDPS.DBO.TRS ON TRN.TRN_IDN = TRS.TRN_IDN
       inner join TexDPS.DBO.CRT_STAT Court ON TRS.TRS_IDN = Court.TRS_IDN
       left join  TexDPS.DBO.OFF_CODE OFC ON Court.CON_COD = OFC.OFF_COD
       left join  TexDPS.DBO.FPO_COD FPOC ON Court.FPO_COD = FPOC.FPO_COD_VAL_COD
       left join  TexDPS.DBO.LDA_COD LDAC ON Court.LDC_COD = LDAC.LDA_COD_VAL_COD
       left join  TexDPS.DBO.CDN_COD CDNC ON Court.CDN_COD = CDNC.CDN_VAL_COD
       left join  TexDPS.DBO.AGENCY  AG   ON Court.AGY_TXT = AG.ORI_TXT
       WHERE cast(cast(DOB_DTE as Datetime) as varchar(12)) = @DOB
AND  (NAM_TXT = @FullName
                                      
       OR (@First = LNA_TXT and rtrim(@Last + ' ' + replace(isnull(@Middle,''),'.','')) = (Case when charindex(' ',FNA_TXT)>0 then rtrim(substring(FNA_TXT,1,charindex(' ',FNA_TXT)-1)) + ' ' + ltrim(substring(FNA_TXT,charindex(' ',FNA_TXT)+1,1)) else FNA_TXT end))
       OR (@Last = LNA_TXT and rtrim(@First + ' ' + replace(isnull(@Middle,''),'.','')) = (Case when charindex(' ',FNA_TXT)>0 then rtrim(substring(FNA_TXT,1,charindex(' ',FNA_TXT)-1)) + ' ' + ltrim(substring(FNA_TXT,charindex(' ',FNA_TXT)+1,1)) else FNA_TXT end))
       OR (@First = LNA_TXT and rtrim(@Last + ' ' + replace(isnull(@Middle,''),'','.')) = (Case when charindex(' ',FNA_TXT)>0 then rtrim(substring(FNA_TXT,1,charindex(' ',FNA_TXT)-1)) + ' ' + ltrim(substring(FNA_TXT,charindex(' ',FNA_TXT)+1,1)) else FNA_TXT end))
       OR (@Last = LNA_TXT and rtrim(@First + ' ' + replace(isnull(@Middle,''),'','.')) = (Case when charindex(' ',FNA_TXT)>0 then rtrim(substring(FNA_TXT,1,charindex(' ',FNA_TXT)-1)) + ' ' + ltrim(substring(FNA_TXT,charindex(' ',FNA_TXT)+1,1)) else FNA_TXT end))
       OR (@Last = LNA_TXT and @First = (Case when charindex(' ',FNA_TXT)>0 then rtrim(substring(FNA_TXT,1,charindex(' ',FNA_TXT)-1)) else FNA_TXT end))
       OR (@First = LNA_TXT and @Last = (Case when charindex(' ',FNA_TXT)>0 then rtrim(substring(FNA_TXT,1,charindex(' ',FNA_TXT)-1)) else FNA_TXT end))
       OR (Case when charindex('-',@Last)>0 then rtrim(substring(@Last,1,charindex('-',@Last)-1)) + ',' + @First   End) = NAM_TXT
       OR (Case when charindex('-',@Last)>0 then @First + ',' + rtrim(substring(@Last,1,charindex('-',@Last)-1))   End) = NAM_TXT
       OR (Case when charindex('-',@Last)>0 then ltrim(substring(@Last,charindex('-',@Last)+1,len(@Last))) + ',' + @First  End) = NAM_TXT
       OR (Case when charindex('-',@Last)>0 then @First + ',' + ltrim(substring(@Last,charindex('-',@Last)+1,len(@Last)))  End) = NAM_TXT )
