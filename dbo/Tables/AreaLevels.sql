CREATE TABLE [dbo].[AreaLevels] (
    [ViewAreaId]  INT CONSTRAINT [df_ViewAreaId] DEFAULT ((0)) NOT NULL,
    [AreaLevel]   INT CONSTRAINT [df_AreaLevel] DEFAULT ((0)) NOT NULL,
    [AreaLabelId] INT CONSTRAINT [df_AreaLabelId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_AreaLevels] PRIMARY KEY CLUSTERED ([ViewAreaId] ASC, [AreaLevel] ASC)
);


GO

