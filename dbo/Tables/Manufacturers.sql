CREATE TABLE [dbo].[Manufacturers] (
    [AmsMfrNameId] INT            NOT NULL,
    [Name]         NVARCHAR (255) NOT NULL,
    [Description]  NVARCHAR (255) NULL,
    CONSTRAINT [pk_AmsMfrNameId] PRIMARY KEY CLUSTERED ([AmsMfrNameId] ASC),
    CONSTRAINT [u_Mfr_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


GO

