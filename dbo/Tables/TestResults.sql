CREATE TABLE [dbo].[TestResults] (
    [TestResultId]           INT            NOT NULL,
    [EventIdDay]             INT            CONSTRAINT [df_TestResult_EventIdDay] DEFAULT ((0)) NOT NULL,
    [EventIdFraction]        INT            CONSTRAINT [df_TestResult_EventIdFraction] DEFAULT ((0)) NOT NULL,
    [BlockKey]               INT            CONSTRAINT [df_TestResult_BlockKey] DEFAULT ((0)) NOT NULL,
    [TechnicianId]           INT            NULL,
    [WorkOrder]              NVARCHAR (50)  NULL,
    [ServiceId]              INT            NULL,
    [TestEquipmentId1]       INT            CONSTRAINT [df_TestResult_TestEqId1] DEFAULT ((-1)) NOT NULL,
    [TestEquipmentId2]       INT            CONSTRAINT [df_TestResult_TestEqId2] DEFAULT ((-1)) NOT NULL,
    [TestEquipmentId3]       INT            CONSTRAINT [df_TestResult_TestEqId3] DEFAULT ((-1)) NOT NULL,
    [TestEquipmentId4]       INT            CONSTRAINT [df_TestResult_TestEqId4] DEFAULT ((-1)) NOT NULL,
    [TemperatureStd]         INT            NULL,
    [AmbientTemperature]     REAL           CONSTRAINT [df_TestResult_AmbientTemp] DEFAULT ((0.0)) NOT NULL,
    [AmbientTemperatureUnit] INT            CONSTRAINT [df_TestResult_AmbientTempUnit] DEFAULT ((0)) NOT NULL,
    [NotificationLimit]      REAL           CONSTRAINT [df_TestResult_NotificationLimit] DEFAULT ((0.0)) NOT NULL,
    [AdjustmentLimit]        REAL           CONSTRAINT [df_TestResult_AdjustmentLimit] DEFAULT ((0.0)) NOT NULL,
    [MaxErrorLimit]          REAL           CONSTRAINT [df_TestResult_MaxErrorLimit] DEFAULT ((0.0)) NOT NULL,
    [ZeroErrorLimit]         REAL           CONSTRAINT [df_TestResult_ZeroErrorLimit] DEFAULT ((0.0)) NOT NULL,
    [SpanErrorLimit]         REAL           CONSTRAINT [df_TestResult_SpanErrorLimit] DEFAULT ((0.0)) NOT NULL,
    [LinearityErrorLimit]    REAL           CONSTRAINT [df_TestResult_LinearityErrorLimit] DEFAULT ((0.0)) NOT NULL,
    [HysteresisErrorLimit]   REAL           CONSTRAINT [df_TestResult_HysteresisErrorLimit] DEFAULT ((0.0)) NOT NULL,
    [UseZeroError]           BIT            CONSTRAINT [df_TestResult_UseZeroError] DEFAULT ((0)) NOT NULL,
    [UseSpanError]           BIT            CONSTRAINT [df_TestResult_UseSpanError] DEFAULT ((0)) NOT NULL,
    [UseLinearityError]      BIT            CONSTRAINT [df_TestResult_UseLinearityError] DEFAULT ((0)) NOT NULL,
    [UseHysteresisError]     BIT            CONSTRAINT [df_TestResult_UseHysteresisError] DEFAULT ((0)) NOT NULL,
    [ServiceNote]            NVARCHAR (255) NULL,
    [Type]                   INT            CONSTRAINT [df_TestResult_Type] DEFAULT ((99)) NOT NULL,
    [TestResultData]         NVARCHAR (MAX) NULL,
    CONSTRAINT [pk_TestResults] PRIMARY KEY CLUSTERED ([TestResultId] ASC),
    CONSTRAINT [fk_TestResults_EventId] FOREIGN KEY ([EventIdDay], [EventIdFraction]) REFERENCES [dbo].[EventLog] ([EventIdDay], [EventIdFraction]),
    CONSTRAINT [fk_TestResults_ServiceId] FOREIGN KEY ([ServiceId]) REFERENCES [dbo].[ServiceReasons] ([ServiceId]),
    CONSTRAINT [fk_TestResults_TechId] FOREIGN KEY ([TechnicianId]) REFERENCES [dbo].[Users] ([UserKey])
);


GO

