CREATE TABLE [dbo].[DeviceCategories] (
    [DeviceCategoryId]      INT CONSTRAINT [df_DeviceCategories_DeviceCategoryId] DEFAULT ((0)) NOT NULL,
    [MajorDeviceCategoryId] INT CONSTRAINT [df_DeviceCategories_MajorDeviceCategoryId] DEFAULT ((0)) NOT NULL,
    [MinorDeviceCategoryId] INT CONSTRAINT [df_DeviceCategories_MinorDeviceCategoryId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_DeviceCategoryId] PRIMARY KEY CLUSTERED ([DeviceCategoryId] ASC),
    CONSTRAINT [fk_DevCat_MajorDeviceCategoryId] FOREIGN KEY ([MajorDeviceCategoryId]) REFERENCES [dbo].[MajorDeviceCategories] ([MajorDeviceCategoryId]),
    CONSTRAINT [fk_DevCat_MinorDeviceCategoryId] FOREIGN KEY ([MinorDeviceCategoryId]) REFERENCES [dbo].[MinorDeviceCategories] ([MinorDeviceCategoryId])
);


GO

