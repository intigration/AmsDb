CREATE TABLE [dbo].[RouteFolders] (
    [FolderId]   INT           CONSTRAINT [df_RouteFolders_FolderId] DEFAULT ((0)) NOT NULL,
    [FolderName] NVARCHAR (32) CONSTRAINT [df_RouteFolders_FolderName] DEFAULT ('') NOT NULL,
    CONSTRAINT [pk_RouteFolders] PRIMARY KEY CLUSTERED ([FolderId] ASC),
    CONSTRAINT [u_RouteFolders_FolderName] UNIQUE NONCLUSTERED ([FolderName] ASC)
);


GO

