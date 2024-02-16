
-- =============================================
-- Date: July 2, 2001
-- Author: Pat Coffer
--
-- Selects data needed to produce a civil
-- worksheet for all counties.
-- =============================================
CREATE PROCEDURE RetCivilForWks
	@CNTY_NO int
AS
SET NOCOUNT ON

--Y.State is accessed by index number, not name, so....
--      if change the position of State, go change the code 
SELECT C.CivilID, Y.A_County, Y.State, Y.Country,.Y.CNTY_NO,
       A.Apno, A.[Last], A.[First], A.Middle, A.SSN, A.DOB,
       A.Addr_Num, A.Addr_Dir, A.Addr_Street, A.Addr_StType,
       A.Addr_Apt, A.City, A.State, A.Zip, 
       A.Alias1_First,A.Alias1_Middle,A.Alias1_Last,A.Alias1_Generation,
       A.Alias2_First,A.Alias2_Middle,A.Alias2_Last,A.Alias2_Generation,
       A.Alias3_First,A.Alias3_Middle,A.Alias3_Last,A.Alias3_Generation,
       A.Alias4_First,A.Alias4_Middle,A.Alias4_Last,A.Alias4_Generation,
       A.Alias, A.Alias2,A.Alias3, A.Alias4,
       Y.Civ_Source, Y.Civ_Phone, Y.Civ_Fax, Y.Civ_Addr,
       Y.Civ_Comment
FROM Civil C
JOIN Appl A ON C.Apno = A.Apno
JOIN Counties Y on C.CNTY_NO = Y.CNTY_NO
WHERE (C.[Clear] IS NULL)
  AND (C.CNTY_NO = @CNTY_NO)
ORDER BY Y.Country,Y.State,Y.A_County
