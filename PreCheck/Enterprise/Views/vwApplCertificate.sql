

CREATE VIEW [Enterprise].[vwApplCertificate]
AS
SELECT        a.APNO, a.ApStatus, a.UserID, a.Billed, a.Investigator, a.EnteredBy, a.EnteredVia, a.ApDate, a.CompDate, a.CLNO, a.Attn, a.Last, a.First, a.Middle, a.Alias, a.Alias2, a.Alias3, a.Alias4, a.SSN, a.DOB, a.Sex, 
                         a.DL_State, a.DL_Number, a.Addr_Num, a.Addr_Dir, a.Addr_Street, a.Addr_StType, a.Addr_Apt, a.City, a.State, a.Zip, a.Pos_Sought, a.Update_Billing, a.Priv_Notes, a.Pub_Notes, a.PC_Time_Stamp, 
                         a.Pc_Time_Out, a.Special_instructions, a.Reason, a.ReopenDate, a.OrigCompDate, a.Generation, a.Alias1_Last, a.Alias1_First, a.Alias1_Middle, a.Alias1_Generation, a.Alias2_Last, a.Alias2_First, 
                         a.Alias2_Middle, a.Alias2_Generation, a.Alias3_Last, a.Alias3_First, a.Alias3_Middle, a.Alias3_Generation, a.Alias4_Last, a.Alias4_First, a.Alias4_Middle, a.Alias4_Generation, a.PrecheckChallenge, a.InUse, 
                         ClientAPNO = ISNULL(a.ClientAPNO,''), ClientApplicantNO=ISNULL(a.ClientApplicantNO,''), a.Last_Updated, a.DeptCode, a.NeedsReview, a.StartDate, a.RecruiterID, a.Phone, a.Rush, a.IsAutoPrinted, a.AutoPrintedDate, a.IsAutoSent, a.AutoSentDate, a.PackageID, 
                         a.Rel_Attached, a.CreatedDate, a.ClientProgramID AS Expr1, a.I94, a.Recruiter_Email, a.CAM, a.SubStatusID, a.GetNextDate, a.Email, a.CellPhone, a.OtherPhone, a.IsDrugTestFileFound_bit, 
                         a.IsDrugTestFileFound, a.FreeReport, a.ClientNotes, a.InProgressReviewed, a.LastModifiedDate, a.LastModifiedBy, o.BatchOrderDetailId, dbo.ClientCertification.ClientCertificationId, 
                         dbo.ClientCertification.ClientCertReceived
FROM            dbo.Appl AS a LEFT OUTER JOIN
                         Enterprise.dbo.[Order] AS o ON o.OrderNumber = a.APNO LEFT OUTER JOIN
                         dbo.ClientCertification ON a.APNO = dbo.ClientCertification.APNO


