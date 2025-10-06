CREATE TABLE [dbo].[DeviceTypes] (
    [AmsDevTypeId]  INT            NOT NULL,
    [MfrProtocolId] INT            CONSTRAINT [df_DevType_MfrProtocolId] DEFAULT ((-1)) NOT NULL,
    [DeviceType]    NVARCHAR (255) NOT NULL,
    [Name]          NVARCHAR (255) CONSTRAINT [df_DevType_Name] DEFAULT ('') NOT NULL,
    [Description]   NVARCHAR (255) NULL,
    CONSTRAINT [pk_AmsDevTypeId] PRIMARY KEY CLUSTERED ([AmsDevTypeId] ASC),
    CONSTRAINT [fk_DevType_MfrProtocolId] FOREIGN KEY ([MfrProtocolId]) REFERENCES [dbo].[MfrProtocols] ([MfrProtocolId])
);


GO

CREATE NONCLUSTERED INDEX [AmsIdx_DeviceTypes_DevType]
    ON [dbo].[DeviceTypes]([MfrProtocolId] DESC, [DeviceType] DESC);


GO

