//
//  AppDelegate.m
//  ProPresenter Creator
//
//  Created by Jason Terhorst on 10/6/14.
//  Copyright (c) 2014 Jason Terhorst. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "AppDelegate.h"

#import "ZipArchive.h"

CGFloat kxTitleFontSize = 117.0f;
CGFloat kxRegularFontSize = 108.0f;
NSInteger kxSlideWidth = 2560;
NSInteger kxSlideHeight = 1440;

CGFloat parkwayTitleFontSize = 50.0f;
CGFloat parkwayRegularFontSize = 45.0f;
NSInteger parkwaySlideWidth = 1024;
NSInteger parkwaySlideHeight = 768;

CGFloat lowerTitleFontSize = 117.0f;
CGFloat lowerRegularFontSize = 108.0f;
NSInteger lowerSlideWidth = 2560;
NSInteger lowerSlideHeight = 1440;

typedef enum {
	KnoxvilleSlideStyle,
	ParkwaySlideStyle,
	LowerThirdSlideStyle
} SlideStyle;

@interface AppDelegate ()

@property (weak) IBOutlet NSView * saveView;
@property (weak) IBOutlet NSMatrix * saveSettingMatrix;

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField * nameField;
@property (weak) IBOutlet NSTableView * slidesTableView;

@property (weak) IBOutlet NSObjectController * documentController;
@property (weak) IBOutlet NSArrayController * slidesController;

- (IBAction)saveAction:(id)sender;

- (IBAction)addSlide:(id)sender;
- (IBAction)removeSlide:(id)sender;

- (IBAction)selectMediaFile:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {




	//[self _saveSlides];
}

- (void)awakeFromNib
{
	if (!_documentController.content)
	{
		[_documentController add:nil];
	}

	[_slidesController setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
}

- (NSString *)dataStringFromAttributedString:(NSAttributedString *)string
{
	NSData * titleDataBlob = [string RTFFromRange:NSMakeRange(0, string.length) documentAttributes:nil];
	NSString * titleData = [titleDataBlob base64EncodedStringWithOptions:0];
	return titleData;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (NSString *)_resultUpdatingTemplate:(NSString *)template withDictionary:(NSDictionary *)dict
{
	NSString * resultPayload = template;
	for (NSString * key in [dict allKeys])
	{
		resultPayload = [resultPayload stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:[dict valueForKey:key]];
	}

	return resultPayload;
}

- (void)_saveSlides
{
	NSSavePanel * documentSavePanel = [NSSavePanel savePanel];
	[documentSavePanel setAllowedFileTypes:@[@"pro5x"]];
	[documentSavePanel setAllowsOtherFileTypes:NO];
	[documentSavePanel setExtensionHidden:NO];
	[documentSavePanel setAccessoryView:_saveView];
	NSInteger saveResult = [documentSavePanel runModal];
	if (saveResult == NSOKButton)
	{
		NSMutableArray * slideArray = [NSMutableArray array];
		
		for (NSManagedObject * object in [_slidesController arrangedObjects])
		{
			NSMutableDictionary * slideDict = [NSMutableDictionary dictionary];
			if ([object valueForKey:@"type"])
				[slideDict setObject:[[object valueForKey:@"type"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"type"];
			if ([object valueForKey:@"text"])
				[slideDict setObject:[[object valueForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"text"];
			if ([object valueForKey:@"mediaPath"])
				[slideDict setObject:[[object valueForKey:@"mediaPath"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"path"];
			if ([object valueForKey:@"reference"])
				[slideDict setObject:[[object valueForKey:@"reference"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"reference"];
			[slideArray addObject:slideDict];
		}

		SlideStyle style = KnoxvilleSlideStyle;
		if (_saveSettingMatrix.selectedRow == 1)
		{
			style = ParkwaySlideStyle;
		}
		else if (_saveSettingMatrix.selectedRow == 2)
		{
			style = LowerThirdSlideStyle;
		}

		[self _saveSlidesFromArray:slideArray inStyle:style toURL:[documentSavePanel URL]];
	}
}

- (void)_saveSlidesFromArray:(NSArray *)slideArray inStyle:(SlideStyle)style toURL:(NSURL *)saveURL
{
	NSInteger slideWidth = kxSlideWidth;
	NSInteger slideHeight = kxSlideHeight;
	CGFloat titleFontSize = kxTitleFontSize;
	CGFloat regularFontSize = kxRegularFontSize;

	NSString * documentTemplatePath = [[NSBundle mainBundle] pathForResource:@"pro5document" ofType:@"slidetemplate"];
	NSString * titleTemplatePath = [[NSBundle mainBundle] pathForResource:@"title" ofType:@"slidetemplate"];
	NSString * scriptureTemplatePath = [[NSBundle mainBundle] pathForResource:@"scripture" ofType:@"slidetemplate"];

	if (style == ParkwaySlideStyle)
	{
		slideWidth = parkwaySlideWidth;
		slideHeight = parkwaySlideHeight;
		titleFontSize = parkwayTitleFontSize;
		regularFontSize = parkwayRegularFontSize;

		documentTemplatePath = [[NSBundle mainBundle] pathForResource:@"parkway_document" ofType:@"slidetemplate"];
		titleTemplatePath = [[NSBundle mainBundle] pathForResource:@"parkway_title" ofType:@"slidetemplate"];
		scriptureTemplatePath = [[NSBundle mainBundle] pathForResource:@"parkway_scripture" ofType:@"slidetemplate"];
	}
	else if (style == LowerThirdSlideStyle)
	{
		slideWidth = lowerSlideWidth;
		slideHeight = lowerSlideHeight;
		titleFontSize = lowerTitleFontSize;
		regularFontSize = lowerRegularFontSize;

		documentTemplatePath = [[NSBundle mainBundle] pathForResource:@"lower_document" ofType:@"slidetemplate"];
		titleTemplatePath = [[NSBundle mainBundle] pathForResource:@"lower_title" ofType:@"slidetemplate"];
		scriptureTemplatePath = [[NSBundle mainBundle] pathForResource:@"lower_scripture" ofType:@"slidetemplate"];
	}

	NSURL * resultingFileURL = saveURL;
	NSString * escapedDocumentTitle = (__bridge NSString *)(CFXMLCreateStringByEscapingEntities(NULL, (__bridge CFStringRef)([[[resultingFileURL path] lastPathComponent] stringByDeletingPathExtension]), NULL));
	NSString * documentTitle = [[[resultingFileURL path] lastPathComponent] stringByDeletingPathExtension];

	[[NSFileManager defaultManager] removeItemAtURL:resultingFileURL error:nil];

	NSString * xmlDocumentPath = [[[resultingFileURL path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pro5", documentTitle]];

	NSString *theZippedFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"z_sermon_archive.zip"];
	NSString * mediaDSStorePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"media"] stringByAppendingPathComponent:@".DS_Store"];
	[[NSFileManager defaultManager] createDirectoryAtPath:[mediaDSStorePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
	[@"" writeToFile:mediaDSStorePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

	ZipArchive * newZipFile = [[ZipArchive alloc] init];
	[newZipFile CreateZipFile2:theZippedFilePath Password:@""];

	[newZipFile addFileToZip:mediaDSStorePath newname:[documentTitle stringByAppendingPathComponent:@"media/.DS_Store"]];

	int slideIndex = 0;
	NSMutableArray * filePaths = [NSMutableArray array];
	NSMutableString * slideData = [NSMutableString string];
	for (NSDictionary * slide in slideArray)
	{
		NSMutableDictionary * replacements = [NSMutableDictionary dictionaryWithDictionary:@{@"document height":[NSString stringWithFormat:@"%ld", (long)slideHeight], @"document width":[NSString stringWithFormat:@"%ld", (long)slideWidth], @"uuid":[[NSUUID UUID] UUIDString], @"label":@"", @"index":[NSString stringWithFormat:@"%d", slideIndex]}];
		NSString * template = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blank_slide" ofType:@"slidetemplate"] encoding:NSUTF8StringEncoding error:nil];

		if ([[slide valueForKey:@"type"] isEqualToString:@"title"])
		{
			NSMutableParagraphStyle * titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
			[titleParagraphStyle setAlignment:NSCenterTextAlignment];
			NSAttributedString * titleString = [[NSAttributedString alloc] initWithString:[slide valueForKey:@"text"] attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont fontWithName:@"MyriadPro-Bold" size:titleFontSize], NSParagraphStyleAttributeName:titleParagraphStyle}];

			template = [NSString stringWithContentsOfFile:titleTemplatePath encoding:NSUTF8StringEncoding error:nil];
			[replacements setObject:[self dataStringFromAttributedString:titleString] forKey:@"rtf data"];

			NSString * slidePayload = [self _resultUpdatingTemplate:template withDictionary:replacements];
			[slideData appendString:slidePayload];

			slideIndex++;
		}
		else if ([[slide valueForKey:@"type"] isEqualToString:@"point"])
		{
			NSMutableParagraphStyle * titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
			[titleParagraphStyle setAlignment:NSCenterTextAlignment];
			NSAttributedString * titleString = [[NSAttributedString alloc] initWithString:[slide valueForKey:@"text"] attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont fontWithName:@"MyriadPro-Bold" size:regularFontSize], NSParagraphStyleAttributeName:titleParagraphStyle}];

			template = [NSString stringWithContentsOfFile:titleTemplatePath encoding:NSUTF8StringEncoding error:nil];
			[replacements setObject:[self dataStringFromAttributedString:titleString] forKey:@"rtf data"];

			NSString * slidePayload = [self _resultUpdatingTemplate:template withDictionary:replacements];
			[slideData appendString:slidePayload];

			slideIndex++;
		}
		else if ([[slide valueForKey:@"type"] isEqualToString:@"scripture"])
		{
			NSMutableCharacterSet * phraseCharacterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
//			[phraseCharacterSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
//			[phraseCharacterSet formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
			NSMutableArray * slideSentences = [NSMutableArray arrayWithArray:[[slide valueForKey:@"text"] componentsSeparatedByCharactersInSet:phraseCharacterSet]];
			NSInteger easyCharacterLimit = 200;
			NSInteger overflowCharacterLimit = 250;
			if (style == LowerThirdSlideStyle)
			{
				easyCharacterLimit = 98;
				overflowCharacterLimit = 105;
			}
			NSMutableArray * slideTextResults = [NSMutableArray array];

			while ([slideSentences count] > 0) {
				NSMutableString * textData = [NSMutableString string];
				while ([textData length] < easyCharacterLimit && [slideSentences firstObject]) {
					[textData appendString:[slideSentences firstObject]];
					[textData appendString:@" "];
					[slideSentences removeObjectAtIndex:0];
				}
				if ([slideSentences firstObject] && [[textData stringByAppendingString:[slideSentences firstObject]] length] <= overflowCharacterLimit)
				{
					[textData appendString:[slideSentences firstObject]];
					[textData appendString:@" "];
					[slideSentences removeObjectAtIndex:0];
				}
				if ([slideSentences count] == 1)
				{
					[textData appendString:[slideSentences firstObject]];
					[textData appendString:@" "];
					[slideSentences removeObjectAtIndex:0];
				}

				if ([textData length] > 0)
				{
					//NSLog(@"adding: %@", textData);
					[slideTextResults addObject:textData];
				}
			}

			for (NSString * slideText in slideTextResults)
			{
				NSLog(@"slide: %d, formatting: %@", slideIndex, slideText);
				NSMutableParagraphStyle * textParagraphStyle = [[NSMutableParagraphStyle alloc] init];
				[textParagraphStyle setAlignment:NSLeftTextAlignment];
				NSAttributedString * textString = [[NSAttributedString alloc] initWithString:slideText attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont fontWithName:@"MyriadPro-Bold" size:regularFontSize], NSParagraphStyleAttributeName:textParagraphStyle}];

				NSMutableParagraphStyle * referenceParagraphStyle = [[NSMutableParagraphStyle alloc] init];
				[referenceParagraphStyle setAlignment:NSRightTextAlignment];
				NSAttributedString * referenceString = [[NSAttributedString alloc] initWithString:[slide valueForKey:@"reference"] attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont fontWithName:@"MyriadPro-Regular" size:regularFontSize], NSParagraphStyleAttributeName:referenceParagraphStyle}];

				template = [NSString stringWithContentsOfFile:scriptureTemplatePath encoding:NSUTF8StringEncoding error:nil];
				[replacements setObject:[self dataStringFromAttributedString:textString] forKey:@"body rtf data"];
				[replacements setObject:[self dataStringFromAttributedString:referenceString] forKey:@"reference rtf data"];
				[replacements setObject:[NSString stringWithFormat:@"%d", slideIndex] forKey:@"index"];

				NSString * slidePayload = [self _resultUpdatingTemplate:template withDictionary:replacements];
				[slideData appendString:slidePayload];

				slideIndex++;
			}
		}
		else if ([[slide valueForKey:@"type"] isEqualToString:@"media"])
		{
			NSString * filePath = [slide valueForKey:@"path"];
			NSURL * fileURL = [NSURL fileURLWithPath:filePath];
			[newZipFile addFileToZip:filePath newname:[documentTitle stringByAppendingPathComponent:[@"media" stringByAppendingPathComponent:[fileURL path]]]];
			[filePaths addObject:filePath];

			template = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media_slide" ofType:@"slidetemplate"] encoding:NSUTF8StringEncoding error:nil];
			[replacements setObject:[fileURL absoluteString] forKey:@"media source"];
			[replacements setObject:[[filePath lastPathComponent] stringByDeletingPathExtension] forKey:@"media display name"];
			[replacements setObject:[[NSUUID UUID] UUIDString] forKey:@"media uuid"];

			NSString * slidePayload = [self _resultUpdatingTemplate:template withDictionary:replacements];
			[slideData appendString:slidePayload];

			slideIndex++;
		}
		else if ([[slide valueForKey:@"type"] isEqualToString:@"blank"])
		{
			NSString * slidePayload = [self _resultUpdatingTemplate:template withDictionary:replacements];
			[slideData appendString:slidePayload];

			slideIndex++;
		}
	}

	NSDateFormatter * sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

	[sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
	[sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
	[sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

	NSString * documentTemplate = [NSString stringWithContentsOfFile:documentTemplatePath encoding:NSUTF8StringEncoding error:nil];

	NSDictionary * replacements = @{@"document title":escapedDocumentTitle, @"document height":[NSString stringWithFormat:@"%ld", (long)slideHeight], @"document width":[NSString stringWithFormat:@"%ld", (long)slideWidth], @"date":[sRFC3339DateFormatter stringFromDate:[NSDate date]], @"group uuid":[[NSUUID UUID] UUIDString], @"slides":slideData};
	NSString * documentTest = [self _resultUpdatingTemplate:documentTemplate withDictionary:replacements];
	//NSString * documentTest = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"slidetemplate"] encoding:NSUTF8StringEncoding error:nil];

	NSError * error = nil;
	[documentTest writeToFile:xmlDocumentPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
	if (error)
	{
		[[NSAlert alertWithMessageText:@"Error while trying to save" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", [error localizedDescription]] runModal];
	}

	[newZipFile addFileToZip:xmlDocumentPath newname:[documentTitle stringByAppendingPathComponent:[xmlDocumentPath lastPathComponent]]];

	[newZipFile CloseZipFile2];

	[[NSFileManager defaultManager] removeItemAtPath:xmlDocumentPath error:nil];

	//NSLog(@"test: %@", documentTest);

	[[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:theZippedFilePath] toURL:resultingFileURL error:nil];
}

- (IBAction)addSlide:(id)sender;
{
	NSManagedObject * newSlide = [NSEntityDescription insertNewObjectForEntityForName:@"Slide" inManagedObjectContext:[self managedObjectContext]];
	NSInteger newIndex = [[_slidesController arrangedObjects] count];
	[newSlide setPrimitiveValue:@(newIndex) forKey:@"index"];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[_slidesController setSelectedObjects:@[newSlide]];
	});
}

- (IBAction)selectMediaFile:(id)sender
{
	NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];

	NSInteger openResult = [openPanel runModal];
	if (openResult == NSOKButton)
	{
		NSString * filePath = [[[openPanel URLs] firstObject] path];
		NSManagedObject * object = [[_slidesController selectedObjects] firstObject];
		[object setValue:filePath forKey:@"mediaPath"];
	}
}

- (IBAction)removeSlide:(id)sender;
{
	[_slidesController remove:nil];
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jterhorst.ProPresenter_Creator" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.jterhorst.ProPresenter_Creator"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ProPresenter_Creator" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"OSXCoreDataObjC.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }

	[self _saveSlides];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
