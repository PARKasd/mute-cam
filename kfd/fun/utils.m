//
//  utils.m
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/07/30.
//

#import <Foundation/Foundation.h>
#import "vnode.h"
#import "krw.h"
#import "helpers.h"

uint64_t createFolderAndRedirect(uint64_t vnode) {
    NSString *mntPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mounted"];
    [[NSFileManager defaultManager] removeItemAtPath:mntPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:mntPath withIntermediateDirectories:NO attributes:nil error:nil];
    uint64_t orig_to_v_data = funVnodeRedirectFolderFromVnode(mntPath.UTF8String, vnode);
    
    return orig_to_v_data;
}

uint64_t UnRedirectAndRemoveFolder(uint64_t orig_to_v_data) {
    NSString *mntPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mounted"];
    funVnodeUnRedirectFolder(mntPath.UTF8String, orig_to_v_data);
    [[NSFileManager defaultManager] removeItemAtPath:mntPath error:nil];
    
    return 0;
}

//- (void)createPlistAtURL:(NSURL *)url height:(NSInteger)height width:(NSInteger)width error:(NSError **)error {
//    NSDictionary *dictionary = @{
//        @"canvas_height": @(height),
//        @"canvas_width": @(width)
//    };
//    BOOL success = [dictionary writeToURL:url atomically:YES];
//    if (!success) {
//        NSDictionary *userInfo = @{
//            NSLocalizedDescriptionKey: @"Failed to write property list to URL.",
//            NSLocalizedFailureReasonErrorKey: @"Error occurred while writing the property list.",
//            NSFilePathErrorKey: url.path
//        };
//        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
//    }
//}
int createPlistAtPath(NSString *path, NSInteger height, NSInteger width) {
    NSDictionary *dictionary = @{
        @"canvas_height": @(height),
        @"canvas_width": @(width)
    };
    
    BOOL success = [dictionary writeToFile:path atomically:YES];
    if (!success) {
        printf("[-] Failed createPlistAtPath.\n");
        return -1;
    }
    
    return 0;
}
int gibmebarplist(NSString *path) {
    NSInteger type = 2556;
    NSDictionary *dictionary = @{
        @"ArtworkDeviceSubType": @(type)
    };
    
    BOOL success = [dictionary writeToFile:path atomically:YES];
    if (!success) {
        printf("[-] Failed createPlistAtPath.\n");
        return -1;
    }
    
    return 0;
}
/**
int CardChange(void){
    uint64_t var_vnode = getVnodeVar();
    uint64_t var_tmp_vnode = findChildVnodeByVnode(var_vnode, "tmp");
    uint64_t orig_to_v_data = createFolderAndRedirect(var_tmp_vnode);
    printf("test");
    NSString *mntPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mounted"];
    NSString *source =  [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/cardBackgroundCombined@2x.png"];
    [[NSFileManager defaultManager] copyItemAtURL:source toURL:mntPath error:nil];
    UnRedirectAndRemoveFolder(orig_to_v_data);
    uint64_t preferences_vnode = getVnodeLibrary();
    orig_to_v_data = createFolderAndRedirect(preferences_vnode);

    remove([mntPath stringByAppendingString:@"/cardBackgroundCombined@2x.png"].UTF8String);
    printf("symlink ret: %d\n", symlink("/var/mobile/Library/Passes/Cards/.pkpass/cardBackgroundCombined@2x.png", [mntPath stringByAppendingString:@"/cardBackgroundCombined@2x.png"].UTF8String));
    UnRedirectAndRemoveFolder(orig_to_v_data);
    funVnodeHide("/var/mobile/Library/Passes/Cards/.cache");
    do_kclose();
    sleep(1);
    return 0;
}
 **/
int CardChange(void){
    funVnodeOverwriteFile("/var/mobile/Library/Passes/Cards/.pkpass/cardBackgroundCombined@2x.png",  [NSString stringWithFormat:@"%@%@", NSBundle.mainBundle.bundlePath, @"/cardBackgroundCombined@2x.png"].UTF8String);
    funVnodeHide("/var/mobile/Library/Passes/Cards/.cache");
    return 0;
}

int ResSet16(void) {
    //1. Create /var/tmp/com.apple.iokit.IOMobileGraphicsFamily.plist
    uint64_t var_vnode = getVnodeVar();
    uint64_t var_tmp_vnode = findChildVnodeByVnode(var_vnode, "tmp");
    printf("[i] /var/tmp vnode: 0x%llx\n", var_tmp_vnode);
    uint64_t orig_to_v_data = createFolderAndRedirect(var_tmp_vnode);
    
    NSString *mntPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mounted"];
    
    //iPhone 14 Pro Max Resolution
    createPlistAtPath([mntPath stringByAppendingString:@"/com.apple.iokit.IOMobileGraphicsFamily.plist"], 2532, 1170);
    
    UnRedirectAndRemoveFolder(orig_to_v_data);
    
    
    //2. Create symbolic link /var/tmp/com.apple.iokit.IOMobileGraphicsFamily.plist -> /var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist
    uint64_t preferences_vnode = getVnodePreferences();
    orig_to_v_data = createFolderAndRedirect(preferences_vnode);

    remove([mntPath stringByAppendingString:@"/com.apple.iokit.IOMobileGraphicsFamily.plist"].UTF8String);
    printf("symlink ret: %d\n", symlink("/var/tmp/com.apple.iokit.IOMobileGraphicsFamily.plist", [mntPath stringByAppendingString:@"/com.apple.iokit.IOMobileGraphicsFamily.plist"].UTF8String));
    UnRedirectAndRemoveFolder(orig_to_v_data);
    
    //3. xpc restart
    do_kclose();
    sleep(1);
    xpc_crasher("com.apple.cfprefsd.daemon");
    xpc_crasher("com.apple.backboard.TouchDeliveryPolicyServer");
    xpc_crasher("com.apple.mobilegestalt.xpc");

    return 0;
}

int gibmebar(void) {
    //CREATE TMP MOUNT POINT
    uint64_t var_vnode = getVnodeVar();
    uint64_t var_tmp_vnode = findChildVnodeByVnode(var_vnode, "tmp");
    printf("[i] /var/tmp vnode: 0x%llx\n", var_tmp_vnode);
    uint64_t orig_to_v_data = createFolderAndRedirect(var_tmp_vnode);
    

   // uint64_t orig_to_v_data61 = createFolderAndRedirect(var_tmp_vnode);
    printf("[i] mounting...");
    NSString *mntPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mounted"];
//mod it
    printf("[i] modding...");
    gibmebarplist([mntPath stringByAppendingString:@"/com.apple.MobileGestalt.plist"]);
//umount here
    printf("[i] unmounting..");
    UnRedirectAndRemoveFolder(orig_to_v_data);
    //   ///FIND VNODE
       printf("[i] gibmebar");
       uint64_t var_tmp_vnode2 = findChildVnodeByVnode(var_vnode, "containers");
      printf("[i] /var/containers vnode: 0x%llx\n", var_tmp_vnode2);

      uint64_t shared_tmp_vnode = findChildVnodeByVnode(var_tmp_vnode2, "Shared");
       printf("[i] /var/containers/Shared vnode: 0x%llx\n", shared_tmp_vnode);
   
       uint64_t SystemGroup = findChildVnodeByVnode(shared_tmp_vnode, "SystemGroup");
      printf("[i] /var/containers/SystemGroup vnode: 0x%llx\n", SystemGroup);

      uint64_t SystemGroup2 = findChildVnodeByVnode(SystemGroup, "systemgroup.com.apple.mobilegestaltcache");
      printf("[i] /var/containers/SystemGroup/systemgroup.com.apple.mobilegestaltcache vnode: 0x%llx\n", SystemGroup2);

       uint64_t SystemGroup3 = findChildVnodeByVnode(SystemGroup2, "Library");
       printf("[i] /var/containers/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library vnode: 0x%llx\n", SystemGroup3);
    uint64_t SystemGroup4 = findChildVnodeByVnode(SystemGroup3, "Caches");
    printf("[i] /var/containers/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library vnode: 0x%llx\n", SystemGroup3);


//mount the real one
    printf("[i] mounting real vnode...");

    orig_to_v_data = createFolderAndRedirect(SystemGroup4);
//rm
    
    remove([mntPath stringByAppendingString:@"/com.apple.MobileGestalt.plist"].UTF8String);
    printf("symlink ret: %d\n", symlink("/var/tmp/com.apple.MobileGestalt.plist", [mntPath stringByAppendingString:@"/com.apple.MobileGestalt.plist"].UTF8String));
    UnRedirectAndRemoveFolder(orig_to_v_data);
    
    //3. xpc restart
    do_kclose();
    sleep(1);
   xpc_crasher("com.apple.mobilegestalt.xpc");
  //  xpc_crasher("com.apple.cfprefsd.daemon");
    xpc_crasher("com.apple.frontboard.systemappservices");
    xpc_crasher("com.apple.backboard.TouchDeliveryPolicyServer");
    return 0;
}




int removeSMSCache(void) {
    uint64_t library_vnode = getVnodeLibrary();
    uint64_t sms_vnode = findChildVnodeByVnode(library_vnode, "Passes");
    
    //find Card vnode, it will hang some seconds. To reduce trycount, open Message and close, and try again. / or go home and back app.
    int trycount = 0;
    while(1) {
        if(sms_vnode != 0)
            break;
        sms_vnode = findChildVnodeByVnode(library_vnode, "Passes");
        trycount++;
    }
    printf("[i] /var/mobile/Library/SMS vnode: 0x%llx, trycount: %d\n", sms_vnode, trycount);
    
    uint64_t orig_to_v_data = createFolderAndRedirect(sms_vnode);
    
    NSString *mntPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mounted"];
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mntPath error:NULL];
    NSLog(@"/var/mobile/Library/SMS directory list: %@", dirs);
    
    remove([mntPath stringByAppendingString:@"/com.apple.messages.geometrycache_v7.plist"].UTF8String);
    
    dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mntPath error:NULL];
    NSLog(@"/var/mobile/Library/SMS directory list: %@", dirs);
    
    UnRedirectAndRemoveFolder(orig_to_v_data);
    
    return 0;
}

int VarMobileWriteTest(void) {
    uint64_t var_mobile_vnode = getVnodeVarMobile();
    
    uint64_t orig_to_v_data = createFolderAndRedirect(var_mobile_vnode);
    
    NSString *mntPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mounted"];
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mntPath error:NULL];
    NSLog(@"/var/mobile directory list: %@", dirs);
    
    //create
    [@"PLZ_GIVE_ME_GIRLFRIENDS!@#" writeToFile:[mntPath stringByAppendingString:@"/can_i_remove_file"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mntPath error:NULL];
    NSLog(@"/var/mobile directory list: %@", dirs);
    
    UnRedirectAndRemoveFolder(orig_to_v_data);
    
    return 0;
}

int VarMobileRemoveTest(void) {
    uint64_t var_mobile_vnode = getVnodeVarMobile();
    
    uint64_t orig_to_v_data = createFolderAndRedirect(var_mobile_vnode);
    
    NSString *mntPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mounted"];
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mntPath error:NULL];
    NSLog(@"/var/mobile directory list: %@", dirs);
    
    //remove
    int ret = remove([mntPath stringByAppendingString:@"/can_i_remove_file"].UTF8String);
    printf("remove ret: %d\n", ret);
    
    dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mntPath error:NULL];
    NSLog(@"/var/mobile directory list: %@", dirs);
    
    UnRedirectAndRemoveFolder(orig_to_v_data);
    
    return 0;
}
