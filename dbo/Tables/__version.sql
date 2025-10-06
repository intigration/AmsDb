CREATE TABLE [dbo].[__version] (
    [Major]       SMALLINT       CONSTRAINT [df_Major] DEFAULT ((0)) NOT NULL,
    [Minor]       SMALLINT       CONSTRAINT [df_Minor] DEFAULT ((0)) NOT NULL,
    [SchemaDate]  SMALLDATETIME  NULL,
    [SchemaNotes] NVARCHAR (256) NULL,
    CONSTRAINT [PK____version__2C3393D0] PRIMARY KEY CLUSTERED ([Major] ASC, [Minor] ASC)
);


GO

