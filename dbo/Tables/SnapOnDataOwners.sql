CREATE TABLE [dbo].[SnapOnDataOwners] (
    [SnapOnDataOwnerId] INT            IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (255) NOT NULL,
    CONSTRAINT [SnapOnDataOwners_PK] PRIMARY KEY CLUSTERED ([SnapOnDataOwnerId] ASC),
    CONSTRAINT [SnapOnDataOwners_UC1] UNIQUE NONCLUSTERED ([Name] ASC)
);


GO

