CREATE TABLE [dbo].[Devices] (
    [DeviceKey]        INT            NOT NULL,
    [AmsDevRevId]      INT            CONSTRAINT [df_Dev_AmsDevRevId] DEFAULT ((-1)) NOT NULL,
    [AmsDeviceId]      NVARCHAR (255) CONSTRAINT [df_Dev_AmsDeviceId] DEFAULT ('') NOT NULL,
    [Identifier]       NVARCHAR (255) NOT NULL,
    [ProtocolRevision] NVARCHAR (50)  NULL,
    [DispositionId]    SMALLINT       CONSTRAINT [df_Dev_DispositionId] DEFAULT ((0)) NOT NULL,
    [AmsDeviceTag]     NVARCHAR (255) NULL,
    CONSTRAINT [pk_Dev_DeviceKey] PRIMARY KEY CLUSTERED ([DeviceKey] ASC),
    CONSTRAINT [fk_Dev_AmsDevRevId] FOREIGN KEY ([AmsDevRevId]) REFERENCES [dbo].[DeviceRevisions] ([AmsDevRevId]),
    CONSTRAINT [fk_Dev_DispositionId] FOREIGN KEY ([DispositionId]) REFERENCES [dbo].[Dispositions] ([DispositionId]),
    CONSTRAINT [u_Dev_AmsDeviceId] UNIQUE NONCLUSTERED ([AmsDeviceId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [AmsIdx_Devices_Identifier]
    ON [dbo].[Devices]([AmsDevRevId] DESC, [Identifier] DESC, [ProtocolRevision] ASC);


GO

