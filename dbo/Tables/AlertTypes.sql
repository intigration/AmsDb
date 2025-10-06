CREATE TABLE [dbo].[AlertTypes] (
    [AlertTypeId]   SMALLINT       IDENTITY (0, 1) NOT NULL,
    [Uid]           NVARCHAR (255) NOT NULL,
    [AlertTypeName] NVARCHAR (255) NOT NULL,
    CONSTRAINT [pk_AlertTypes] PRIMARY KEY CLUSTERED ([AlertTypeId] ASC),
    CONSTRAINT [AlertTypes_Uid_UC1] UNIQUE NONCLUSTERED ([Uid] ASC)
);


GO

