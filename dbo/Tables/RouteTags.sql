CREATE TABLE [dbo].[RouteTags] (
    [ExtBlockTagKey]           INT           CONSTRAINT [df_RouteTags_ExtBlockTagKey] DEFAULT ((-1)) NOT NULL,
    [RouteId]                  INT           CONSTRAINT [df_RouteTags_RouteId] DEFAULT ((0)) NOT NULL,
    [DL_Status]                TINYINT       CONSTRAINT [df_RouteTags_DL_Status] DEFAULT ((0)) NOT NULL,
    [LocationInCalibrator]     NVARCHAR (50) NULL,
    [PreviousExtTagKeyInRoute] INT           CONSTRAINT [df_RouteTags_PreviousExtTagKeyInRoute] DEFAULT ((0)) NOT NULL,
    [NextExtTagKeyInRoute]     INT           CONSTRAINT [df_RouteTags_NextTagKeyInRoute] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_RouteTags] PRIMARY KEY CLUSTERED ([ExtBlockTagKey] ASC, [RouteId] ASC),
    CONSTRAINT [fk_RouteTags_ExtBlockTagKey] FOREIGN KEY ([ExtBlockTagKey]) REFERENCES [dbo].[ExtBlockTags] ([ExtBlockTagKey]),
    CONSTRAINT [fk_RouteTags_RouteId] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[Routes] ([RouteId])
);


GO

