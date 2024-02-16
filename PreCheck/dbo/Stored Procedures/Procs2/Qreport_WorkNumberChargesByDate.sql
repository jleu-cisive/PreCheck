/**  
Old Script :  
SELECT app.APNO AS [App #], cl.CLNO AS [Client #], cl.[NAME] AS [Client Name], app.APDATE AS [Application Date],DESCRIPTION AS [Description],  
AMOUNT AS [Amount]    FROM DBO.[INVDETAIL] inv WITH (NOLOCK)    INNER JOIN DBO.[APPL] app WITH (NOLOCK)    ON inv.APNO = app.APNO      
INNER JOIN DBO.[CLIENT] cl WITH (NOLOCK)    ON app.[CLNO] = cl.[CLNO]     WHERE [TYPE] = 1    AND  inv.CreateDate >= --'01/1/2007'--   
and inv.CreateDate < DATEADD(d,1,--'01/27/2007'--)     AND [DESCRIPTION] LIKE '%WORK%NUMBER%'    order by APDATE DESC    
**/  
/**=======================================================================================  
Created Date : 02/27/2023  
Created By  : Yashan Sharma   
Description  : As per requirement of HDT #83752 a new column add in output   
Exec : dbo.Qreport_WorkNumberChargesByDate '02/01/2023','02/17/2023'  

ModifiedBy		ModifiedDate	TicketNo	Description  
Shashank Bhoi	04/19/2023		90801		#90801 Work Number Charges by Date Qreport-- Required additional columns Investigator1,Is Hidden Report,Is on Report,Public Notes,Private Notes
											EXEC dbo.Qreport_WorkNumberChargesByDate '02/01/2023','02/17/2023' 
=========================================================================================**/ 
CREATE Procedure dbo.Qreport_WorkNumberChargesByDate  
(  
@StartDate DateTime  
,@EndDate DateTime  
)  
AS   
BEGIN  
SELECT	app.APNO AS [App #]  
		,cl.CLNO AS [Client #]  
		,cl.[NAME] AS [Client Name]  
		,app.APDATE AS [Application Date]  
		,Inv.CreateDate AS [BillDate]  -- New Column Added according to HDT #83752  
		,INV.DESCRIPTION AS [Description]  
		,AMOUNT AS [Amount],
		e.Investigator AS [Investigator1],												-- Added column for #90801 
		CASE WHEN E.IsHidden = 0 THEN 'False' ELSE 'True' END AS [Is Hidden Report],	-- Added column for #90801 
		CASE WHEN e.IsOnReport = 0 THEN 'False' ELSE 'True' END AS [Is On Report],		-- Added column for #90801
		E.Pub_Notes [Public Notes],														-- Added column for #90801
		E.PRIV_NOTES AS [Private Notes]													-- Added column for #90801
FROM	DBO.[INVDETAIL]			AS inv WITH (NOLOCK)      
		INNER JOIN DBO.[APPL]	AS app WITH (NOLOCK) ON inv.APNO = app.APNO    
		INNER JOIN DBO.[CLIENT] AS cl WITH (NOLOCK)  ON app.[CLNO] = cl.[CLNO]
		INNER JOIN dbo.Empl		AS E with(NOLOCK) ON inv.APNO = E.APNO					-- Added table for #90801
		INNER JOIN dbo.SectStat AS S with(NOLOCK) ON E.SectStat = S.CODE				-- Added table for #90801
WHERE	inv.[TYPE] = 1      
		AND  inv.CreateDate >= @StartDate and inv.CreateDate < DATEADD(d,1,@EndDate)          
		AND Inv.[DESCRIPTION] LIKE '%WORK%NUMBER%'     
order by app.APDATE DESC  
END  
