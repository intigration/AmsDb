CREATE TABLE [dbo].[MfrProtocols] (
    [MfrProtocolId] INT            NOT NULL,
    [AmsMfrNameId]  INT            CONSTRAINT [df_MfrProt_AmsMfrNameId] DEFAULT ((-1)) NOT NULL,
    [ProtocolId]    INT            CONSTRAINT [df_MfrProt_ProtocolId] DEFAULT ((0)) NOT NULL,
    [MfrId]         NVARCHAR (255) NULL,
    CONSTRAINT [pk_MfrProtocolId] PRIMARY KEY CLUSTERED ([MfrProtocolId] ASC),
    CONSTRAINT [fk_MfrProt_AmsMfrNameId] FOREIGN KEY ([AmsMfrNameId]) REFERENCES [dbo].[Manufacturers] ([AmsMfrNameId]),
    CONSTRAINT [fk_MfrProt_ProtocolId] FOREIGN KEY ([ProtocolId]) REFERENCES [dbo].[DeviceProtocols] ([ProtocolId])
);


GO

CREATE NONCLUSTERED INDEX [AmsIdx_MfrProtocols_MfrId]
    ON [dbo].[MfrProtocols]([MfrId] DESC, [ProtocolId] DESC);


GO

