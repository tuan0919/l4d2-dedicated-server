forward Tuan_OnClient_SelfRevived(int client);
forward Tuan_OnClient_KillOther(int client, int other);
forward Tuan_OnClient_IncapacitatedOther(int client, int victim);
forward Tuan_OnClient_HealedOther(int client, int victim);
forward Tuan_OnClient_UsedThrowable(int client, int victim);
forward Tuan_OnClient_BilejarOthers(int client, int[] victims);
forward Tuan_OnClient_GiveWeapon(int client, int target, char[] item);
forward Tuan_OnClient_SwapWeapon(int client, int target, char[] prevItem, char[] curItem);