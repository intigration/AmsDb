CREATE TABLE [dbo].[Blocks] (
    [BlockKey]      INT          NOT NULL,
    [DeviceKey]     INT          CONSTRAINT [df_Block_DeviceKey] DEFAULT ((-1)) NOT NULL,
    [BlockIndex]    INT          CONSTRAINT [df_Block_BlockIndex] DEFAULT ((0)) NOT NULL,
    [DispositionId] SMALLINT     CONSTRAINT [df_Block_DispositionId] DEFAULT ((0)) NOT NULL,
    [BlockType]     NVARCHAR (1) CONSTRAINT [df_Block_BlockType] DEFAULT ('') NOT NULL,
    CONSTRAINT [pk_Block_BlockKey] PRIMARY KEY CLUSTERED ([BlockKey] ASC),
    CONSTRAINT [fk_Block_DeviceKey] FOREIGN KEY ([DeviceKey]) REFERENCES [dbo].[Devices] ([DeviceKey]),
    CONSTRAINT [fk_Block_DispositionId] FOREIGN KEY ([DispositionId]) REFERENCES [dbo].[Dispositions] ([DispositionId])
);


GO

CREATE NONCLUSTERED INDEX [AmsIdx_Blocks_BlockIndex]
    ON [dbo].[Blocks]([DeviceKey] DESC, [BlockIndex] DESC);


GO

