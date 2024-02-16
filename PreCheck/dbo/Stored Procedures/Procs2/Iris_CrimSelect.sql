











CREATE PROCEDURE [dbo].[Iris_CrimSelect]
(

@CrimID int
)
as

SELECT     CrimID, APNO, Clear, County, Ordered, Name, DOB, SSN, CaseNo, Date_Filed, Degree, Offense, Disposition, Sentence, Fine, Disp_Date, Pub_Notes, 
                      Priv_Notes, CRIM_SpecialInstr, vendorid, --status, 
                      txtalias, txtalias2, txtalias3, txtalias4, --uniqueid, 
                      txtlast, --Crimenteredtime, 
                      Last_Updated, CNTY_NO, 
                      IRIS_REC, --Report, batchnumber, crim_time, deliverymethod, countydefault, 
                      b_rule, --tobeworked, readytosend, NoteToVendor, test, 
                      InUse--, --parentCrimID, 
                      --IrisFlag, IrisOrdered, [Temporary], CreatedDate
FROM         dbo.Crim where CrimID=@CrimID







