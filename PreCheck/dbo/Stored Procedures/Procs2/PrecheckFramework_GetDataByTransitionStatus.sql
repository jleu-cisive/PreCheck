 

/* ***********************************************  

Created By Doug DeGenaro

Created Date : 12/20/2012

Description : Get transition data by status

*****************************************************/

--update dbo.appl set InUse = 'Case_S' where apno in (  

--select top 2 apno from dbo.Appl with (NOLOCK) order by apdate desc)  

  

--dbo.PrecheckFramework_GetDataByTransitionStatus 'Case_S' 



CREATE procedure [dbo].[PrecheckFramework_GetDataByTransitionStatus]  

(  

@transitionStatus varchar(100)  

)  

as  

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  

  

declare @apno int  

if (@transitionStatus = null)  

begin  

 set @transitionStatus = 'Service'  

end  

  

/****** Object:  Table [dbo].[Appl]    Script Date: 12/19/2012 11:58:07 ******/  

  

CREATE TABLE [dbo].[#tmpAppl](  

 [APNO] [int]  NOT NULL,  

 [Attn] [varchar](100) NULL,  

 [Last] [varchar](20) NOT NULL,  

 [First] [varchar](20) NOT NULL,  

 [Middle] [varchar](20) NULL,   

 [Addr_Street] [varchar](100) NULL,  

 [City] [varchar](50) NULL,  

 [State] [varchar](2) NULL,   

 [Pos_Sought] [varchar](50) NULL,  

 [Generation] [varchar](3) NULL,  

 [Alias1_Last] [varchar](20) NULL,  

 [Alias1_First] [varchar](20) NULL,  

 [Alias1_Middle] [varchar](20) NULL,  

 [Alias1_Generation] [varchar](3) NULL,  

 [Alias2_Last] [varchar](20) NULL,  

 [Alias2_First] [varchar](20) NULL,  

 [Alias2_Middle] [varchar](20) NULL,  

 [Alias2_Generation] [varchar](3) NULL,  

 [Alias3_Last] [varchar](20) NULL,  

 [Alias3_First] [varchar](20) NULL,  

 [Alias3_Middle] [varchar](20) NULL,  

 [Alias3_Generation] [varchar](3) NULL,  

 [Alias4_Last] [varchar](20) NULL,  

 [Alias4_First] [varchar](20) NULL,  

 [Alias4_Middle] [varchar](20) NULL,  

 [Alias4_Generation] [varchar](3) NULL  

 CONSTRAINT [PK_tmpAppl] PRIMARY KEY CLUSTERED   

(  

 [APNO] ASC  

))  

  

  

insert into [dbo].#tmpAppl (APNO  

 ,Attn  

 ,Last  

 ,First  

 ,Middle  

 ,Addr_Street  

 ,Generation  

 ,Alias1_First  

 ,Alias1_Middle  

 ,Alias1_Last  

 ,Alias1_Generation  

 ,Alias2_First  

 ,Alias2_Middle  

 ,Alias2_Last  

 ,Alias2_Generation  

 ,Alias3_First  

 ,Alias3_Middle  

 ,Alias3_Last  

 ,Alias3_Generation   

 ,Alias4_First  

 ,Alias4_Middle  

 ,Alias4_Last  

 ,Alias4_Generation  

 ,City  

 ,Pos_Sought)   

Select APNO  

 ,Attn  

 ,Last  

 ,First  

 ,Middle  

 ,Addr_Street  

 ,Generation  

 ,Alias1_First  

 ,Alias1_Middle  

 ,Alias1_Last  

 ,Alias1_Generation  

 ,Alias2_First  

 ,Alias2_Middle  

 ,Alias2_Last  

 ,Alias2_Generation  

 ,Alias3_First  

 ,Alias3_Middle  

 ,Alias3_Last  

 ,Alias3_Generation   

 ,Alias4_First  

 ,Alias4_Middle  

 ,Alias4_Last  

 ,Alias4_Generation  

 ,City  

 ,Pos_Sought   

 from DBO.Appl with (nolock)  

 where InUse = @transitionStatus  

   

 select   

 'Appl' as Section 

 ,APNO 

 ,Attn  

 ,Last  

 ,First  

 ,Middle  

 ,Addr_Street  

 ,Generation  

 ,Alias1_First  

 ,Alias1_Middle  

 ,Alias1_Last  

 ,Alias1_Generation  

 ,Alias2_First  

 ,Alias2_Middle  

 ,Alias2_Last  

 ,Alias2_Generation  

 ,Alias3_First  

 ,Alias3_Middle  

 ,Alias3_Last  

 ,Alias3_Generation   

 ,Alias4_First  

 ,Alias4_Middle  

 ,Alias4_Last  

 ,Alias4_Generation  

 ,City  

 ,Pos_Sought   

 from dbo.#tmpAppl  

  

 if (select count(1) from dbo.Empl where apno in (select apno from dbo.#tmpAppl)) > 0  

 select   

  'Empl' as Section 

  ,EmplId as SectionId

   ,APNO  

  ,Employer  

  ,Location

  ,Dept  

  ,Position_A  

 -- ,Position_V  

  ,Supervisor as Supervisor  

  ,RFL as RFL  

  ,City as City  

 from dbo.Empl  

 where apno in (select apno from dbo.#tmpAppl)  

   

 if (select count(1) from dbo.Educat where apno in (select apno from dbo.#tmpAppl)) > 0  

 SELECT   

       'Educat' as Section

        ,EducatId as SectionId 

       ,APNO

       ,[School]        

      ,[Degree_A]  

     -- ,[Degree_V]  

      ,[Studies_A]  

     -- ,[Studies_V]       

      ,[city]        

      ,[CampusName]        

  FROM [dbo].[Educat]  

  where apno in (select apno from dbo.#tmpAppl)  

  

 if (select count(1) from dbo.PersRef where apno in (select apno from dbo.#tmpAppl)) > 0  

  SELECT    

       'PersRef' as Section

        ,PersRefId as SectionId   

       ,APNO

       ,Name         

      ,[Rel_V]        

  FROM [dbo].[PersRef]  

 where apno in (select apno from dbo.#tmpAppl)  

  

    

 DROP Table dbo.#tmpAppl  



SET TRANSACTION ISOLATION LEVEL READ COMMITTED    
SET NOCOUNT OFF
   
