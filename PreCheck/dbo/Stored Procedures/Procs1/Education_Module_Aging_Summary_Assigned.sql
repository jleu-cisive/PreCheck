
/*
Procedure Name : Education_Module_Aging_Summary_Assigned
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Execution : EXEC [Education_Module_Aging_Summary_Assigned]
*/

CREATE PROCEDURE [dbo].[Education_Module_Aging_Summary_Assigned]
AS

    DROP TABLE IF EXISTS #WeekDayRecords
    DROP TABLE IF EXISTS #WeekEndRecords
    DROP TABLE IF EXISTS #InvestigatorTotals
    DROP TABLE IF EXISTS #InvestigatorAggrigatesForNulls
    DROP TABLE IF EXISTS #AgingRecordsByInvestigator

-- Get Weekday Records

SELECT	E.Investigator,
		E.CreatedDate,
		DATENAME(dw, E.CreatedDate) AS NameOfTheDay,
		dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE()) AS NoOfHours,
		CASE --WHEN (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '23.99' THEN 0
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '0.00' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '47.99') THEN 1
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '47.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '71.99') THEN 2
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '71.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '95.99') THEN 3
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '95.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '119.99') THEN 4
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '119.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '143.99') THEN 5
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '143.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '167.99') THEN 6
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '167.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '191.99') THEN 7
		ELSE 8
		END DaysPassed,
		COUNT(*) AS RecordCountByDay,
		SUM(COUNT(*)) OVER (PARTITION BY E.Investigator) AS RecordCountByInvestigator
		INTO #WeekDayRecords
FROM dbo.Educat AS E(NOLOCK)
INNER JOIN dbo.Users AS U(NOLOCK) ON E.Investigator = U.UserID AND U.Educat = 1 AND [Disabled] = 0
WHERE E.SectStat in ('0','9') 
  AND E.Investigator is not null
  AND E.Investigator != ''
  AND E.IsOnReport = 1
  AND DATENAME(dw, E.CreatedDate) NOT IN ('Saturday', 'Sunday') 
GROUP BY E.Investigator,
		 E.CreatedDate,
		 dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE()),
		 CASE --WHEN (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '23.99' THEN 0
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '0.00' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '47.99') THEN 1
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '47.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '71.99') THEN 2
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '71.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '95.99') THEN 3
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '95.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '119.99') THEN 4
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '119.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '143.99') THEN 5
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '143.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '167.99') THEN 6
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '167.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '191.99') THEN 7
		 ELSE 8
		 END
ORDER BY E.Investigator

--SELECT * FROM #WeekDayRecords ORDER BY Investigator, CreatedDate DESC
--PRINT 'WEEKDAY RECORDS'

-- Get Weekend records
-- These requests are coming in via XML or WEB over the weekend, so they are technically created but during offline hours.

SELECT  E.Investigator,
		E.CreatedDate,
		DATENAME(dw, E.CreatedDate) AS NameOfTheDay,
		dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE()) AS NoOfHours,
		CASE --WHEN (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '23.99' THEN 0
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '0.00' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '47.99') THEN 1
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '47.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '71.99') THEN 2
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '71.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '95.99') THEN 3
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '95.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '119.99') THEN 4
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '119.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '143.99') THEN 5
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '143.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '167.99') THEN 6
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '167.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '191.99') THEN 7
		ELSE 8
		END DaysPassed,
		COUNT(*) AS RecordCountByDay,
		SUM(COUNT(*)) OVER (PARTITION BY E.Investigator) AS RecordCountByInvestigator
		INTO #WeekEndRecords
FROM dbo.Educat AS E(NOLOCK)
INNER JOIN dbo.Users AS U(NOLOCK) ON E.Investigator = U.UserID AND U.Educat = 1 AND [Disabled] = 0
WHERE SectStat in ('0','9') 
	AND E.Investigator IS NOT NULL
	AND E.Investigator != ''
	AND E.IsOnReport = 1
	AND DATENAME(dw, E.CreatedDate) IN ('Saturday', 'Sunday')
GROUP BY E.Investigator,
		 E.CreatedDate,
		 DATENAME(dw, E.CreatedDate),
		 dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE()),
		CASE --WHEN (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '23.99' THEN 0
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '0.00' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '47.99') THEN 1
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '47.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '71.99') THEN 2
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '71.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '95.99') THEN 3
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '95.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '119.99') THEN 4
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '119.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '143.99') THEN 5
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '143.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '167.99') THEN 6
			 WHEN ((dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) > '167.99' AND (dbo.GetHoursExcludingWeekEnd(E.CreatedDate, GETDATE())) <= '191.99') THEN 7
		ELSE 8
		 END

--SELECT * FROM #WeekEndRecords ORDER BY Investigator, CreatedDate DESC
--PRINT 'WEEKEND RECORDS'

-- Add the WeekEnd Records to the main table 
-- Append 'Days' to DaysPassed Column (Aged Records)
-- Add (WeekEnd Record Count + WeekDay Record Count ) as RecordCount for each Investigator
--DROP TABLE #InvestigatorTotals
SELECT  a.Investigator,
		a.CreatedDate,
		a.NameOfTheDay,
		a.NoOfHours,
		a.DaysPassed,
		a.RecordCountByDay,
		CASE WHEN a.DaysPassed >= 8 THEN  CAST(a.DaysPassed AS varchar(8)) + '+ days' 
			ELSE CAST(a.DaysPassed AS varchar(8)) + ' days' 
		END AS NoOfDays,
		a.RecordCountByInvestigator AS OriginalRecordCountByInvestigator,
		CASE WHEN (b.RecordCountByInvestigator > 0 OR b.RecordCountByInvestigator IS NOT NULL) THEN (a.RecordCountByInvestigator + b.RecordCountByInvestigator)
			ELSE a.RecordCountByInvestigator
		END AS NewRecordCountByInvestigator
		INTO #InvestigatorTotals
FROM #WeekDayRecords AS a
LEFT OUTER JOIN (SELECT Investigator,
			 			MAX(RecordCountByInvestigator) AS RecordCountByInvestigator
				 FROM #WeekEndRecords
				 GROUP BY Investigator) as b ON b.Investigator = a.Investigator
GROUP BY a.Investigator,
		 a.CreatedDate,
		 a.NameOfTheDay,
		 a.NoOfHours,
		 a.DaysPassed,
		 a.RecordCountByDay,
		 CASE WHEN a.DaysPassed >= 8 THEN  CAST(a.DaysPassed AS varchar(8)) + '+ days' 
			ELSE CAST(a.DaysPassed AS varchar(8)) + ' days' 
		 END,
		 a.RecordCountByInvestigator,
		 CASE WHEN (b.RecordCountByInvestigator > 0 OR b.RecordCountByInvestigator IS NOT NULL) THEN (a.RecordCountByInvestigator + b.RecordCountByInvestigator)
			ELSE a.RecordCountByInvestigator 
		 END;

--SELECT * FROM #InvestigatorTotals ORDER BY Investigator, CreatedDate DESC
--PRINT '#InvestigatorTotals'

-- Insert WeekEnd Records for Matching Investigator's into the Main table 
-- After inserting 'Saturday' and 'Sunday' records, Update these records to Monday at 8:00:000 am
-- Suffix the DaysPassed to 'Days' for WeekEnd Records
MERGE #InvestigatorTotals AS Target
USING (SELECT Investigator, CreatedDate, NameOfTheDay, NoOfHours, DaysPassed, RecordCountByDay, RecordCountByInvestigator FROM #WeekEndRecords) AS Source
ON (Target.Investigator = Source.Investigator AND Target.NameOfTheDay = Source.NameOfTheDay)
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Investigator, CreatedDate, NameOfTheDay, NoOfHours, DaysPassed, RecordCountByDay, NoOfDays) --, OriginalRecordCountByInvestigator, NewRecordCountByInvestigator
	VALUES (Source.Investigator, 
			(SELECT MAX(CASE WHEN DATENAME(DW, CreatedDate) = 'Saturday' THEN DATEADD(DAY, DATEDIFF(DAY, -2, CreatedDate), '08:00:00') -- if saturday add 2 days
							 WHEN DATENAME(DW, CreatedDate) = 'Sunday' THEN DATEADD(DAY, DATEDIFF(DAY, -1, CreatedDate), '08:00:00') -- if sunday add 1 day
						END)
			 FROM #WeekEndRecords),
			'Monday',
			Source.NoOfHours,
			Source.DaysPassed,
			Source.RecordCountByDay, 
			(SELECT MAX(CASE WHEN DaysPassed >= 8 THEN  CAST(DaysPassed AS varchar(8)) + '+ days' 
							ELSE CAST(DaysPassed AS varchar(8)) + ' days' 
						END)
			 FROM #WeekEndRecords
			 WHERE Investigator = Source.Investigator));

--PRINT '(1)Inserting ''Saturday'' and ''Sunday'' records to main set, (2)Update these records to Monday at 8:00:000 am'

-- Update After hours records from Friday to Monday at 8:00:000 am
UPDATE #WeekDayRecords
	SET CreatedDate = DATEADD(DAY, DATEDIFF(DAY, -3, CreatedDate), '08:00:00'),
		NameOfTheDay = 'Monday'--,
		--NoOfHours = 23,
		--DaysPassed = 1
WHERE DATENAME(dw, createddate) IN ('Friday') 
  AND DATEPART(HOUR,CreatedDate) > 17;

--PRINT 'Update After hours records from Friday to Monday at 8:00:000 am'

-- If there are any WeekEnd records for the Investigator, then Get the Maximum existing RecordCount
-- The reason is, to fill the NULL values added from WeekEnd to the main table
SELECT  I.Investigator,
		OriginalRecordCountByInvestigator = MAX(COALESCE(I.OriginalRecordCountByInvestigator,0)),
		NewRecordCountByInvestigator = MAX(COALESCE(NewRecordCountByInvestigator,0))
		INTO #InvestigatorAggrigatesForNulls
FROM #InvestigatorTotals AS I
WHERE EXISTS (SELECT Investigator, OriginalRecordCountByInvestigator, NewRecordCountByInvestigator
			  FROM #InvestigatorTotals AS S
			  WHERE S.Investigator = I.Investigator
			    AND CONVERT(VARCHAR(8),S.CreatedDate,108) = '08:00:00'
			 )
GROUP BY Investigator

--SELECT * FROM #InvestigatorAggrigatesForNulls
--PRINT 'If there are any WeekEnd records for the Investigator, then Get the Maximum existing RecordCount'

-- Update the NULL RecordCount with the existing RecordCount
UPDATE  #InvestigatorTotals
	SET OriginalRecordCountByInvestigator = S.OriginalRecordCountByInvestigator,
		NewRecordCountByInvestigator = S.NewRecordCountByInvestigator
FROM #InvestigatorTotals AS I
INNER JOIN (SELECT  Investigator, 
					OriginalRecordCountByInvestigator, 
					NewRecordCountByInvestigator
			FROM #InvestigatorAggrigatesForNulls
			 ) AS S ON S.Investigator = I.Investigator
WHERE I.OriginalRecordCountByInvestigator IS NULL

---- Check if WeekEnd Records with Totals are added to main table
--SELECT * FROM #InvestigatorTotals 
--WHERE OriginalRecordCountByInvestigator != NewRecordCountByInvestigator
--ORDER BY Investigator, CreatedDate DESC
--PRINT 'Update the NULL RecordCount with the existing RecordCount'

-- Get the Final Aged Records for Invetigator
SELECT  Investigator,
		NoOfDays,
		SUM(RecordCountByDay) AS TotalRecordCountsByDay,
		NewRecordCountByInvestigator AS RecordCountByInvestigator
		INTO #AgingRecordsByInvestigator
FROM #InvestigatorTotals
GROUP BY Investigator,
		 NoOfDays,
		 NewRecordCountByInvestigator
ORDER BY Investigator

--SELECT * FROM #AgingRecordsByInvestigator ORDER BY Investigator
--PRINT 'Generate Final Aging Dataset'

-- Apply Rows to Columns for Each Invetigator
SELECT	Investigator,
		MAX(CASE WHEN NoOfDays = '1 days' THEN TotalRecordCountsByDay ELSE 0 END) [Day 1],
		MAX(CASE WHEN NoOfDays = '2 days' THEN TotalRecordCountsByDay ELSE 0 END) [Day 2],
		MAX(CASE WHEN NoOfDays = '3 days' THEN TotalRecordCountsByDay ELSE 0 END) [Day 3],
		MAX(CASE WHEN NoOfDays = '4 days' THEN TotalRecordCountsByDay ELSE 0 END) [Day 4],
		MAX(CASE WHEN NoOfDays = '5 days' THEN TotalRecordCountsByDay ELSE 0 END) [Day 5],
		MAX(CASE WHEN NoOfDays = '6 days' THEN TotalRecordCountsByDay ELSE 0 END) [Day 6],
		MAX(CASE WHEN NoOfDays = '7 days' THEN TotalRecordCountsByDay ELSE 0 END) [Day 7],
		MAX(CASE WHEN NoOfDays = '8+ days' THEN TotalRecordCountsByDay ELSE 0 END) [Day 8+],
		MAX(RecordCountByInvestigator) AS [Total Record Count]
FROM #AgingRecordsByInvestigator
GROUP BY Investigator
ORDER BY Investigator

--PRINT 'FINAL RESULT'