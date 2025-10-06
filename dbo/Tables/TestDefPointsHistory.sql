CREATE TABLE [dbo].[TestDefPointsHistory] (
    [TestDefinitionId] INT  NOT NULL,
    [EventIdDay]       INT  NOT NULL,
    [EventIdFraction]  INT  NOT NULL,
    [TestPointId]      INT  NOT NULL,
    [DefTestPoint]     REAL NOT NULL,
    [Type]             INT  CONSTRAINT [df_TestDefPtsHistory_Type] DEFAULT ((99)) NOT NULL,
    CONSTRAINT [pk_TestDefPointsHistory] PRIMARY KEY CLUSTERED ([TestDefinitionId] ASC, [TestPointId] ASC, [EventIdDay] ASC, [EventIdFraction] ASC, [Type] ASC),
    CONSTRAINT [TestDefinitionHistory_TestDefPointsHistory_FK1] FOREIGN KEY ([TestDefinitionId], [EventIdDay], [EventIdFraction]) REFERENCES [dbo].[TestDefinitionHistory] ([TestDefinitionId], [EventIdDay], [EventIdFraction])
);


GO

