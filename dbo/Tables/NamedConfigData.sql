CREATE TABLE [dbo].[NamedConfigData] (
    [ConfigKey]       INT            CONSTRAINT [df_NamedConfigData_ConfigKey] DEFAULT ((0)) NOT NULL,
    [EventIdDay]      INT            CONSTRAINT [df_NamedConfigData_EventIdDay] DEFAULT ((0)) NOT NULL,
    [EventIdFraction] INT            CONSTRAINT [df_NamedConfigData_EventIdFraction] DEFAULT ((0)) NOT NULL,
    [ParamKind]       NCHAR (1)      CONSTRAINT [df_NamedConfigData_ParamKind] DEFAULT ('P') NOT NULL,
    [ParamName]       NVARCHAR (255) NOT NULL,
    [ParamDataType]   SMALLINT       CONSTRAINT [df_NamedConfigData_ParamDataType] DEFAULT ((0)) NOT NULL,
    [ParamDataSize]   INT            CONSTRAINT [df_NamedConfigData_ParamDataSize] DEFAULT ((0)) NOT NULL,
    [ParamData]       VARCHAR (MAX)  NULL,
    [Archived]        BIT            CONSTRAINT [df_NamedConfigData_Archived] DEFAULT ((0)) NOT NULL,
    [BlockIndex]      INT            CONSTRAINT [df_NamedConfigData_BlockIndex] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_NamedConfigData] PRIMARY KEY CLUSTERED ([ConfigKey] ASC, [EventIdDay] ASC, [EventIdFraction] ASC, [ParamKind] ASC, [ParamName] ASC),
    CONSTRAINT [fk_NamedConfigData_ConfigKey] FOREIGN KEY ([ConfigKey]) REFERENCES [dbo].[NamedConfigs] ([ConfigKey]),
    CONSTRAINT [fk_NamedConfigData_EventId] FOREIGN KEY ([EventIdDay], [EventIdFraction]) REFERENCES [dbo].[EventLog] ([EventIdDay], [EventIdFraction])
);


GO

CREATE NONCLUSTERED INDEX [IX_NamedConfigData_ConfigKey]
    ON [dbo].[NamedConfigData]([ConfigKey] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_NamedConfigData_EventId]
    ON [dbo].[NamedConfigData]([EventIdDay] ASC, [EventIdFraction] ASC);


GO

