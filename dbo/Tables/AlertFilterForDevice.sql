CREATE TABLE [dbo].[AlertFilterForDevice] (
    [BlockKey]    INT NOT NULL,
    [AlertDescId] INT CONSTRAINT [DF_AlertFilterForDevice_AlertDescId] DEFAULT ('00000000000') NOT NULL,
    [Enabled]     BIT CONSTRAINT [DF_AlertFilterForDevice_Enabled] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AlertFilterForDevice] PRIMARY KEY CLUSTERED ([BlockKey] ASC, [AlertDescId] ASC),
    CONSTRAINT [FK1_AlertDescID_AlertFilterForDevice] FOREIGN KEY ([AlertDescId]) REFERENCES [dbo].[DeviceAlertDesc] ([AlertDescId]),
    CONSTRAINT [FK2_BlockKey_AlertFilterForDevice] FOREIGN KEY ([BlockKey]) REFERENCES [dbo].[DeviceMonitorList] ([BlockKey])
);


GO

