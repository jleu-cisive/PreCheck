﻿
CREATE view [STG].[Empl_CT]
as
SELECT  Null [EmplID]
      ,ApplicantNumber  [APNO]
      ,EmployerName [Employer]
      ,[Address] [Location]
      ,Null  [SectStat]
      ,Null  [Worksheet]
      ,SupervisorPhone  [Phone]
      ,SupervisorName [Supervisor]
      ,SupervisorPhone [SupPhone]
      ,Null [Dept]
      ,ReasonForLeaving [RFL]
      ,~(IsOKToContact) [DNC] --flip the value - schapyala on 08/02/2017 (~ is the operator equivalent to NOT)
      ,Null [SpecialQ]
      ,Null [Ver_Salary]
      ,EmploymentFrom [From_A]
      ,[EmploymentTo] [To_A]
      ,EndDesignation [Position_A] --schapyala changed from StartDesignation because EndDesignation is the current position which is what we will verify
      ,EndSalary [Salary_A] --schapyala changed from StartSalary because EndSalary is the current salary which is what we will verify
      ,Null [From_V]
      ,Null [To_V]
      ,Null [Position_V]
      ,Null [Salary_V]
      ,Null [Emp_Type]
      ,Null [Rel_Cond]
      ,Null [Rehire]
      ,Null [Ver_By]
      ,Null [Title]
      ,Null [Priv_Notes]
      ,Null [Pub_Notes]
      ,Null [web_status]
      ,Null [web_updated]
      ,Null [Includealias]
      ,Null [Includealias2]
      ,Null [Includealias3]
      ,Null [Includealias4]
      ,Null [PendingUpdated]
      ,Null [Time_In]
      ,ModifyDate [Last_Updated]
      ,City [city]
      ,[State] [state]
      ,Zip [zipcode]
      ,Null [Investigator]
      ,Null [EmployerID]
      ,Null [InvestigatorAssigned]
      ,Null [PendingChanged]
      ,Null [TempInvestigator]
      ,Null [InUse]
      ,CreateDate [CreatedDate]
      ,CreateBy [EnteredBy]
      ,Null [EnteredDate]
      ,Null [IsCamReview]
      ,Null [Last_Worked]
      ,Null [ClientEmployerID]
      ,Null [AutoFaxStatus]
      ,Null [IsOnReport]
      ,Null [IsHidden]
      ,Null [IsHistoryRecord]
      ,Null [EmploymentStatus]
      ,IsOKToContact [IsOKtoContact]
      ,Null [OKtoContactInitial]
      ,Null [EmplVerifyID]
      ,Null [GetNextDate]
      ,Null [SubStatusID]
      ,Null [ClientAdjudicationStatus]
      ,Null [ClientRefID]
      ,case when Country in ('USA','US','America','States') then 0 else 1 end [IsIntl]
      ,Null [DateOrdered]
      ,Null [OrderId]
      ,Null [Email]
      ,Null [AdverseRFL]
      ,Null [InUse_TimeStamp]
      ,Null [LastModifiedDate]
      ,Null [LastModifiedBy]
	  ,Operation
	  ,IsPresentEmployer  --Larry Ouch - added field 11/14/2018
  FROM [STG].[ApplicantEmployment_CT]

