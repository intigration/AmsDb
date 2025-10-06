CREATE TABLE [dbo].[AreaViews] (
    [ViewAreaId]  INT       CONSTRAINT [df_AreaViews_ViewAreaId] DEFAULT ((0)) NOT NULL,
    [ViewType]    NCHAR (1) NULL,
    [MaxLevels]   TINYINT   CONSTRAINT [df_AreaViews_MaxLevels] DEFAULT ((0)) NOT NULL,
    [Required]    BIT       NOT NULL,
    [Balanced]    BIT       NOT NULL,
    [Permissions] NCHAR (6) NULL,
    CONSTRAINT [pk_AreaViews] PRIMARY KEY CLUSTERED ([ViewAreaId] ASC)
);


GO

