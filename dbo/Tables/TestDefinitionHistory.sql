CREATE TABLE [dbo].[TestDefinitionHistory] (
    [TestDefinitionId]        INT            NOT NULL,
    [EventIdDay]              INT            NOT NULL,
    [EventIdFraction]         INT            NOT NULL,
    [Name]                    NVARCHAR (255) NOT NULL,
    [Type]                    INT            NOT NULL,
    [DefCalibrationInterval]  INT            NOT NULL,
    [DefIntervalUnits]        INT            NOT NULL,
    [CriticalService]         INT            NOT NULL,
    [DefNotificationLimit]    REAL           NOT NULL,
    [DefAdjustmentLimit]      REAL           NOT NULL,
    [DefMaxErrorLimit]        REAL           NOT NULL,
    [DefZeroErrorLimit]       REAL           NOT NULL,
    [DefSpanErrorLimit]       REAL           NOT NULL,
    [DefLinearityErrorLimit]  REAL           NOT NULL,
    [DefHysteresisErrorLimit] REAL           NOT NULL,
    [DefUseZeroError]         INT            NOT NULL,
    [DefUseSpanError]         INT            NOT NULL,
    [DefUseLinearityError]    INT            NOT NULL,
    [DefUseHysteresisError]   INT            NOT NULL,
    [DefSetupInstructions]    NVARCHAR (255) NULL,
    [DefCleanupInstructions]  NVARCHAR (255) NULL,
    [DefCalPowerSource]       INT            NOT NULL,
    [DefCalGenerateInput]     INT            NOT NULL,
    [DefCalMeasureInput]      INT            NOT NULL,
    [DefCalMeasureOutput]     INT            NOT NULL,
    [DefNumberOfTestPoints]   INT            NOT NULL,
    [ProverMaterial]          NVARCHAR (255) CONSTRAINT [df_TestDefHistory_ProverMaterial] DEFAULT ('') NULL,
    CONSTRAINT [pk_TestDefinitionHistory] PRIMARY KEY CLUSTERED ([TestDefinitionId] ASC, [EventIdDay] ASC, [EventIdFraction] ASC),
    CONSTRAINT [EventLog_TestDefinitionHistory_FK1] FOREIGN KEY ([EventIdDay], [EventIdFraction]) REFERENCES [dbo].[EventLog] ([EventIdDay], [EventIdFraction]),
    CONSTRAINT [TestDefinition_TestDefinitionHistory_FK1] FOREIGN KEY ([TestDefinitionId]) REFERENCES [dbo].[TestDefinition] ([TestDefinitionId])
);


GO

