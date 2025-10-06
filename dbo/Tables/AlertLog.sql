CREATE TABLE [dbo].[AlertLog] (
    [EventIdDay]      INT             NOT NULL,
    [EventIdFraction] INT             NOT NULL,
    [AlertId]         NVARCHAR (1024) NOT NULL,
    [AlertTypeId]     SMALLINT        NOT NULL,
    CONSTRAINT [pk_AlertLog] PRIMARY KEY CLUSTERED ([EventIdDay] ASC, [EventIdFraction] ASC),
    CONSTRAINT [AlertTypes_AlertLog_FK1] FOREIGN KEY ([AlertTypeId]) REFERENCES [dbo].[AlertTypes] ([AlertTypeId]),
    CONSTRAINT [EventLog_AlertLog_FK1] FOREIGN KEY ([EventIdDay], [EventIdFraction]) REFERENCES [dbo].[EventLog] ([EventIdDay], [EventIdFraction])
);


GO

