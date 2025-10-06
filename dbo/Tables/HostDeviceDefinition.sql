CREATE TABLE [dbo].[HostDeviceDefinition] (
    [NetworkInfoKey]   INT            NOT NULL,
    [HostDeviceId]     NVARCHAR (255) NOT NULL,
    [DeviceDefinition] NVARCHAR (255) NOT NULL,
    [GSDId]            INT            NOT NULL,
    CONSTRAINT [PK_ProfibusDPDeviceInfo] PRIMARY KEY CLUSTERED ([NetworkInfoKey] ASC, [HostDeviceId] ASC),
    CONSTRAINT [FK_HostDeviceDefinition_NetworkInfo] FOREIGN KEY ([NetworkInfoKey]) REFERENCES [dbo].[NetworkInfo] ([NetworkInfoKey])
);


GO

