CREATE TABLE [dbo].[Routes] (
    [RouteId]               INT           CONSTRAINT [df_Routes_RouteId] DEFAULT ((0)) NOT NULL,
    [FolderId]              INT           CONSTRAINT [df_Routes_FolderId] DEFAULT ((0)) NOT NULL,
    [RouteName]             NVARCHAR (50) NOT NULL,
    [RouteDescription]      NVARCHAR (50) NULL,
    [DefaultCalibratorType] NVARCHAR (50) NOT NULL,
    [RouteStatus]           TINYINT       CONSTRAINT [df_Routes_RouteStatus] DEFAULT ((0)) NULL,
    [DownloadDay]           INT           CONSTRAINT [df_Routes_DownloadDay] DEFAULT ((0)) NOT NULL,
    [DownloadFraction]      INT           CONSTRAINT [df_Routes_DownloadFraction] DEFAULT ((0)) NOT NULL,
    [DownloadTestEquipId]   INT           CONSTRAINT [df_Routes_DownloadTestEquipId] DEFAULT ((0)) NOT NULL,
    [UploadDay]             INT           CONSTRAINT [df_Routes_UploadDay] DEFAULT ((0)) NOT NULL,
    [UploadFraction]        INT           CONSTRAINT [df_Routes_UploadFraction] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_Routes] PRIMARY KEY CLUSTERED ([RouteId] ASC),
    CONSTRAINT [fk_Routes] FOREIGN KEY ([FolderId]) REFERENCES [dbo].[RouteFolders] ([FolderId])
);


GO

