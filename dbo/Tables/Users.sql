CREATE TABLE [dbo].[Users] (
    [UserKey]        INT            NOT NULL,
    [UserName]       NVARCHAR (50)  NOT NULL,
    [UserIdentifier] NVARCHAR (255) NULL,
    [SSOID]          NVARCHAR (300) NULL,
    CONSTRAINT [pk_User_UserKey] PRIMARY KEY CLUSTERED ([UserKey] ASC),
    CONSTRAINT [u_User_UserKey] UNIQUE NONCLUSTERED ([UserName] ASC)
);


GO

