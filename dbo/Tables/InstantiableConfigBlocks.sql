CREATE TABLE [dbo].[InstantiableConfigBlocks] (
    [InstantiableBlockKey] INT          NOT NULL,
    [DeviceKey]            INT          NOT NULL,
    [BlockIndex]           INT          NOT NULL,
    [BlockType]            NVARCHAR (1) NOT NULL,
    [ConfigType]           NVARCHAR (1) NOT NULL,
    CONSTRAINT [PK_InstantiableConfigBlocks] PRIMARY KEY CLUSTERED ([InstantiableBlockKey] ASC),
    CONSTRAINT [FK_InstantiableConfigBlocks_DeviceKey] FOREIGN KEY ([DeviceKey]) REFERENCES [dbo].[Devices] ([DeviceKey])
);


GO

