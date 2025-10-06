CREATE TABLE [dbo].[Dispositions] (
    [DispositionId] SMALLINT       CONSTRAINT [df_Disp_DispositionId] DEFAULT ((0)) NOT NULL,
    [Name]          NVARCHAR (255) NOT NULL,
    [Description]   NVARCHAR (255) NULL,
    CONSTRAINT [pk_DispositionId] PRIMARY KEY CLUSTERED ([DispositionId] ASC),
    CONSTRAINT [u_Disp_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


GO

