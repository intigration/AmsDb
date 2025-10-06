CREATE TABLE [dbo].[ExtBlockTags] (
    [ExtBlockTagKey]   INT            CONSTRAINT [df_ExtBlockTag_ExtBlockTagKey] DEFAULT ((0)) NOT NULL,
    [ExtBlockTag]      NVARCHAR (40)  NOT NULL,
    [ExtBlockTagDesc]  NVARCHAR (255) NULL,
    [TestDefinitionId] INT            CONSTRAINT [df_ExtBlockTag_TestDefinitionId] DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [pk_ExtBlockTags] PRIMARY KEY CLUSTERED ([ExtBlockTagKey] ASC),
    CONSTRAINT [TestDefinition_ExtBlockTags_FK1] FOREIGN KEY ([TestDefinitionId]) REFERENCES [dbo].[TestDefinition] ([TestDefinitionId]),
    CONSTRAINT [u_ExtBlockTag] UNIQUE NONCLUSTERED ([ExtBlockTag] ASC)
);


GO

