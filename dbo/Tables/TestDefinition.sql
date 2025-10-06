CREATE TABLE [dbo].[TestDefinition] (
    [TestDefinitionId]        INT            NOT NULL,
    [Name]                    NVARCHAR (255) NOT NULL,
    [Type]                    INT            CONSTRAINT [df_TestDef_Type] DEFAULT ((99)) NOT NULL,
    [DefCalibrationInterval]  INT            CONSTRAINT [df_TestDef_DefCalibrationInterval] DEFAULT ((0)) NOT NULL,
    [DefIntervalUnits]        INT            CONSTRAINT [df_TestDef_DefIntervalUnits] DEFAULT ((0)) NOT NULL,
    [CriticalService]         INT            NOT NULL,
    [DefNotificationLimit]    REAL           CONSTRAINT [df_TestDef_DefNotificationLimit] DEFAULT ((0)) NOT NULL,
    [DefAdjustmentLimit]      REAL           CONSTRAINT [df_TestDef_DefAdjustmentLimit] DEFAULT ((0)) NOT NULL,
    [DefMaxErrorLimit]        REAL           CONSTRAINT [df_TestDef_DefMaxErrorLimit] DEFAULT ((0)) NOT NULL,
    [DefZeroErrorLimit]       REAL           CONSTRAINT [df_TestDef_DefZeroErrorLimit] DEFAULT ((0)) NOT NULL,
    [DefSpanErrorLimit]       REAL           CONSTRAINT [df_TestDef_DefSpanErrorLimit] DEFAULT ((0)) NOT NULL,
    [DefLinearityErrorLimit]  REAL           CONSTRAINT [df_TestDef_DefLinearityErrorLimit] DEFAULT ((0)) NOT NULL,
    [DefHysteresisErrorLimit] REAL           CONSTRAINT [df_TestDef_DefHystereisErrorLimit] DEFAULT ((0)) NOT NULL,
    [DefUseZeroError]         INT            CONSTRAINT [df_TestDef_DefUseZeroError] DEFAULT ((0)) NOT NULL,
    [DefUseSpanError]         INT            CONSTRAINT [df_TestDef_DefUseSpanError] DEFAULT ((0)) NOT NULL,
    [DefUseLinearityError]    INT            CONSTRAINT [df_TestDef_DefUseLinearityError] DEFAULT ((0)) NOT NULL,
    [DefUseHysteresisError]   INT            CONSTRAINT [df_TestDef_DefUseHysteresisError] DEFAULT ((0)) NOT NULL,
    [DefSetupInstructions]    NVARCHAR (255) NULL,
    [DefCleanupInstructions]  NVARCHAR (255) NULL,
    [DefCalPowerSource]       INT            CONSTRAINT [df_TestDef_DefCalPowerSource] DEFAULT ((0)) NOT NULL,
    [DefCalGenerateInput]     INT            CONSTRAINT [df_TestDef_DefCalGenerateInput] DEFAULT ((0)) NOT NULL,
    [DefCalMeasureInput]      INT            CONSTRAINT [df_TestDef_DefCalMeasureInput] DEFAULT ((0)) NOT NULL,
    [DefCalMeasureOutput]     INT            CONSTRAINT [df_TestDef_DefCalMeasureOutput] DEFAULT ((0)) NOT NULL,
    [DefNumberOfTestPoints]   INT            CONSTRAINT [df_TestDef_DefNumberOfTestPoints] DEFAULT ((0)) NOT NULL,
    [ProverMaterial]          NVARCHAR (255) CONSTRAINT [df_TestDef_ProverMaterial] DEFAULT ('') NULL,
    CONSTRAINT [pk_TestDefinition] PRIMARY KEY CLUSTERED ([TestDefinitionId] ASC),
    CONSTRAINT [IX_TestDefinitionName] UNIQUE NONCLUSTERED ([Name] ASC)
);


GO

