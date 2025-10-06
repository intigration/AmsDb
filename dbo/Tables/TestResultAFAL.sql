CREATE TABLE [dbo].[TestResultAFAL] (
    [TestResultAFALId]      INT       CONSTRAINT [df_TestResAFAL_TestResultAFALId] DEFAULT ((0)) NOT NULL,
    [TestResultId]          INT       CONSTRAINT [df_TestResAFAL_TestResultId] DEFAULT ((0)) NOT NULL,
    [TestResultAFALType]    NCHAR (1) NOT NULL,
    [MaxError]              REAL      CONSTRAINT [df_TestResAFAL_MaxError] DEFAULT ((0.0)) NOT NULL,
    [ZeroError]             REAL      CONSTRAINT [df_TestResAFAL_ZeroError] DEFAULT ((0.0)) NOT NULL,
    [SpanError]             REAL      CONSTRAINT [df_TestResAFAL_SpanError] DEFAULT ((0.0)) NOT NULL,
    [LinearityError]        REAL      CONSTRAINT [df_TestResAFAL_LinearityError] DEFAULT ((0.0)) NOT NULL,
    [HysteresisError]       REAL      CONSTRAINT [df_TestResAFAL_HysteresisError] DEFAULT ((0.0)) NOT NULL,
    [InputLowerRangeValue]  REAL      CONSTRAINT [df_TestResAFAL_InputLowerRangeValue] DEFAULT ((0.0)) NOT NULL,
    [InputUpperRangeValue]  REAL      CONSTRAINT [df_TestResAFAL_InputUpperRangeValue] DEFAULT ((0.0)) NOT NULL,
    [InputRangeUnits]       INT       CONSTRAINT [df_TestResAFAL_InputRangeUnits] DEFAULT ((0)) NOT NULL,
    [OutputLowerRangeValue] REAL      CONSTRAINT [df_TestResAFAL_OutputLowerRangeValue] DEFAULT ((0.0)) NOT NULL,
    [OutputUpperRangeValue] REAL      CONSTRAINT [df_TestResAFAL_OutputUpperRangeValue] DEFAULT ((0.0)) NOT NULL,
    [OutputRangeUnits]      INT       CONSTRAINT [df_TestResAFAL_OutputRangeUnits] DEFAULT ((0)) NOT NULL,
    [Relationship]          INT       CONSTRAINT [df_TestResAFAL_Relationship] DEFAULT ((0)) NOT NULL,
    [NumberOfTestPoints]    TINYINT   CONSTRAINT [df_TestResAFAL_NumberOfTestPoints] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_TestResultAFAL] PRIMARY KEY CLUSTERED ([TestResultAFALId] ASC),
    CONSTRAINT [fk_TestResAFAL_TestResultId] FOREIGN KEY ([TestResultId]) REFERENCES [dbo].[TestResults] ([TestResultId])
);


GO

