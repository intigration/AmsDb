CREATE TABLE [dbo].[DeviceRevisions] (
    [AmsDevRevId]      INT            NOT NULL,
    [AmsDevTypeId]     INT            CONSTRAINT [df_DevRev_AmsDevTypeId] DEFAULT ((-1)) NOT NULL,
    [DeviceRevision]   NVARCHAR (255) NOT NULL,
    [DeviceCategoryId] INT            CONSTRAINT [df_DevRev_DeviceCategoryId] DEFAULT ((0)) NOT NULL,
    [Name]             NVARCHAR (255) NULL,
    [Description]      NVARCHAR (255) NULL,
    CONSTRAINT [pk_DevRev_AmsDevRevId] PRIMARY KEY CLUSTERED ([AmsDevRevId] ASC),
    CONSTRAINT [fk_DevRev_AmsDevTypeId] FOREIGN KEY ([AmsDevTypeId]) REFERENCES [dbo].[DeviceTypes] ([AmsDevTypeId]),
    CONSTRAINT [fk_DevRev_DeviceCategoryId] FOREIGN KEY ([DeviceCategoryId]) REFERENCES [dbo].[DeviceCategories] ([DeviceCategoryId])
);


GO

CREATE NONCLUSTERED INDEX [AmsIdx_DeviceRevisions_DevRev]
    ON [dbo].[DeviceRevisions]([AmsDevTypeId] DESC, [DeviceRevision] DESC);


GO

