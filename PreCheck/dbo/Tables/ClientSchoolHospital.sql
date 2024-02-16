CREATE TABLE [dbo].[ClientSchoolHospital] (
    [ClientSchoolHospitalID] INT IDENTITY (1, 1) NOT NULL,
    [CLNO_School]            INT NULL,
    [CLNO_Hospital]          INT NULL,
    [IsActive]               BIT NULL,
    CONSTRAINT [PK_ClientSchoolHospital] PRIMARY KEY CLUSTERED ([ClientSchoolHospitalID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ClientSchoolHospital_CLNO-School]
    ON [dbo].[ClientSchoolHospital]([CLNO_School] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [CLNO_Hospital_Includes]
    ON [dbo].[ClientSchoolHospital]([CLNO_Hospital] ASC)
    INCLUDE([IsActive]) WITH (FILLFACTOR = 100);

