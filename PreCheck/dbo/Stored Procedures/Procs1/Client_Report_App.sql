CREATE PROCEDURE Client_Report_App  @apno int AS
SELECT     dbo.Appl.APNO, dbo.Appl.CLNO,  dbo.Appl.Attn, dbo.Appl.Alias, dbo.Appl.Alias2, dbo.Appl.Alias3, 
                    upper( appl.Last + ' , ' + appl.first + ' ' + isnull(appl.middle,'')) as tname ,  dbo.Appl.Alias4, dbo.Appl.SSN, dbo.Appl.DOB, dbo.Appl.Sex, dbo.Appl.DL_State, dbo.Appl.DL_Number, dbo.Client.Name, dbo.Client.Addr1, 
                      dbo.Client.Addr2, dbo.Client.Addr3, dbo.Client.Phone, dbo.Client.Fax, dbo.Client.Contact, dbo.Appl.Addr_Num, dbo.Appl.Addr_Dir, dbo.Appl.Addr_Street, 
                      dbo.Appl.Addr_StType, dbo.Appl.Addr_Apt, dbo.Appl.City, dbo.Appl.State, dbo.Appl.Zip, dbo.Appl.Pos_Sought, dbo.Appl.Pub_Notes, dbo.Appl.Priv_Notes, 
                      dbo.Appl.ApDate, dbo.Appl.CompDate, dbo.Appl.ApStatus
FROM         dbo.Appl LEFT OUTER JOIN
                      dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO
where dbo.appl.apno = @apno
