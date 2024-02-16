/*
	exec [dbo].[PendingCrims_GetCrimsFromReview] 34424343
*/

CREATE PROCEDURE [dbo].[PendingCrims_GetCrimsFromReview]
@crimid int
as begin

SELECT [t3].[test], [t3].[Crim_ReviewID], [t3].[CrimID], [t3].[DOB], [t3].[SSN], [t3].[CaseNo], [t3].[Date_Filed], 
		[t3].[Degree], [t3].[Offense], [t3].[Disposition], [t3].[Sentence], [t3].[Fine], [t3].[Disp_Date], 
		[t3].[NotesCaseInformation], [t3].[WarrantStatus], [t3].[NameonRecord], [t3].[SSN_OnRecord], 
		[t3].[DOB_OnRecord], [t3].[CrimStatus], [t3].[ResolvedStatus], [t3].[ResolvedBy], [t3].[ResolvedDate],
		[t3].[AdditionalInformation], [t3].[AIMS_ReviewDate], [t3].[RefDispositionID]
FROM (
    SELECT [t0].[CrimID], [t0].[DOB], [t0].[SSN], [t0].[CaseNo], [t0].[Date_Filed], [t0].[Degree], 
			[t0].[Offense], [t0].[Disposition], [t0].[Sentence], [t0].[Fine], [t0].[Disp_Date], 
			[t0].[WarrantStatus], [t0].[NameonRecord], [t0].[SSN_OnRecord], [t0].[DOB_OnRecord], 
			[t0].[CrimStatus], [t0].[AdditionalInformation], [t0].[NotesCaseInformation],
			[t0].[RefDispositionID]
    FROM [dbo].[Crim_Review] AS [t0]
    WHERE [t0].[CrimID] = @crimid
    GROUP BY [t0].[CrimID], [t0].[DOB], [t0].[SSN], [t0].[CaseNo], [t0].[Date_Filed], [t0].[Degree], 
			[t0].[Offense], [t0].[Disposition], [t0].[Sentence], [t0].[Fine], [t0].[Disp_Date], [t0].[WarrantStatus], 
			[t0].[NameonRecord], [t0].[SSN_OnRecord], [t0].[DOB_OnRecord], [t0].[CrimStatus], 
			[t0].[AdditionalInformation], [t0].[NotesCaseInformation], [t0].[RefDispositionID]
    ) AS [t1]
OUTER APPLY (
    SELECT  1 AS [test], [t2].[Crim_ReviewID], [t2].[CrimID], [t2].[DOB], [t2].[SSN], [t2].[CaseNo], [t2].[Date_Filed], 
			[t2].[Degree], [t2].[Offense], [t2].[Disposition], [t2].[Sentence], [t2].[Fine], [t2].[Disp_Date], 
			[t2].[NotesCaseInformation], [t2].[WarrantStatus], [t2].[NameonRecord], [t2].[SSN_OnRecord], 
			[t2].[DOB_OnRecord], [t2].[CrimStatus], [t2].[ResolvedStatus], [t2].[ResolvedBy], [t2].[ResolvedDate], 
			[t2].[AdditionalInformation], [t2].[AIMS_ReviewDate], [t2].[RefDispositionID]
    FROM [dbo].[Crim_Review] AS [t2]
    WHERE ([t1].[CrimID] = [t2].[CrimID]) AND 
	((([t1].[DOB] IS NULL) AND ([t2].[DOB] IS NULL)) OR (([t1].[DOB] IS NOT NULL) AND ([t2].[DOB] IS NOT NULL) AND ((([t1].[DOB] IS NULL) AND ([t2].[DOB] IS NULL)) OR (([t1].[DOB] IS NOT NULL) AND ([t2].[DOB] IS NOT NULL) AND ([t1].[DOB] = [t2].[DOB]))))) 
	AND ((([t1].[SSN] IS NULL) AND ([t2].[SSN] IS NULL)) OR (([t1].[SSN] IS NOT NULL) AND ([t2].[SSN] IS NOT NULL) AND ((([t1].[SSN] IS NULL) AND ([t2].[SSN] IS NULL)) OR (([t1].[SSN] IS NOT NULL) AND ([t2].[SSN] IS NOT NULL) AND ([t1].[SSN] = [t2].[SSN]))))) 
	AND ((([t1].[CaseNo] IS NULL) AND ([t2].[CaseNo] IS NULL)) OR (([t1].[CaseNo] IS NOT NULL) AND ([t2].[CaseNo] IS NOT NULL) AND ((([t1].[CaseNo] IS NULL) AND ([t2].[CaseNo] IS NULL)) OR (([t1].[CaseNo] IS NOT NULL) AND ([t2].[CaseNo] IS NOT NULL) AND ([t1].[CaseNo] = [t2].[CaseNo]))))) 
	AND ((([t1].[Date_Filed] IS NULL) AND ([t2].[Date_Filed] IS NULL)) OR (([t1].[Date_Filed] IS NOT NULL) AND ([t2].[Date_Filed] IS NOT NULL) 	AND ((([t1].[Date_Filed] IS NULL) AND ([t2].[Date_Filed] IS NULL)) OR (([t1].[Date_Filed] IS NOT NULL) AND ([t2].[Date_Filed] IS NOT NULL) AND ([t1].[Date_Filed] = [t2].[Date_Filed])))))
	 AND ((([t1].[Degree] IS NULL) AND ([t2].[Degree] IS NULL)) OR (([t1].[Degree] IS NOT NULL) AND ([t2].[Degree] IS NOT NULL)  AND ((([t1].[Degree] IS NULL) AND ([t2].[Degree] IS NULL)) OR (([t1].[Degree] IS NOT NULL) AND ([t2].[Degree] IS NOT NULL) AND ([t1].[Degree] = [t2].[Degree]))))) 
	 AND ((([t1].[Offense] IS NULL) AND ([t2].[Offense] IS NULL)) OR (([t1].[Offense] IS NOT NULL) AND ([t2].[Offense] IS NOT NULL) AND ((([t1].[Offense] IS NULL) AND ([t2].[Offense] IS NULL)) OR (([t1].[Offense] IS NOT NULL) AND ([t2].[Offense] IS NOT NULL) AND ([t1].[Offense] = [t2].[Offense]))))) 
	 AND ((([t1].[Disposition] IS NULL) AND ([t2].[Disposition] IS NULL)) OR (([t1].[Disposition] IS NOT NULL) AND ([t2].[Disposition] IS NOT NULL) AND ((([t1].[Disposition] IS NULL) AND ([t2].[Disposition] IS NULL)) OR (([t1].[Disposition] IS NOT NULL) AND ([t2].[Disposition] IS NOT NULL) AND ([t1].[Disposition] = [t2].[Disposition]))))) 
	 AND ((([t1].[Sentence] IS NULL) AND ([t2].[Sentence] IS NULL)) OR (([t1].[Sentence] IS NOT NULL) AND ([t2].[Sentence] IS NOT NULL) AND ((([t1].[Sentence] IS NULL) AND ([t2].[Sentence] IS NULL)) OR (([t1].[Sentence] IS NOT NULL) AND ([t2].[Sentence] IS NOT NULL) AND ([t1].[Sentence] = [t2].[Sentence]))))) 
	 AND ((([t1].[Fine] IS NULL) AND ([t2].[Fine] IS NULL)) OR (([t1].[Fine] IS NOT NULL) AND ([t2].[Fine] IS NOT NULL) AND ((([t1].[Fine] IS NULL) AND ([t2].[Fine] IS NULL)) OR (([t1].[Fine] IS NOT NULL) AND ([t2].[Fine] IS NOT NULL) AND ([t1].[Fine] = [t2].[Fine]))))) 
	 AND ((([t1].[Disp_Date] IS NULL) AND ([t2].[Disp_Date] IS NULL)) OR (([t1].[Disp_Date] IS NOT NULL) AND ([t2].[Disp_Date] IS NOT NULL) AND ((([t1].[Disp_Date] IS NULL) AND ([t2].[Disp_Date] IS NULL)) OR (([t1].[Disp_Date] IS NOT NULL) AND ([t2].[Disp_Date] IS NOT NULL) AND ([t1].[Disp_Date] = [t2].[Disp_Date]))))) 
	 AND ((([t1].[WarrantStatus] IS NULL) AND ([t2].[WarrantStatus] IS NULL)) OR (([t1].[WarrantStatus] IS NOT NULL) AND ([t2].[WarrantStatus] IS NOT NULL) AND ((([t1].[WarrantStatus] IS NULL) AND ([t2].[WarrantStatus] IS NULL)) OR (([t1].[WarrantStatus] IS NOT NULL) AND ([t2].[WarrantStatus] IS NOT NULL)  AND ([t1].[WarrantStatus] = [t2].[WarrantStatus]))))) 
	 AND ((([t1].[NameonRecord] IS NULL) AND ([t2].[NameonRecord] IS NULL)) OR (([t1].[NameonRecord] IS NOT NULL) AND ([t2].[NameonRecord] IS NOT NULL) 
	 AND ((([t1].[NameonRecord] IS NULL) AND ([t2].[NameonRecord] IS NULL)) OR (([t1].[NameonRecord] IS NOT NULL) AND ([t2].[NameonRecord] IS NOT NULL) AND ([t1].[NameonRecord] = [t2].[NameonRecord]))))) 
	 AND ((([t1].[SSN_OnRecord] IS NULL) AND ([t2].[SSN_OnRecord] IS NULL)) OR (([t1].[SSN_OnRecord] IS NOT NULL) AND ([t2].[SSN_OnRecord] IS NOT NULL) 
	 AND ((([t1].[SSN_OnRecord] IS NULL) AND ([t2].[SSN_OnRecord] IS NULL)) OR (([t1].[SSN_OnRecord] IS NOT NULL) AND ([t2].[SSN_OnRecord] IS NOT NULL) AND ([t1].[SSN_OnRecord] = [t2].[SSN_OnRecord]))))) 
	 AND ((([t1].[DOB_OnRecord] IS NULL) AND ([t2].[DOB_OnRecord] IS NULL)) OR (([t1].[DOB_OnRecord] IS NOT NULL) AND ([t2].[DOB_OnRecord] IS NOT NULL) 
	 AND ((([t1].[DOB_OnRecord] IS NULL) AND ([t2].[DOB_OnRecord] IS NULL)) OR (([t1].[DOB_OnRecord] IS NOT NULL) AND ([t2].[DOB_OnRecord] IS NOT NULL) AND ([t1].[DOB_OnRecord] = [t2].[DOB_OnRecord]))))) 
	 AND ((([t1].[CrimStatus] IS NULL) AND ([t2].[CrimStatus] IS NULL)) OR (([t1].[CrimStatus] IS NOT NULL) AND ([t2].[CrimStatus] IS NOT NULL) 
	 AND ((([t1].[CrimStatus] IS NULL) AND ([t2].[CrimStatus] IS NULL)) OR (([t1].[CrimStatus] IS NOT NULL) AND ([t2].[CrimStatus] IS NOT NULL) AND ([t1].[CrimStatus] = [t2].[CrimStatus]))))) 
	 AND ((([t1].[AdditionalInformation] IS NULL) AND ([t2].[AdditionalInformation] IS NULL)) OR (([t1].[AdditionalInformation] IS NOT NULL) AND ([t2].[AdditionalInformation] IS NOT NULL) 
	 AND ((([t1].[AdditionalInformation] IS NULL) AND ([t2].[AdditionalInformation] IS NULL)) OR (([t1].[AdditionalInformation] IS NOT NULL) AND ([t2].[AdditionalInformation] IS NOT NULL) AND ([t1].[AdditionalInformation] = [t2].[AdditionalInformation]))))) 
	 AND ((([t1].[NotesCaseInformation] IS NULL) AND ([t2].[NotesCaseInformation] IS NULL)) OR (([t1].[NotesCaseInformation] IS NOT NULL) AND ([t2].[NotesCaseInformation] IS NOT NULL) 
	 AND ((([t1].[NotesCaseInformation] IS NULL) AND ([t2].[NotesCaseInformation] IS NULL)) OR (([t1].[NotesCaseInformation] IS NOT NULL) AND ([t2].[NotesCaseInformation] IS NOT NULL) AND ([t1].[NotesCaseInformation] = [t2].[NotesCaseInformation]))))) 
	 AND ([t2].[CrimID] = @crimid)
    ) AS [t3]



end