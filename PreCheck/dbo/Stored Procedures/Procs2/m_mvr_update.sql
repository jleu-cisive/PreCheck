CREATE procedure [dbo].[m_mvr_update](@apno int,@report varchar(max),@sectstat int)
as 
update DL set sectstat = @sectstat,web_status = case when @sectstat = 9 then web_status else null end,
	report = @report,last_Updated = Current_TimeStamp where APNO = @apno


------------------END OF ALTERING OF DL STORED PROCEDURES------------------------	
	