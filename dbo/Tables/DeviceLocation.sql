CREATE TABLE [dbo].[DeviceLocation] (
    [BlockKey]       INT             CONSTRAINT [DF_DeviceLocation_BlockKey] DEFAULT ((0)) NOT NULL,
    [PlantServerKey] INT             CONSTRAINT [DF_DeviceLocation_PlantServerKey] DEFAULT ((0)) NOT NULL,
    [NetworkInfoKey] INT             CONSTRAINT [DF_DeviceLocation_NetworkInfoKey] DEFAULT ('-1') NOT NULL,
    [AmsPath]        NVARCHAR (1024) CONSTRAINT [DF_DeviceLocation_AMSPath] DEFAULT ('') NOT NULL,
    [HostPath]       NVARCHAR (1024) CONSTRAINT [DF_DeviceLocation_HostPath] DEFAULT ('') NOT NULL,
    [HostTag]        NVARCHAR (255)  CONSTRAINT [DF_DeviceLocation_HostTag] DEFAULT ('') NOT NULL,
    [IdentStatus]    INT             CONSTRAINT [DF_DeviceLocation_IdentStatus] DEFAULT ((0)) NOT NULL,
    [SisStatus]      INT             CONSTRAINT [DF_DeviceLocation_SisStatus] DEFAULT ((0)) NOT NULL,
    [LatencyFactor]  SMALLINT        CONSTRAINT [DF_DeviceLocation_LatencyFactor] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DeviceLocation] PRIMARY KEY NONCLUSTERED ([BlockKey] ASC, [PlantServerKey] ASC, [NetworkInfoKey] ASC),
    CONSTRAINT [FK_DeviceLocation_Blocks] FOREIGN KEY ([BlockKey]) REFERENCES [dbo].[Blocks] ([BlockKey]),
    CONSTRAINT [FK_DeviceLocation_NetworkInfo] FOREIGN KEY ([NetworkInfoKey]) REFERENCES [dbo].[NetworkInfo] ([NetworkInfoKey]),
    CONSTRAINT [FK_DeviceLocation_PlantServer] FOREIGN KEY ([PlantServerKey]) REFERENCES [dbo].[PlantServer] ([PlantServerKey])
);


GO

