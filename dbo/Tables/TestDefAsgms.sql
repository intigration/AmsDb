CREATE TABLE [dbo].[TestDefAsgms] (
    [ExtBlockTagKey]     INT NOT NULL,
    [TestDefinitionId]   INT NOT NULL,
    [EventIdDayOut]      INT NOT NULL,
    [EventIdFractionOut] INT NOT NULL,
    [EventIdDayIn]       INT NOT NULL,
    [EventIdFractionIn]  INT NOT NULL,
    CONSTRAINT [TestDefAsgms_PK] PRIMARY KEY CLUSTERED ([ExtBlockTagKey] ASC, [TestDefinitionId] ASC, [EventIdDayOut] ASC, [EventIdFractionOut] ASC),
    CONSTRAINT [EventLog_TestDefAsgms_FK1] FOREIGN KEY ([EventIdDayOut], [EventIdFractionOut]) REFERENCES [dbo].[EventLog] ([EventIdDay], [EventIdFraction]),
    CONSTRAINT [ExtBlockTags_TestDefAsgms_FK1] FOREIGN KEY ([ExtBlockTagKey]) REFERENCES [dbo].[ExtBlockTags] ([ExtBlockTagKey]),
    CONSTRAINT [TestDefinition_TestDefAsgms_FK1] FOREIGN KEY ([TestDefinitionId]) REFERENCES [dbo].[TestDefinition] ([TestDefinitionId])
);


GO

