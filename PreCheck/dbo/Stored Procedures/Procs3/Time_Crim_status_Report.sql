
CREATE PROCEDURE [dbo].[Time_Crim_status_Report] AS
-- Bruce Revised Criminal Report 12/11/2002


SELECT     c.APNO, c.Clear,  c.Ordered, a.UserID, a.ApDate, a.[Last], a.[First], a.Middle, a.PC_Time_Stamp, c.Crimenteredtime, 
                      CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(c.Ordered, GETDATE())) AS Elapsed,  dbo.Counties.A_County + ', ' + dbo.Counties.State as county,
                      convert(numeric(7,2),dbo.ElapsedBusinessDays(convert(varchar,a.apdate,106),GetDate())) as ElapsedReceived,
                     convert(numeric(7,2),dbo.ElapsedBusinessDays(convert(varchar,c.crimenteredtime,106),GetDate())) as ApplicationReceived
FROM         dbo.Crim c with (nolock) INNER JOIN
                      dbo.Appl a with (nolock) ON c.APNO = a.APNO INNER JOIN
                      dbo.Counties with (nolock) ON c.CNTY_NO = dbo.Counties.CNTY_NO
WHERE     (c.Clear = 'O') AND (a.ApStatus IN ('P', 'W')) AND
                          ((SELECT     COUNT(*)
                              FROM         Crim with (nolock) 
                              WHERE     (Crim.Apno = A.Apno) AND ((Crim.Clear IS NULL) OR
                                                    (Crim.Clear = 'O'))) > 0)
ORDER BY a.ApDate







