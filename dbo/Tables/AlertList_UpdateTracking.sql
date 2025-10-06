CREATE TABLE [dbo].[AlertList_UpdateTracking] (
    [AlertState]     NCHAR (10) CONSTRAINT [DF_AlertList_UpdateTracking_AlertState] DEFAULT (N'Active') NOT NULL,
    [UpdateCount]    INT        NOT NULL,
    [InitializeTime] DATETIME   CONSTRAINT [DF_AlertList_UpdateTracking_InitializeTime] DEFAULT (((1)/(1))/(1970)) NOT NULL,
    [LastUpdateTime] DATETIME   CONSTRAINT [DF_AlertList_UpdateTracking_LastUpdateTime] DEFAULT (((1)/(1))/(1970)) NOT NULL,
    [LastAddTime]    DATETIME   CONSTRAINT [DF_AlertList_UpdateTracking_LastAddTime] DEFAULT (((1)/(1))/(1970)) NOT NULL
);


GO

