CREATE TABLE [dbo].[MajorDeviceCategories] (
    [MajorDeviceCategoryId] INT            CONSTRAINT [df_MajorDevCat_MajorDeviceCategoryId] DEFAULT ((0)) NOT NULL,
    [Name]                  NVARCHAR (255) NOT NULL,
    [Description]           NVARCHAR (255) NULL,
    CONSTRAINT [pk_MajorDeviceCategoryId] PRIMARY KEY CLUSTERED ([MajorDeviceCategoryId] ASC),
    CONSTRAINT [u_MajorDevCat_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


GO

