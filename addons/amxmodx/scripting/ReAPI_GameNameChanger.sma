#include <AMXModX>
#include <AMXMisc>
#include <ReAPI>

#pragma semicolon 1
#pragma compress 1

#define PluginName "Game Name Changer"
#define PluginVersion "1.0"
#define PluginAuthor "Ali 13"

const MaxValueLentgh = 32;

new const ConfigFile[] = "GameName.ini";
new const GameNameKey[] = "GAME_NAME";

new GetGameName[MaxValueLentgh];

public plugin_init()
{
	register_plugin(PluginName, PluginVersion, PluginAuthor);

	register_concmd("gnm_reload", "ConCmdReload", ADMIN_RCON, "-- Reloads The Configuration File");

	ReadConfigFile();
}

public ConCmdReload(id, Level, Cid)
{
	if(!cmd_access(id, Level, Cid, 1))
		return PLUGIN_HANDLED;

	ReadConfigFile();

	console_print(id, "[AMXX] Reload Successful !");

	return PLUGIN_HANDLED;
}

ReadConfigFile()
{
	new ConfigsDirectory[256];
	get_configsdir(ConfigsDirectory, charsmax(ConfigsDirectory));

	new FilePath[256];
	formatex(FilePath, charsmax(FilePath), "%s/%s", ConfigsDirectory, ConfigFile);
	
	if(!file_exists(FilePath) || !file_size(FilePath, FSOPT_BYTES_COUNT))
	{
		new FileUse;

		if((FileUse = fopen(FilePath, "wt")))
		{
			fprintf(FileUse, "; Game Name Changer^n");
			fprintf(FileUse, "; File location: $moddir/%s/%s^n", ConfigsDirectory, ConfigFile);
			fprintf(FileUse, "; Syntax^n; %s = Custom Name^n^n%s = My Awesome Name", GameNameKey, GameNameKey);

			fclose(FileUse);

			ReadConfigFile();
		}
		else
			set_fail_state("Failed To Create Config File : '%s'", ConfigFile);
	}
	else
	if(file_exists(FilePath) && file_size(FilePath, FSOPT_BYTES_COUNT))
	{
		new FileUse;

		if((FileUse = fopen(FilePath, "rt")))
		{
			new FileData[128], FileKey[10], KeyValue[MaxValueLentgh];

			while(!feof(FileUse))
			{
				fgets(FileUse, FileData, charsmax(FileData));
				
				trim(FileData);

				if(!FileData[0] || FileData[0] == EOS || FileData[0] == ';' || FileData[0] == '/' &&  FileData[1] == '/' || FileData[0] == '#')
					continue;

				strtok(FileData, FileKey, charsmax(FileKey), KeyValue, charsmax(KeyValue), '=');

				trim(FileKey);
				trim(KeyValue);

				if(equal(FileKey, GameNameKey))
					copy(GetGameName, charsmax(GetGameName), KeyValue);
			}

			fclose(FileUse);
		}
	}

	set_member_game(m_GameDesc, GetGameName);
}
