//
//  DeviceHardware.m
//

#import "DeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#define DH_MACHINE_IPHONE_1_1 @"iPhone1,1"
#define DH_MACHINE_IPHONE_1_2 @"iPhone1,2"
#define DH_MACHINE_IPHONE_2_1 @"iPhone2,1"
#define DH_MACHINE_IPHONE_3_1 @"iPhone3,1"
#define DH_MACHINE_IPHONE_3_3 @"iPhone3,3"
#define DH_MACHINE_IPHONE_4_1 @"iPhone4,1"
#define DH_MACHINE_IPHONE_5_1 @"iPhone5,1"
#define DH_MACHINE_IPHONE_5_2 @"iPhone5,2"
#define DH_MACHINE_IPHONE_5_3 @"iPhone5,3"
#define DH_MACHINE_IPHONE_5_4 @"iPhone5,4"
#define DH_MACHINE_IPHONE_6_1 @"iPhone6,1"
#define DH_MACHINE_IPHONE_6_2 @"iPhone6,2"
#define DH_MACHINE_IPHONE_7_1 @"iPhone7,1"
#define DH_MACHINE_IPHONE_7_2 @"iPhone7,2"
#define DH_MACHINE_IPOD_1_1 @"iPod1,1"
#define DH_MACHINE_IPOD_2_1 @"iPod2,1"
#define DH_MACHINE_IPOD_3_1 @"iPod3,1"
#define DH_MACHINE_IPOD_4_1 @"iPod4,1"
#define DH_MACHINE_IPOD_5_1 @"iPod5,1"
#define DH_MACHINE_IPAD_1_1 @"iPad1,1"
#define DH_MACHINE_IPAD_2_1 @"iPad2,1"
#define DH_MACHINE_IPAD_2_2 @"iPad2,2"
#define DH_MACHINE_IPAD_2_3 @"iPad2,3"
#define DH_MACHINE_IPAD_2_4 @"iPad2,4"
#define DH_MACHINE_IPAD_2_5 @"iPad2,5"
#define DH_MACHINE_IPAD_2_6 @"iPad2,6"
#define DH_MACHINE_IPAD_2_7 @"iPad2,7"
#define DH_MACHINE_IPAD_3_1 @"iPad3,1"
#define DH_MACHINE_IPAD_3_2 @"iPad3,2"
#define DH_MACHINE_IPAD_3_3 @"iPad3,3"
#define DH_MACHINE_IPAD_3_4 @"iPad3,4"
#define DH_MACHINE_IPAD_3_5 @"iPad3,5"
#define DH_MACHINE_IPAD_3_6 @"iPad3,6"
#define DH_MACHINE_IPAD_4_1 @"iPad4,1"
#define DH_MACHINE_IPAD_4_2 @"iPad4,2"
#define DH_MACHINE_IPAD_4_4 @"iPad4,4"
#define DH_MACHINE_IPAD_4_5 @"iPad4,5"
#define DH_MACHINE_I386   @"i386"
#define DH_MACHINE_X86_64 @"x86_64"

@implementation DeviceHardware

+ (DeviceHardwareSpecificPlatform)specificPlatform {
	NSString *platform = [self machine];
	if ([platform isEqualToString:DH_MACHINE_IPHONE_1_1])    return DeviceHardwareSpecificPlatform_iPhone_1G;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_1_2])    return DeviceHardwareSpecificPlatform_iPhone_3G;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_2_1])    return DeviceHardwareSpecificPlatform_iPhone_3GS;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_3_1])    return DeviceHardwareSpecificPlatform_iPhone_4;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_3_3])    return DeviceHardwareSpecificPlatform_iPhone_4_Verizon;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_4_1])    return DeviceHardwareSpecificPlatform_iPhone_4S;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_1])    return DeviceHardwareSpecificPlatform_iPhone_5_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_2])    return DeviceHardwareSpecificPlatform_iPhone_5_CDMA_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_3])    return DeviceHardwareSpecificPlatform_iPhone_5C_CDMA_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_4])    return DeviceHardwareSpecificPlatform_iPhone_5C_Global;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_6_1])    return DeviceHardwareSpecificPlatform_iPhone_5S_CDMA_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_6_2])    return DeviceHardwareSpecificPlatform_iPhone_5S_Global;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_7_1])    return DeviceHardwareSpecificPlatform_iPhone_6_Plus_CDMA_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_7_2])    return DeviceHardwareSpecificPlatform_iPhone_6_CDMA_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPOD_1_1])      return DeviceHardwareSpecificPlatform_iPod_Touch_1G;
	if ([platform isEqualToString:DH_MACHINE_IPOD_2_1])      return DeviceHardwareSpecificPlatform_iPod_Touch_2G;
	if ([platform isEqualToString:DH_MACHINE_IPOD_3_1])      return DeviceHardwareSpecificPlatform_iPod_Touch_3G;
	if ([platform isEqualToString:DH_MACHINE_IPOD_4_1])      return DeviceHardwareSpecificPlatform_iPod_Touch_4G;
	if ([platform isEqualToString:DH_MACHINE_IPOD_5_1])      return DeviceHardwareSpecificPlatform_iPod_Touch_5G;
	if ([platform isEqualToString:DH_MACHINE_IPAD_1_1])      return DeviceHardwareSpecificPlatform_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_1])      return DeviceHardwareSpecificPlatform_iPad_2_WiFi;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_2])      return DeviceHardwareSpecificPlatform_iPad_2_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_3])      return DeviceHardwareSpecificPlatform_iPad_2_CDMA;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_4])      return DeviceHardwareSpecificPlatform_iPad_2_WiFi;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_5])      return DeviceHardwareSpecificPlatform_iPad_Mini_WiFi;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_6])      return DeviceHardwareSpecificPlatform_iPad_Mini_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_7])      return DeviceHardwareSpecificPlatform_iPad_Mini_CDMA_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_1])      return DeviceHardwareSpecificPlatform_iPad_3_WiFi;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_2])      return DeviceHardwareSpecificPlatform_iPad_3_CDMA;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_3])      return DeviceHardwareSpecificPlatform_iPad_3_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_4])      return DeviceHardwareSpecificPlatform_iPad_4_WiFi;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_5])      return DeviceHardwareSpecificPlatform_iPad_4_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_6])      return DeviceHardwareSpecificPlatform_iPad_4_CDMA_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_1])      return DeviceHardwareSpecificPlatform_iPad_Air_WiFi;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_2])      return DeviceHardwareSpecificPlatform_iPad_Air_CDMA_GSM;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_4])      return DeviceHardwareSpecificPlatform_iPad_Mini_Retina_WiFi;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_5])      return DeviceHardwareSpecificPlatform_iPad_Mini_Retina_CDMA_GSM;
	if ([platform isEqualToString:DH_MACHINE_I386])          return DeviceHardwareSpecificPlatform_Simulator;
	if ([platform isEqualToString:DH_MACHINE_X86_64])        return DeviceHardwareSpecificPlatform_Simulator;
	return DeviceHardwareSpecificPlatform_Unknown;
}

+ (DeviceHardwareGeneralPlatform)generalPlatform {
	NSString *platform = [self machine];
	if ([platform isEqualToString:DH_MACHINE_IPHONE_1_1])    return DeviceHardwareGeneralPlatform_iPhone_1G;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_1_2])    return DeviceHardwareGeneralPlatform_iPhone_3G;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_2_1])    return DeviceHardwareGeneralPlatform_iPhone_3GS;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_3_1])    return DeviceHardwareGeneralPlatform_iPhone_4;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_3_3])    return DeviceHardwareGeneralPlatform_iPhone_4;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_4_1])    return DeviceHardwareGeneralPlatform_iPhone_4S;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_1])    return DeviceHardwareGeneralPlatform_iPhone_5;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_2])    return DeviceHardwareGeneralPlatform_iPhone_5;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_3])    return DeviceHardwareGeneralPlatform_iPhone_5C;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_4])    return DeviceHardwareGeneralPlatform_iPhone_5C;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_6_1])    return DeviceHardwareGeneralPlatform_iPhone_5S;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_6_2])    return DeviceHardwareGeneralPlatform_iPhone_5S;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_7_1])    return DeviceHardwareGeneralPlatform_iPhone_6_Plus;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_7_2])    return DeviceHardwareGeneralPlatform_iPhone_6;
	if ([platform isEqualToString:DH_MACHINE_IPOD_1_1])      return DeviceHardwareGeneralPlatform_iPod_Touch_1G;
	if ([platform isEqualToString:DH_MACHINE_IPOD_2_1])      return DeviceHardwareGeneralPlatform_iPod_Touch_2G;
	if ([platform isEqualToString:DH_MACHINE_IPOD_3_1])      return DeviceHardwareGeneralPlatform_iPod_Touch_3G;
	if ([platform isEqualToString:DH_MACHINE_IPOD_4_1])      return DeviceHardwareGeneralPlatform_iPod_Touch_4G;
	if ([platform isEqualToString:DH_MACHINE_IPOD_5_1])      return DeviceHardwareGeneralPlatform_iPod_Touch_5G;
	if ([platform isEqualToString:DH_MACHINE_IPAD_1_1])      return DeviceHardwareGeneralPlatform_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_1])      return DeviceHardwareGeneralPlatform_iPad_2;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_2])      return DeviceHardwareGeneralPlatform_iPad_2;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_3])      return DeviceHardwareGeneralPlatform_iPad_2;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_4])      return DeviceHardwareGeneralPlatform_iPad_2;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_5])      return DeviceHardwareGeneralPlatform_iPad_Mini;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_6])      return DeviceHardwareGeneralPlatform_iPad_Mini;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_7])      return DeviceHardwareGeneralPlatform_iPad_Mini;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_1])      return DeviceHardwareGeneralPlatform_iPad_3;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_2])      return DeviceHardwareGeneralPlatform_iPad_3;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_3])      return DeviceHardwareGeneralPlatform_iPad_3;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_4])      return DeviceHardwareGeneralPlatform_iPad_4;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_5])      return DeviceHardwareGeneralPlatform_iPad_4;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_6])      return DeviceHardwareGeneralPlatform_iPad_4;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_1])      return DeviceHardwareGeneralPlatform_iPad_Air;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_2])      return DeviceHardwareGeneralPlatform_iPad_Air;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_4])      return DeviceHardwareGeneralPlatform_iPad_Mini_Retina;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_5])      return DeviceHardwareGeneralPlatform_iPad_Mini_Retina;
	if ([platform isEqualToString:DH_MACHINE_I386])          return DeviceHardwareGeneralPlatform_Simulator;
	if ([platform isEqualToString:DH_MACHINE_X86_64])        return DeviceHardwareGeneralPlatform_Simulator;
	return DeviceHardwareGeneralPlatform_Unknown;
}

+ (DeviceHardwarePlatformType)platformType {
	NSString *platform = [self machine];
	if ([platform isEqualToString:DH_MACHINE_IPHONE_1_1])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_1_2])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_2_1])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_3_1])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_3_3])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_4_1])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_1])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_2])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_3])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_4])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_6_1])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_6_2])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_7_1])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPHONE_7_2])    return DeviceHardwarePlatformType_iPhone;
	if ([platform isEqualToString:DH_MACHINE_IPOD_1_1])      return DeviceHardwarePlatformType_iPod_Touch;
	if ([platform isEqualToString:DH_MACHINE_IPOD_2_1])      return DeviceHardwarePlatformType_iPod_Touch;
	if ([platform isEqualToString:DH_MACHINE_IPOD_3_1])      return DeviceHardwarePlatformType_iPod_Touch;
	if ([platform isEqualToString:DH_MACHINE_IPOD_4_1])      return DeviceHardwarePlatformType_iPod_Touch;
	if ([platform isEqualToString:DH_MACHINE_IPOD_5_1])      return DeviceHardwarePlatformType_iPod_Touch;
	if ([platform isEqualToString:DH_MACHINE_IPAD_1_1])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_1])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_2])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_3])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_4])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_5])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_6])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_7])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_1])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_2])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_3])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_4])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_5])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_6])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_1])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_2])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_4])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_5])      return DeviceHardwarePlatformType_iPad;
	if ([platform isEqualToString:DH_MACHINE_I386])          return DeviceHardwarePlatformType_Simulator;
	if ([platform isEqualToString:DH_MACHINE_X86_64])        return DeviceHardwarePlatformType_Simulator;
	return DeviceHardwarePlatformType_Unknown;
}

+ (NSString *)platformString {
	NSString *platform = [self machine];
	if ([platform isEqualToString:DH_MACHINE_IPHONE_1_1])    return @"iPhone 1G";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_1_2])    return @"iPhone 3G";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_2_1])    return @"iPhone 3GS";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_3_1])    return @"iPhone 4";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_3_3])    return @"iPhone 4 (Verizon)";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_4_1])    return @"iPhone 4S";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_1])    return @"iPhone 5 (GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_2])    return @"iPhone 5 (CDMA+GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_3])    return @"iPhone 5C (CDMA+GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_5_4])    return @"iPhone 5C (Global)";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_6_1])    return @"iPhone 5S (CDMA+GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_6_2])    return @"iPhone 5S (Global)";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_7_1])    return @"iPhone 6 Plus (CDMA+GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPHONE_7_2])    return @"iPhone 6 (CDMA+GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPOD_1_1])      return @"iPod Touch 1G";
	if ([platform isEqualToString:DH_MACHINE_IPOD_2_1])      return @"iPod Touch 2G";
	if ([platform isEqualToString:DH_MACHINE_IPOD_3_1])      return @"iPod Touch 3G";
	if ([platform isEqualToString:DH_MACHINE_IPOD_4_1])      return @"iPod Touch 4G";
	if ([platform isEqualToString:DH_MACHINE_IPOD_5_1])      return @"iPod Touch 5G";
	if ([platform isEqualToString:DH_MACHINE_IPAD_1_1])      return @"iPad";
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_1])      return @"iPad 2 (WiFi)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_2])      return @"iPad 2 (GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_3])      return @"iPad 2 (CDMA)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_4])      return @"iPad 2 (WiFi)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_5])      return @"iPad Mini (WiFi)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_6])      return @"iPad Mini (GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_2_7])      return @"iPad Mini (CDMA+GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_1])      return @"iPad 3 (WiFi)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_2])      return @"iPad 3 (CDMA)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_3])      return @"iPad 3 (GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_4])      return @"iPad 4 (WiFi)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_5])      return @"iPad 4 (GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_3_6])      return @"iPad 4 (CDMA+GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_1])      return @"iPad Air (WiFi)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_2])      return @"iPad Air (CDMA+GSM)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_4])      return @"iPad Mini Retina (WiFi)";
	if ([platform isEqualToString:DH_MACHINE_IPAD_4_5])      return @"iPad Mini Retina (CDMA+GSM)";
	if ([platform isEqualToString:DH_MACHINE_I386])          return @"Simulator";
	if ([platform isEqualToString:DH_MACHINE_X86_64])        return @"Simulator";
	return platform;
}

+ (NSString *)machine {
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	return platform;
}

@end