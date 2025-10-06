CREATE TABLE [dbo].[BlockAsgms] (
    [ExtBlockTagKey]     INT CONSTRAINT [df_BlockAsgms_ExtBlockTagKey] DEFAULT ((0)) NOT NULL,
    [BlockKey]           INT CONSTRAINT [df_BlockAsgms_BlockKey] DEFAULT ((0)) NOT NULL,
    [EventIdDayOut]      INT CONSTRAINT [df_BlockAsgms_EventIdDayOut] DEFAULT ((0)) NOT NULL,
    [EventIdFractionOut] INT CONSTRAINT [df_BlockAsgms_EventIdFractionOut] DEFAULT ((0)) NOT NULL,
    [EventIdDayIn]       INT CONSTRAINT [df_BlockAsgms_EventIdDayIn] DEFAULT ((0)) NOT NULL,
    [EventIdFractionIn]  INT CONSTRAINT [df_BlockAsgms_EventIdFractionIn] DEFAULT ((0)) NOT NULL,
    [Archived]           BIT CONSTRAINT [df_BlockAsgms_Archived] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_BlockAsgms] PRIMARY KEY CLUSTERED ([ExtBlockTagKey] ASC, [BlockKey] ASC, [EventIdDayOut] ASC, [EventIdFractionOut] ASC),
    CONSTRAINT [fk_BlockAsgms_BlockKey] FOREIGN KEY ([BlockKey]) REFERENCES [dbo].[Blocks] ([BlockKey]),
    CONSTRAINT [fk_BlockAsgms_EventIdOut] FOREIGN KEY ([EventIdDayOut], [EventIdFractionOut]) REFERENCES [dbo].[EventLog] ([EventIdDay], [EventIdFraction]),
    CONSTRAINT [fk_BlockAsgms_ExtBlockTagKey] FOREIGN KEY ([ExtBlockTagKey]) REFERENCES [dbo].[ExtBlockTags] ([ExtBlockTagKey])
);


GO

CREATE NONCLUSTERED INDEX [IX_BlockAsgms_ExtBlockTagKey]
    ON [dbo].[BlockAsgms]([ExtBlockTagKey] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_BlockAsgms_BlockKey]
    ON [dbo].[BlockAsgms]([BlockKey] ASC);


GO

