// Made by The_Cookie_Monster#1959, initial version by ActuallyOutput#0411

state("Mobility")
{ // thanks to https://gist.github.com/just-ero/9f21152d9b3982cee3bc522d3114a633
	double IGT: "Mobility.exe", 0x5AAB08, 0x2C, 0x10, 0x3B4, 0x3F0;
	int room_id: "Mobility.exe", 0x7C50E8;
}

startup
{
	// array of room_ids which are gameplay levels
	int[] levelsArray = new int[] {11, 12, 13, 14, 15, 16, 22, 23, 24, 25, 26, 27, 32, 33, 34, 35, 36, 37, 38, 39, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58};
	vars.levelsList = new List<int>(levelsArray); // store as List<int> so we can use Contains method
	
	settings.Add("onlyLevels", false, "Only split when exiting levels");
	settings.SetToolTip("onlyLevels", "Will only split when moving from a gameplay level to a hub room, rather than when exiting any room");
}

init
{
	refreshRate = 30; // game runs at 30fps
}

isLoading
{
	return true; // pause timer when IGT isn't updating, thanks Jujstme
}

start
{
	if (old.IGT == 0.0 && current.IGT > 0.0) { // IGT used to be 0 (new file) but isn't anymore
		print("started");
		return true;
	}
}

reset
{
	if (current.IGT == 0.0 && old.IGT > 0.0) { // IGT is 0 (new file) but didn't used to be
		print("reset");
		return true;
	}
}

gameTime
{
	return TimeSpan.FromSeconds(current.IGT);
}

split
{
	if (current.room_id != old.room_id) { // changed room
		if (current.room_id != 1 && old.room_id != 1) { // room_id 1 is main menu
			if (settings["onlyLevels"]) { // "Only split when exiting levels" setting is enabled
				bool cameFromLevel = vars.levelsList.Contains(old.room_id);
				if (!cameFromLevel) { // room we came from is not a level
					print("exited " + old.room_id + " which is not a level");
					return false;
				}
				else {
					print("exited " + old.room_id + " which is a level");
				}
			}
			print("split (moved from room " + old.room_id + " to room " + current.room_id + ")");
			return true;
		} else { // don't split on navigating to or from main menu
			print("entered or exited main menu");
		}
	}
}
