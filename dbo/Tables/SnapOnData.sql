CREATE TABLE [dbo].[SnapOnData] (
    [SnapOnDataId]      INT            NOT NULL,
    [BlockKey]          INT            NOT NULL,
    [EventIdDay]        INT            NOT NULL,
    [EventIdFraction]   INT            NOT NULL,
    [SnapOnDataOwnerId] INT            NOT NULL,
    [SnapOnDataNote]    NVARCHAR (255) NULL,
    [SnapOnDataType]    INT            NULL,
    [SnapOnData]        IMAGE          NULL,
    CONSTRAINT [SnapOnData_PK] PRIMARY KEY CLUSTERED ([SnapOnDataId] ASC),
    CONSTRAINT [Blocks_SnapOnData_FK1] FOREIGN KEY ([BlockKey]) REFERENCES [dbo].[Blocks] ([BlockKey]),
    CONSTRAINT [SnapOnDataOwners_SnapOnData_FK1] FOREIGN KEY ([SnapOnDataOwnerId]) REFERENCES [dbo].[SnapOnDataOwners] ([SnapOnDataOwnerId]),
    CONSTRAINT [SnapOnData_UC2] UNIQUE NONCLUSTERED ([BlockKey] ASC, [EventIdDay] ASC, [EventIdFraction] ASC, [SnapOnDataType] ASC, [SnapOnDataOwnerId] ASC, [SnapOnDataNote] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_SnapOnData_BlockKey]
    ON [dbo].[SnapOnData]([BlockKey] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_SnapOnDataOwner_BlockKey]
    ON [dbo].[SnapOnData]([BlockKey] ASC, [SnapOnDataOwnerId] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_SnapOnDataOwner_SnapOnDataNote]
    ON [dbo].[SnapOnData]([SnapOnDataNote] ASC, [SnapOnDataOwnerId] ASC);


GO

