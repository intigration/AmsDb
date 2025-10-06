CREATE TABLE [dbo].[DeviceMonitorList] (
    [BlockKey]     INT     NOT NULL,
    [MonitorGroup] TINYINT NOT NULL,
    [Frequency]    INT     CONSTRAINT [DF_DeviceMonitorList_Frequency] DEFAULT ((0)) NOT NULL,
    [DVMEnabled]   BIT     CONSTRAINT [DF_DeviceMonitorList_DVMEnabled] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DeviceMonitorList] PRIMARY KEY CLUSTERED ([BlockKey] ASC),
    CONSTRAINT [FK1_BlockKey_DeviceMonitorList] FOREIGN KEY ([BlockKey]) REFERENCES [dbo].[Blocks] ([BlockKey])
);


GO

