CREATE TABLE [dbo].[DeviceAlertDesc] (
    [AlertDescId] INT            IDENTITY (1000, 1) NOT NULL,
    [AmsDevRevId] INT            NOT NULL,
    [AlertId]     NVARCHAR (50)  NOT NULL,
    [Description] NVARCHAR (256) NOT NULL,
    [AlertTypeId] SMALLINT       CONSTRAINT [DF_DeviceAlertDesc_AlertTypeId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DeviceAlertDesc] PRIMARY KEY CLUSTERED ([AlertDescId] ASC),
    CONSTRAINT [FK1_AmsDevRevID_DeviceAlertDesc] FOREIGN KEY ([AmsDevRevId]) REFERENCES [dbo].[DeviceRevisions] ([AmsDevRevId]),
    CONSTRAINT [UC1_DeviceAlertDesc] UNIQUE NONCLUSTERED ([AmsDevRevId] ASC, [AlertId] ASC)
);


GO

