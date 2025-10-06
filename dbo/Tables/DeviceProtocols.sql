CREATE TABLE [dbo].[DeviceProtocols] (
    [ProtocolId]  INT            NOT NULL,
    [Name]        NVARCHAR (255) NOT NULL,
    [Description] NVARCHAR (255) NULL,
    CONSTRAINT [pk_ProtocolId] PRIMARY KEY CLUSTERED ([ProtocolId] ASC),
    CONSTRAINT [u_DevProt_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


GO

