


-- =============================================
-- Author:		Kiran Miryala
-- Create date: 7/7/2008
-- Description:	Pulls info from appl Table by SSN Value---- used for Onassignment
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_appinfoBySSN]
	@CLNO	int,
	@SSN    varchar(11)
AS
SELECT 
[First],
[Middle],
 [Last],
 --[maidenname],
 [Generation],
 [Alias1_Last],
 [Alias1_First],
 [Alias1_Middle], 
 [Alias1_Generation], 
 [Alias2_Last],
 [Alias2_First],
 [Alias2_Middle], 
 [Alias2_Generation],
[Alias3_Last],
 [Alias3_First],
 [Alias3_Middle], 
 [Alias3_Generation], 
 [Alias4_Last],
 [Alias4_First],
 [Alias4_Middle], 
 [Alias4_Generation],
  [Pos_Sought],
 [Addr_Street],
[City],
 [state],
[Zip],
Phone,
 replace(SSN,'-','') as SSN,
 [DOB],
 [DL_Number],
 [DL_State],
 --[btd],
  Attn
  --notes,

FROM Appl
WHERE CLNO = @CLNO AND replace(SSN,'-','') = replace(@SSN,'-','')


