



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [dbo].[sp_FormFreeReportList]
@apno int
As
Declare @ErrorCode int

Begin Transaction

select aa.FreeReportID As AAID 
       	,case a.apstatus
	 	when 'f' then ''
	 	else '*'
       	end as [Not Finished]
       	,aa.APNO
       	,aa.StatusID
       	,refas.Status
	--,r.ClientType		 
	,case when aa.CLNO is null then
				(select r.ClientType 
				  from Client c,refClientType r
				 where aa.apno=a.apno and a.clno=c.clno and c.ClientTypeID=r.ClientTypeID)			
	      else  (select r.ClientType 
			from Client c,refClientType r
		       where aa.CLNO=c.clno and c.ClientTypeID=r.ClientTypeID) 
			  
	end as ClientType
       	,'' as ClientEmail
 	,aa.[Name] As ApplicantName
	,aa.Address1
	,'' as Address2
       	,aa.City,aa.State
	,aa.Zip
	,aa.FreeReportLetterReturnID as PALetterReturnID
	,x.refAdverseLetterReturnDesc as PALetterReturnDesc
       	,aa.[2ndLetterReturnID] as AALetterReturnID
       	,y.refAdverseLetterReturnDesc as AALetterReturnDesc
  from FreeReport aa,refAdverseStatus refas,Appl a,refAdverseLetterReturn x,refAdverseLetterReturn y--,Client c,refClientType r
 where aa.apno=a.apno
   and aa.StatusID = refas.refAdverseStatusID
   --and (aa.StatusID  in (24,25,26,27,28) or aa.apno=@apno)
   and (aa.StatusID  in (24,25,26,27,28,35,39) or aa.apno=@apno)
   and aa.FreeReportLetterReturnID=x.refAdverseLetterReturnID
   and aa.[2ndLetterReturnID]=y.refAdverseLetterReturnID
order by aa.FreeReportID

  
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (0)







