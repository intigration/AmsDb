CREATE TABLE [dbo].[Hierarchies] (
    [AreaId]       INT           CONSTRAINT [df_Hierarchies_AreaId] DEFAULT ((0)) NOT NULL,
    [ParentAreaId] INT           CONSTRAINT [df_Hierarchies_ParentAreaId] DEFAULT ((0)) NOT NULL,
    [ViewAreaId]   INT           CONSTRAINT [df_Hierarchies_ViewAreaId] DEFAULT ((0)) NOT NULL,
    [AreaLevel]    INT           CONSTRAINT [df_Hierarchies_AreaLevel] DEFAULT ((0)) NOT NULL,
    [AreaName]     NVARCHAR (32) NULL,
    [LabelId]      INT           CONSTRAINT [df_Hierarchies_LabelId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_Hierarchies] PRIMARY KEY CLUSTERED ([AreaId] ASC)
);


GO

