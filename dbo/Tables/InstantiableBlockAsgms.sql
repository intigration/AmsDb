CREATE TABLE [dbo].[InstantiableBlockAsgms] (
    [InstantiableBlockKey] INT            NOT NULL,
    [DDItemId]             NVARCHAR (255) NOT NULL,
    [UtcDateTimeIn]        DATETIME2 (7)  NOT NULL,
    [UtcDateTimeOut]       DATETIME2 (7)  DEFAULT (N'9999-12-31') NOT NULL,
    CONSTRAINT [PK_InstantiableBlockAsgms] PRIMARY KEY CLUSTERED ([InstantiableBlockKey] ASC, [DDItemId] ASC, [UtcDateTimeOut] ASC),
    CONSTRAINT [FK_InstantiableBlockAsgms_InstantiableBlockKey] FOREIGN KEY ([InstantiableBlockKey]) REFERENCES [dbo].[InstantiableConfigBlocks] ([InstantiableBlockKey])
);


GO

