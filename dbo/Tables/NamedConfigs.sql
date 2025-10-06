CREATE TABLE [dbo].[NamedConfigs] (
    [ConfigKey]   INT           NOT NULL,
    [AmsDevRevId] INT           CONSTRAINT [df_NamedConfig_AmsDevRevId] DEFAULT ((-1)) NOT NULL,
    [ConfigName]  NVARCHAR (50) CONSTRAINT [df_NamedConfig_ConfigName] DEFAULT ('') NOT NULL,
    [ConfigType]  NCHAR (1)     NULL,
    [UniversalId] INT           CONSTRAINT [df_NamedConfig_UniversalId] DEFAULT ((0)) NOT NULL,
    [H275]        BIT           CONSTRAINT [df_NamedConfig_H275] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_NamedConfig] PRIMARY KEY CLUSTERED ([ConfigKey] ASC),
    CONSTRAINT [fk_NamedConfig_AmsDevRevId] FOREIGN KEY ([AmsDevRevId]) REFERENCES [dbo].[DeviceRevisions] ([AmsDevRevId]),
    CONSTRAINT [NamedConfigs_UC1] UNIQUE NONCLUSTERED ([ConfigName] ASC)
);


GO

