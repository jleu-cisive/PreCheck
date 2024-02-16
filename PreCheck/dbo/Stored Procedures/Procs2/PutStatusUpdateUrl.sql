
/****** Object:  StoredProcedure [dbo].[PutStatusUpdateUrl]    Script Date: 8/12/2019 9:29:09 AM ******/


CREATE procedure [dbo].[PutStatusUpdateUrl]
( @apno int,@url varchar(300))
as
insert into [dbo].[Integration_StatusUpdate_Urls] 
select @Apno,@Url,GETDATE()




