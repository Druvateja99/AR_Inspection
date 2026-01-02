
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

extern void UnitySendMessage(const char* obj, const char* method, const char* msg);

@interface UnityFilePicker : NSObject <UIDocumentPickerDelegate>
@end

@implementation UnityFilePicker

+ (instancetype)shared {
    static UnityFilePicker* s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [UnityFilePicker new];
    });
    return s;
}

- (UIViewController*)topVC {
    UIViewController* root = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (root.presentedViewController) root = root.presentedViewController;
    return root;
}

- (void)pickGLBGLTF {
    NSArray<UTType*>* types = @[];
    if (@available(iOS 14.0, *)) {
        UTType* glb  = [UTType typeWithFilenameExtension:@"glb"];
        UTType* gltf = [UTType typeWithFilenameExtension:@"gltf"];
        NSMutableArray* t = [NSMutableArray array];
        if (glb)  [t addObject:glb];
        if (gltf) [t addObject:gltf];
        types = t;
    }

    // asCopy:YES = iOS will copy file into your app container (best for Unity)
    UIDocumentPickerViewController* picker =
        [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:types asCopy:YES];

    picker.delegate = self;
    picker.allowsMultipleSelection = NO;

    [[self topVC] presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentsAtURLs:(NSArray<NSURL*>*)urls {
    NSURL* url = urls.firstObject;
    if (!url) return;

    UnitySendMessage("RuntimeFilePicker", "OnPickedFile", url.absoluteString.UTF8String);
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController*)controller {
    UnitySendMessage("RuntimeFilePicker", "OnPickerCancelled", "");
}

@end

extern "C" {
    void PickGLBGLTF() {
        [[UnityFilePicker shared] pickGLBGLTF];
    }
}
