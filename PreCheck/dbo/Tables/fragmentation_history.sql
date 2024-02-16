CREATE TABLE [dbo].[fragmentation_history] (
    [history_id]                          INT        IDENTITY (1, 1) NOT NULL,
    [database_id]                         SMALLINT   NULL,
    [database_name]                       [sysname]  NULL,
    [schema_id]                           INT        NULL,
    [schema_name]                         [sysname]  NULL,
    [object_id]                           INT        NULL,
    [object_name]                         [sysname]  NULL,
    [index_id]                            INT        NULL,
    [index_name]                          [sysname]  NULL,
    [partition_number]                    INT        NULL,
    [avg_fragmentation_in_percent_before] FLOAT (53) NULL,
    [avg_fragmentation_in_percent_after]  FLOAT (53) NULL,
    [alter_start]                         DATETIME   NULL,
    [alter_end]                           DATETIME   NULL,
    [progress]                            DATETIME   NULL
) ON [PRIMARY];

