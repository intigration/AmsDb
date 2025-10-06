CREATE TABLE [dbo].[Components] (
    [TableName] NVARCHAR (20) NOT NULL,
    [TableKey]  INT           CONSTRAINT [df_Components_TableKey] DEFAULT ((0)) NOT NULL,
    [AreaId]    INT           CONSTRAINT [df_Components_AreaId] DEFAULT ((0)) NOT NULL,
    [LabelId]   INT           CONSTRAINT [df_Components_LabelId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_Components] PRIMARY KEY CLUSTERED ([TableName] ASC, [TableKey] ASC, [AreaId] ASC),
    CONSTRAINT [fk_Components_AreaId] FOREIGN KEY ([AreaId]) REFERENCES [dbo].[Hierarchies] ([AreaId])
);


GO

