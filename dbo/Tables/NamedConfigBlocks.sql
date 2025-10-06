CREATE TABLE [dbo].[NamedConfigBlocks] (
    [ConfigKey]  INT          CONSTRAINT [df_NamedConfigBlocks_ConfigKey] DEFAULT ((0)) NOT NULL,
    [BlockIndex] INT          CONSTRAINT [df_NamedConfigBlocks_BlockIndex] DEFAULT ((0)) NOT NULL,
    [BlockType]  NVARCHAR (1) CONSTRAINT [df_NamedConfigBlocks_BlockType] DEFAULT ('') NOT NULL,
    CONSTRAINT [pk_NamedConfigBlocks] PRIMARY KEY CLUSTERED ([ConfigKey] ASC, [BlockIndex] ASC),
    CONSTRAINT [fk_NamedConfigBlocks_ConfigKey] FOREIGN KEY ([ConfigKey]) REFERENCES [dbo].[NamedConfigs] ([ConfigKey]),
    CONSTRAINT [NamedConfigBlocks_UC1] UNIQUE NONCLUSTERED ([ConfigKey] ASC, [BlockIndex] ASC)
);


GO

