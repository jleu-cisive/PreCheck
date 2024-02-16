CREATE TABLE [dbo].[sql_errors] (
    [error_id]        INT            IDENTITY (1, 1) NOT NULL,
    [command]         VARCHAR (4000) NULL,
    [error_number]    INT            NULL,
    [error_severity]  SMALLINT       NULL,
    [error_state]     SMALLINT       NULL,
    [error_line]      INT            NULL,
    [error_message]   VARCHAR (4000) NULL,
    [error_procedure] VARCHAR (200)  NULL,
    [time_stamp]      DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([error_id] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY];

