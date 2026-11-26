#include "jbsettings.h"
#include <libjailbreak/info.h>
#include <libjailbreak/jbroot.h>
#include <sys/stat.h>
#include <sys/sysctl.h>
#include <sys/time.h>
#include <unistd.h>

int jbsettings_get(const char *key, xpc_object_t *valueOut)
{
	if (!key)	return -1;

	if (!strcmp(key, "wxCompatibilityUsed")) {
		struct stat st;
		struct timeval bootTime;
		size_t bootTimeSize = sizeof(bootTime);
		bool used = false;
		if (stat(JBROOT_PATH("/.wx_compatibility_layer"), &st) == 0 &&
			sysctlbyname("kern.boottime", &bootTime, &bootTimeSize, NULL, 0) == 0) {
			used = st.st_mtimespec.tv_sec > bootTime.tv_sec ||
				(st.st_mtimespec.tv_sec == bootTime.tv_sec && st.st_mtimespec.tv_nsec > bootTime.tv_usec * 1000);
		}
		*valueOut = xpc_bool_create(used);
		return 0;
	}
	if (!strcmp(key, "markAppsAsDebugged")) {
		*valueOut = xpc_bool_create(jbsetting(markAppsAsDebugged));
		return 0;
	}
	else if (!strcmp(key, "jetsamMultiplier")) {
		*valueOut = xpc_double_create(jbsetting(jetsamMultiplier));
		return 0;
	}
	return -1;
}

int jbsettings_set(const char *key, xpc_object_t value)
{
	if (!key) return -1;
	if (!strcmp(key, "markAppsAsDebugged") && xpc_get_type(value) == XPC_TYPE_BOOL) {
		gSystemInfo.jailbreakSettings.markAppsAsDebugged = xpc_bool_get_value(value);
		return 0;
	}
	else if (!strcmp(key, "jetsamMultiplier") && xpc_get_type(value) == XPC_TYPE_DOUBLE) {
		gSystemInfo.jailbreakSettings.jetsamMultiplier = xpc_double_get_value(value);
		return 0;
	}
	return -1;
}
