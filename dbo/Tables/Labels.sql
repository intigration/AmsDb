CREATE TABLE [dbo].[Labels] (
    [LabelId]   INT            CONSTRAINT [df_Labels_LabelId] DEFAULT ((0)) NOT NULL,
    [LabelName] NVARCHAR (255) NULL,
    CONSTRAINT [pk_Labels] PRIMARY KEY CLUSTERED ([LabelId] ASC)
);


GO

