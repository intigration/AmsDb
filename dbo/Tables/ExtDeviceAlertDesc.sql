CREATE TABLE [dbo].[ExtDeviceAlertDesc] (
    [AlertDescId]      INT             NOT NULL,
    [DDHelpText]       NVARCHAR (4000) NOT NULL,
    [ExtendedHelpText] NVARCHAR (4000) NULL,
    CONSTRAINT [fk_ExtDeviceAlertDesc_AlertDescId] FOREIGN KEY ([AlertDescId]) REFERENCES [dbo].[DeviceAlertDesc] ([AlertDescId]),
    CONSTRAINT [ExtDeviceAlertDesc_UC1] UNIQUE NONCLUSTERED ([AlertDescId] ASC)
);


GO

