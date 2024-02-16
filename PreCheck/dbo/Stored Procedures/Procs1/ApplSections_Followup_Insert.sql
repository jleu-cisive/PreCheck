
CREATE PROCEDURE [dbo].[ApplSections_Followup_Insert]

(

      @apno int,

    @educatid int,

    @followupneededreason varchar(50),

    @followupneededdate datetime,
    
    @webstatus int,

    @investigator varchar(10),

	@sectionname varchar(10)=null

      

)

AS
begin
if @webstatus = 63

begin

update dbo.ApplSections_Followup set Repeat_Followup = 1,CompletedBy = @investigator,CompletedOn = getdate() where ApplSectionID = @educatid and Apno=@apno and Repeat_Followup = 0

INSERT INTO dbo.ApplSections_Followup (

ApplSectionID,

Apno,

SectionID,

Reason,

CreatedBy,

CreatedOn,

FollowupOn,

--CompletedBy,

--CompletedOn,

IsCompleted,

Repeat_Followup)

Values(

    @educatid,

    @apno,

    isnull(@sectionname,'Educat'),

    @followupneededreason,

    @investigator,

    getdate(),

    @followupneededdate,

    --@investigator,

   -- getdate(),

    0,

    0)
    
end
   else
    update dbo.ApplSections_Followup set IsCompleted = 1,CompletedBy = @investigator,CompletedOn = getdate() where ApplSectionID = @educatid and Apno=@apno and Repeat_Followup = 0
end
