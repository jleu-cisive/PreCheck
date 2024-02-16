CREATE proc dbo.AIMS_ShowPublicRecordsIntegResp(
@apno int = null,--3613252
@date1 datetime = '01/01/2018',
@date2 datetime = null
)
as
if (@date2 is null)
set @date2 = GETDATE()
--declare @apno int = null--3613252
--declare @date1 datetime = '01/01/2017'
--declare @date2 datetime = '01/01/2018'
SELECT distinct 
		Node.Data.value('(Apno)[1]', 'INT') as Apno
        ,Node.Data.value('(SectionID)[1]', 'INT') as CrimID	
		,vo.VendorName as Vendor	
        ,Node.Data.value('(Last)[1]', 'VARCHAR(100)') as [Last]
		,Node.Data.value('(First)[1]', 'VARCHAR(50)') as First
		,Node.Data.value('(NoRecord)[1]', 'VARCHAR(10)') as NoRecord
		,Node.Data.value('(CaseNo)[1]', 'VARCHAR(30)') as CaseNo
		,Node.Data.value('(SSNOnRecord)[1]', 'VARCHAR(20)') as SSNOnRecord
		,Node.Data.value('(DOBOnRecord)[1]', 'VARCHAR(20)') as DOBOnRecord
		,Node.Data.value('(AdditionalInformation)[1]', 'VARCHAR(MAX)') as AdditionalInformation
		,Node.Data.value('(NotesCaseInformation)[1]', 'VARCHAR(MAX)') as NotesCaseInformation
		,Node.Data.value('(DateFiled)[1]', 'VARCHAR(20)') as DateFiled
		,Node.Data.value('(Disposition)[1]', 'VARCHAR(MAX)') as Disposition
		,Node.Data.value('(Fine)[1]', 'VARCHAR(MAX)') as Fine
		,Node.Data.value('(Sentence)[1]', 'VARCHAR(MAX)') as Sentence
		,Node.Data.value('(Offense)[1]', 'VARCHAR(MAX)') as Offense
		,Node.Data.value('(DispositionDate)[1]', 'VARCHAR(20)') as DispositionDate
		,Node.Data.value('(Degree)[1]', 'VARCHAR(MAX)') as Degree
		,Node.Data.value('(DegreeDescription)[1]', 'VARCHAR(MAX)') as DegreeDescription
		,Node.Data.value('(WarrantStatus)[1]', 'VARCHAR(MAX)') as WarrantStatus
		,vo.CreatedDate as [SentFromVendorTime]
		,case when 
			Node.Data.value('(Error/HasError)[1]', 'BIT') = 1 
		then
			Node.Data.value('(Error/ErrorMessage)[1]', 'VARCHAR(MAX)') end as ErrorMessage     
From Integration_VendorOrder vo (nolock)  CROSS APPLY Request.nodes('/Order/ItemList/Item') Node(Data) 
inner join dbo.Crim c (nolock) on c.CrimID = Node.Data.value('(SectionID)[1]','int') 
where 
		vo.VendorOperation='Completed' --and VendorName='Wholesale'  
	and 
		c.APNO= COALESCE(@apno,APNO)
	and 
		vo.CreatedDate Between COALESCE(@date1,vo.CreatedDate) 
	and COALESCE(@date2,vo.CreatedDate)
