create procedure [PRECHECK\DDegenaro].m_mvr_reorder 
(
	@apno int
)

as 

update dl set sectstat = '9',web_status = null,dateordered = null 
where apno = @apno