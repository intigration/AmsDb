CREATE TABLE [dbo].[MinorDeviceCategories] (
    [MinorDeviceCategoryId] INT            CONSTRAINT [df_MinorDevCat_MinorDeviceCategoryId] DEFAULT ((0)) NOT NULL,
    [Name]                  NVARCHAR (255) NOT NULL,
    [Description]           NVARCHAR (255) NULL,
    CONSTRAINT [pk_MinorDeviceCategoryId] PRIMARY KEY CLUSTERED ([MinorDeviceCategoryId] ASC),
    CONSTRAINT [u_MinorDevCat_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


GO

