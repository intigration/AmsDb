CREATE TABLE [dbo].[EventLog] (
    [EventIdDay]      INT             CONSTRAINT [df_EventLog_EventIdDay] DEFAULT ((0)) NOT NULL,
    [EventIdFraction] INT             CONSTRAINT [df_EventLog_EventIdFraction] DEFAULT ((0)) NOT NULL,
    [EventTime]       DATETIME        CONSTRAINT [df_EventLog_EventTime] DEFAULT ('01/01/1970') NOT NULL,
    [UserKey]         INT             CONSTRAINT [df_EventLog_UserKey] DEFAULT ((0)) NOT NULL,
    [ComputerId]      INT             CONSTRAINT [df_EventLog_ComputerId] DEFAULT ((0)) NOT NULL,
    [BlockKey]        INT             CONSTRAINT [df_EventLog_BlockKey] DEFAULT ((0)) NOT NULL,
    [EventCode]       INT             CONSTRAINT [df_EventLog_EventCode] DEFAULT ((0)) NOT NULL,
    [Source]          NVARCHAR (50)   NULL,
    [Type]            INT             CONSTRAINT [df_EventLog_Type] DEFAULT ((0)) NOT NULL,
    [Category]        INT             CONSTRAINT [df_EventLog_Category] DEFAULT ((0)) NOT NULL,
    [Description]     NVARCHAR (1024) NULL,
    [OtherBufLen]     INT             CONSTRAINT [df_EventLog_OtherBufLen] DEFAULT ((0)) NOT NULL,
    [Other]           NVARCHAR (255)  NULL,
    [Archived]        BIT             CONSTRAINT [df_EventLog_Archived] DEFAULT ((0)) NOT NULL,
    [MoreDetail]      NVARCHAR (MAX)  NULL,
    CONSTRAINT [pk_EventLog] PRIMARY KEY CLUSTERED ([EventIdDay] ASC, [EventIdFraction] ASC),
    CONSTRAINT [fk_EventLog_Category] FOREIGN KEY ([Category]) REFERENCES [dbo].[EventCategories] ([Category]),
    CONSTRAINT [fk_EventLog_UserKey] FOREIGN KEY ([UserKey]) REFERENCES [dbo].[Users] ([UserKey])
);


GO

CREATE NONCLUSTERED INDEX [IX_EventLog_UserKey]
    ON [dbo].[EventLog]([UserKey] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_EventLog_Category]
    ON [dbo].[EventLog]([Category] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_EventLog_BlockKey]
    ON [dbo].[EventLog]([BlockKey] ASC);


GO

