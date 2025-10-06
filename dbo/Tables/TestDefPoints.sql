CREATE TABLE [dbo].[TestDefPoints] (
    [TestDefinitionId] INT  CONSTRAINT [df_TestDefPts_TestDefinitionId] DEFAULT ((0)) NOT NULL,
    [TestPointId]      INT  CONSTRAINT [df_TestDefPts_TestPointId] DEFAULT ((0)) NOT NULL,
    [DefTestPoint]     REAL CONSTRAINT [df_TestDefPts_DefTestPoint] DEFAULT ((0)) NOT NULL,
    [Type]             INT  CONSTRAINT [df_TestDefPts_Type] DEFAULT ((99)) NOT NULL,
    CONSTRAINT [pk_TestDefPoints] PRIMARY KEY CLUSTERED ([TestDefinitionId] ASC, [TestPointId] ASC, [Type] ASC),
    CONSTRAINT [fk_TestDefPts_TestDefinitionId] FOREIGN KEY ([TestDefinitionId]) REFERENCES [dbo].[TestDefinition] ([TestDefinitionId])
);


GO

