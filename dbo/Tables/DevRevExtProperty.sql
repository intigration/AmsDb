CREATE TABLE [dbo].[DevRevExtProperty] (
    [AmsDevRevId]      INT            NOT NULL,
    [ExtPropertyName]  NVARCHAR (255) NOT NULL,
    [ExtPropertyValue] NVARCHAR (255) NOT NULL,
    CONSTRAINT [pk_DevRevExtProperty] PRIMARY KEY CLUSTERED ([AmsDevRevId] ASC, [ExtPropertyName] ASC),
    CONSTRAINT [FK_DevRevExtProperty_DeviceRevisions] FOREIGN KEY ([AmsDevRevId]) REFERENCES [dbo].[DeviceRevisions] ([AmsDevRevId])
);


GO

