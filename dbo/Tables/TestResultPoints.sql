CREATE TABLE [dbo].[TestResultPoints] (
    [TestResultAFALId]  INT  CONSTRAINT [df_TestResPts_TestResultAFALId] DEFAULT ((0)) NOT NULL,
    [TestResultPointId] INT  CONSTRAINT [df_TestResPts_TestResultPointId] DEFAULT ((0)) NOT NULL,
    [Input]             REAL CONSTRAINT [df_TestResPts_Input] DEFAULT ((0.0)) NOT NULL,
    [Output]            REAL CONSTRAINT [df_TestResPts_Output] DEFAULT ((0.0)) NOT NULL,
    [Error]             REAL CONSTRAINT [df_TestResPts_Error] DEFAULT ((0.0)) NOT NULL,
    CONSTRAINT [pk_TestResultPoints] PRIMARY KEY CLUSTERED ([TestResultAFALId] ASC, [TestResultPointId] ASC),
    CONSTRAINT [fk_TestResPts_TestResultAFALId] FOREIGN KEY ([TestResultAFALId]) REFERENCES [dbo].[TestResultAFAL] ([TestResultAFALId])
);


GO

CREATE NONCLUSTERED INDEX [IX_TestResultPoints_TestResultPointId]
    ON [dbo].[TestResultPoints]([TestResultPointId] ASC);


GO

