CREATE TABLE [dbo].[EventCategories] (
    [Category]     INT            CONSTRAINT [df_EvtCtgr_Category] DEFAULT ((0)) NOT NULL,
    [CategoryDesc] NVARCHAR (255) CONSTRAINT [df_EvtCtgr_CategoryDesc] DEFAULT ('') NOT NULL,
    CONSTRAINT [pk_EventCat_Category] PRIMARY KEY CLUSTERED ([Category] ASC)
);


GO

