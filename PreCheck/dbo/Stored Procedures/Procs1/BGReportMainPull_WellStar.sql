
-- =================================================================================
-- Author:		Prasanna
-- Create date: 07/19/2021
-- Description:	Modified existing procedure BGReportMainPull_MedSpot
-- Execution: EXEC [BGReportMainPull_WellStar] 3115
-- =================================================================================

CREATE PROCEDURE [dbo].[BGReportMainPull_WellStar]
	@CLNO int, @StartDate datetime,@EndDate datetime,@UseHevnDb bit = 1
AS
BEGIN
    SET @StartDate = '10/01/2019'
	Set @EndDate = '07/21/2021';

	If(@UseHevnDb = 1)
	 BEGIN		

		SELECT FolderID, clno, ReportID, lastname, firstname,employeeNumber, ClientFacilityGroup		
		FROM(
		
			select  idtable.apno as FolderID,idtable.clno, br.backgroundreportid AS ReportID,lastname, firstname,idtable.employeeNumber, isnull(ClientFacilityGroup,'NonGrouped') as ClientFacilityGroup --schapyala returning emptystring for facilitygroup as this is not used for BG purposes - 05/04/2015
			from (
				SELECT DISTINCT  a.apno,cast(a.clno as int) as clno ,a.Last as [LastName], a.First as [FirstName],'000000000' employeeNumber, 'NonGrouped' as ClientFacilityGroup
				FROM   PRECHECK.DBO.appl a  WITH (NOLOCK) 
					INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno  
					INNER JOIN dbo.Client c(NOLOCK) ON A.CLNO = c.CLNO
				WHERE 
				   	    a.apstatus = 'F' 				
						AND a.APNO IN(5646705,5510287,5690304,5731049,5293980,5718804,5721494,5662454,5727204,5746008,4792577,5750557,5735775,5666509,5651201,5687939,5537552,5520272,4705230,5643165,
                                      5678361,5757846,5767057,5410030,5578941,5799302,5666871,5633364,5678410,5694626,5718951,5360567,5739644,5781834,5627287,5750094,4472247,4613456,5486672,5721494,
                                      4613456,4910025,5041577,5075322,5295338,5274780,5302588,5351453,5375642,5377140,5374237,5373325,5369769,5391921,5368145,5365860,5615101,5691580,5781891,5725457, 
                                      5368793,5377140,5375642,5367910,5373325,5373029, 5369769,5368145,5368797,5365860,5368793,5361263,5375933,5382961,5408693,5435342,5672755,5670772,1390458,5340252,
                                      5432129,5448449,5434275,5378118,5448449,5454850,5473055,5133791,5133255,5457501,5118211,5487003,5486674,5487059,5487070,5368432,5133998,5132233,5486765,
									  5454850,5452601,5473055,5553821,5711896,5495146,5690725,5485992,5133926,5500260,5487904,5444725,5486825,5449961,5508902,5475892,5499475,5423140,5525603,5537458,
									  5546535,5558290,5548667,5553853,5560390,5562145,5552049,5565111,5552608,5595336,5594431,5589159,5611973,5634051,5651218,5652073,5574146,5639341,5656782,5667933,
									  5687036,5704225,5696857,5692229,5679722,5693758,5687030,5679432,5691770,5711598,5685164,5674569,5707063,5691962,5704092,5704582,5693060,5717816,5627067,5627067,
                                      5712572,5674901,5710400,5727302,5612366,5714275,5723545,5733225,5707036,5721282,5665114,5506156,5623427,5633184,5627059,5623209,5591936,5746008,5721746,5733401,5637917,
                                      5686356,5623249,5629870,5739940,5689931,5745854,5752202,5620980,5626140,5753386,5750027,5759961,5763694,5766826,5750027,5620974,5748660,5117957,5799249,5705350,5653789
                        )
				) as idTable 
				INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on br.apno = idTable.apno
				and br.CreateDate = (Select MAX(createdate) from BackgroundReports.dbo.BackgroundReport WITH (NOLOCK) where apno = idTable.apno)

			) AS Y
	 End

END