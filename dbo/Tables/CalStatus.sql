CREATE TABLE [dbo].[CalStatus] (
    [DeviceKey]                     INT CONSTRAINT [df_CalStatus_DeviceKey] DEFAULT ((0)) NOT NULL,
    [DevLastCalibrationDay]         INT CONSTRAINT [df_CalStatus_DevLastCalibrationDay] DEFAULT ((0)) NOT NULL,
    [DevLastCalibrationFraction]    INT CONSTRAINT [df_CalStatus_DevLastCalibrationFraction] DEFAULT ((0)) NOT NULL,
    [DevNextCalibrationDueDay]      INT CONSTRAINT [df_CalStatus_DevNextCalibrationDueDay] DEFAULT ((0)) NOT NULL,
    [DevNextCalibrationDueFraction] INT CONSTRAINT [df_CalStatus_DevNextCalibrationDueFraction] DEFAULT ((0)) NOT NULL,
    [DevPassedLastCalibration]      BIT CONSTRAINT [df_CalStatus_DevPassedLastCalibration] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_CalStatus] PRIMARY KEY CLUSTERED ([DeviceKey] ASC),
    CONSTRAINT [fk_CalStatus_DeviceKey] FOREIGN KEY ([DeviceKey]) REFERENCES [dbo].[Devices] ([DeviceKey])
);


GO

