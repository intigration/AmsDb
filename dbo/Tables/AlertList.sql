CREATE TABLE [dbo].[AlertList] (
    [EventIdDay]      INT             NOT NULL,
    [EventIdFraction] INT             NOT NULL,
    [AlertTime]       DATETIME        NOT NULL,
    [BlockKey]        INT             NOT NULL,
    [SetCount]        INT             NOT NULL,
    [AlertId]         NVARCHAR (1024) NOT NULL,
    [AlertSource]     NVARCHAR (256)  NOT NULL,
    [AlertState]      INT             NOT NULL,
    [AckState]        INT             NOT NULL
);


GO

CREATE UNIQUE CLUSTERED INDEX [IX_AL_Clustered]
    ON [dbo].[AlertList]([BlockKey] ASC, [AlertId] ASC, [AlertSource] ASC) WITH (IGNORE_DUP_KEY = ON);


GO

