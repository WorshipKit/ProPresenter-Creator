//
//  AppDelegate.m
//  ProPresenter Creator
//
//  Created by Jason Terhorst on 10/6/14.
//  Copyright (c) 2014 Jason Terhorst. All rights reserved.
//

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

typedef enum {
	KnoxvilleSlideStyle,
	ParkwaySlideStyle,
} SlideStyle;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
- (IBAction)saveAction:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

//	NSString * rtfTestData = @"e1xydGYxXGFuc2lcYW5zaWNwZzEyNTJcY29jb2FydGYxMzI4XGNvY29hc3VicnRmMTEwClxjb2NvYXNjcmVlbmZvbnRzMXtcZm9udHRibFxmMFxmbmlsXGZjaGFyc2V0MCBNeXJpYWRQcm8tUmVndWxhcjt9CntcY29sb3J0Ymw7XHJlZDI1NVxncmVlbjI1NVxibHVlMjU1O30KXHBhcmRcdHg1NjBcdHgxMTIwXHR4MTY4MFx0eDIyNDBcdHgyODAwXHR4MzM2MFx0eDM5MjBcdHg0NDgwXHR4NTA0MFx0eDU2MDBcdHg2MTYwXHR4NjcyMFxwYXJkaXJuYXR1cmFsXHFjCgpcZjBcYlxmczExOCBcY2YxIFRyYW5zY2VuZGVuY2VcCgpcYjAgV2h5IGlzIEdvZCBzbyBkaXN0YW50P30=";
//	NSData * data = [[NSData alloc] initWithBase64EncodedString:rtfTestData options:0];
//	NSAttributedString * attributedString = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentOption:NSRTFTextDocumentType} documentAttributes:NULL error:nil];
//	NSLog(@"document: %@", [attributedString string]);

    NSMutableArray * slideArray = [NSMutableArray array];
    [slideArray addObject:@{@"type":@"blank"}];
	[slideArray addObject:@{@"type":@"media", @"path":@"/Users/jterhorst/Dropbox/Sermon slide pro5 files/generous-life-widescreen.png"}];
	[slideArray addObject:@{@"type":@"title", @"text":@"Shake it off"}];
	[slideArray addObject:@{@"type":@"point", @"text":@"Haters gonna hate hate hate hate"}];
//	NSAttributedString * scriptureString = [[NSAttributedString alloc] initWithString:@"Testing scripture text body." attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont boldSystemFontOfSize:45]}];
//	NSAttributedString * referenceString = [[NSAttributedString alloc] initWithString:@"Scripture 3:16 (NIV)" attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont systemFontOfSize:45]}];
	[slideArray addObject:@{@"type":@"scripture", @"text":@"Testing scripture text body", @"reference":@"Scripture 3:16 (NIV)"}];
//    
    [self _saveSlidesFromArray:slideArray inStyle:ParkwaySlideStyle];
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

- (void)_saveSlidesFromArray:(NSArray *)slideArray inStyle:(SlideStyle)style
{

//    
//    NSString * slide1Test = [self _outputForBlankSlideAtIndex:0];
//    NSString * titleTest = [self _outputForSlideWithTitle:titleData atIndex:1];

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

    NSSavePanel * documentSavePanel = [NSSavePanel savePanel];
    [documentSavePanel setAllowedFileTypes:@[@"pro5x"]];
    [documentSavePanel setAllowsOtherFileTypes:NO];
    [documentSavePanel setExtensionHidden:NO];
    NSInteger saveResult = [documentSavePanel runModal];
    if (saveResult == NSOKButton)
    {
        NSURL * resultingFileURL = [documentSavePanel URL];
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
            }
            else if ([[slide valueForKey:@"type"] isEqualToString:@"point"])
            {
				NSMutableParagraphStyle * titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
				[titleParagraphStyle setAlignment:NSCenterTextAlignment];
				NSAttributedString * titleString = [[NSAttributedString alloc] initWithString:[slide valueForKey:@"text"] attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont fontWithName:@"MyriadPro-Bold" size:regularFontSize], NSParagraphStyleAttributeName:titleParagraphStyle}];

				template = [NSString stringWithContentsOfFile:titleTemplatePath encoding:NSUTF8StringEncoding error:nil];
				[replacements setObject:[self dataStringFromAttributedString:titleString] forKey:@"rtf data"];
            }
            else if ([[slide valueForKey:@"type"] isEqualToString:@"scripture"])
            {
				NSMutableParagraphStyle * textParagraphStyle = [[NSMutableParagraphStyle alloc] init];
				[textParagraphStyle setAlignment:NSLeftTextAlignment];
				NSAttributedString * textString = [[NSAttributedString alloc] initWithString:[slide valueForKey:@"text"] attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont fontWithName:@"MyriadPro-Bold" size:regularFontSize], NSParagraphStyleAttributeName:textParagraphStyle}];

				NSMutableParagraphStyle * referenceParagraphStyle = [[NSMutableParagraphStyle alloc] init];
				[referenceParagraphStyle setAlignment:NSRightTextAlignment];
				NSAttributedString * referenceString = [[NSAttributedString alloc] initWithString:[slide valueForKey:@"reference"] attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont fontWithName:@"MyriadPro-Regular" size:regularFontSize], NSParagraphStyleAttributeName:referenceParagraphStyle}];

				template = [NSString stringWithContentsOfFile:scriptureTemplatePath encoding:NSUTF8StringEncoding error:nil];
				[replacements setObject:[self dataStringFromAttributedString:textString] forKey:@"body rtf data"];
				[replacements setObject:[self dataStringFromAttributedString:referenceString] forKey:@"reference rtf data"];
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
            }

			NSString * slidePayload = [self _resultUpdatingTemplate:template withDictionary:replacements];
			[slideData appendString:slidePayload];

            slideIndex++;
        }

		NSDateFormatter * sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
		NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

		[sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
		[sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
		[sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

		NSString * documentTemplate = [NSString stringWithContentsOfFile:documentTemplatePath encoding:NSUTF8StringEncoding error:nil];
		
		NSDictionary * replacements = @{@"document title":[[xmlDocumentPath lastPathComponent] stringByDeletingPathExtension], @"document height":[NSString stringWithFormat:@"%ld", (long)slideHeight], @"document width":[NSString stringWithFormat:@"%ld", (long)slideWidth], @"date":[sRFC3339DateFormatter stringFromDate:[NSDate date]], @"group uuid":[[NSUUID UUID] UUIDString], @"slides":slideData};
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

        NSLog(@"test: %@", documentTest);

		[[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:theZippedFilePath] toURL:resultingFileURL error:nil];
    }
}
/*
- (NSString *)_outputTemplateForTitle:(NSString *)sermonTitle groupContent:(NSString *)groupContent
{
	return [NSString stringWithFormat:@"<RVPresentationDocument CCLIArtistCredits=\"\" CCLICopyrightInfo=\"\" CCLIDisplay=\"0\" CCLILicenseNumber=\"\" CCLIPublisher=\"\" CCLISongTitle=\"%@\" album=\"\" artist=\"\" author=\"\" backgroundColor=\"0 0 0 1\" category=\"Presentation\" chordChartPath=\"\" creatorCode=\"1349676880\" docType=\"0\" drawingBackgroundColor=\"0\" height=\"800\" lastDateUsed=\"2014-10-04T02:55:07\" notes=\"\" resourcesDirectory=\"\" usedCount=\"0\" versionNumber=\"500\" width=\"1280\"><timeline duration=\"0\" loop=\"0\" selectedMediaTrackIndex=\"0\" timeOffSet=\"0\" unitOfMeasure=\"60\"><timeCues containerClass=\"NSMutableArray\"/><mediaTracks containerClass=\"NSMutableArray\"/></timeline><bibleReference containerClass=\"NSMutableDictionary\"/><_-RVProTransitionObject-_transitionObject motionDuration=\"20\" motionEnabled=\"0\" motionSpeed=\"100\" transitionDuration=\"1\" transitionType=\"-1\"/><groups containerClass=\"NSMutableArray\">%@</groups><arrangements containerClass=\"NSMutableArray\"/></RVPresentationDocument>", sermonTitle, groupContent];
}

- (NSString *)_outputTemplateForGroupAtIndex:(int)groupIndex contentString:(NSString *)contentString
{
	return [NSString stringWithFormat:@"<RVSlideGrouping color=\"0 0 0 0\" name=\"\" serialization-array-index=\"%d\" uuid=\"%@\"><slides containerClass=\"NSMutableArray\">%@</slides></RVSlideGrouping>", groupIndex, [[NSUUID UUID] UUIDString], contentString];
}

- (NSString *)_outputForBlankSlideAtIndex:(int)slideIndex
{
	return [NSString stringWithFormat:@"<RVDisplaySlide UUID=\"%@\" backgroundColor=\"0 0 0 1\" chordChartPath=\"\" drawingBackgroundColor=\"0\" enabled=\"1\" highlightColor=\"0 0 0 0\" hotKey=\"\" label=\"\" notes=\"\" serialization-array-index=\"%d\" slideType=\"1\" sort_index=\"%d\"><cues containerClass=\"NSMutableArray\"/><displayElements containerClass=\"NSMutableArray\"/><_-RVProTransitionObject-_transitionObject motionDuration=\"20\" motionEnabled=\"0\" motionSpeed=\"100\" transitionDuration=\"1\" transitionType=\"-1\"/></RVDisplaySlide>", [[NSUUID UUID] UUIDString], slideIndex, slideIndex];
}

- (NSString *)_outputForSlideWithTitle:(NSString *)titleSlideData atIndex:(int)slideIndex
{
	return [NSString stringWithFormat:@"<RVDisplaySlide UUID=\"%@\" backgroundColor=\"0 0 0 1\" chordChartPath=\"\" drawingBackgroundColor=\"0\" enabled=\"1\" highlightColor=\"0 0 0 0\" hotKey=\"\" label=\"\" notes=\"\" serialization-array-index=\"%d\" slideType=\"1\" sort_index=\"%d\"><cues containerClass=\"NSMutableArray\"/><displayElements containerClass=\"NSMutableArray\"><RVTextElement RTFData=\"%@\" adjustsHeightToFit=\"0\" bezelRadius=\"0\" displayDelay=\"0\" displayName=\"\" drawingFill=\"0\" drawingShadow=\"1\" drawingStroke=\"0\" fillColor=\"0 0 0 0\" fromTemplate=\"0\" locked=\"0\" persistent=\"0\" revealType=\"0\" rotation=\"0\" serialization-array-index=\"0\" source=\"\" typeID=\"0\" verticalAlignment=\"0\"><_-RVRect3D-_position height=\"609.4775\" width=\"915.4355\" x=\"182.2823\" y=\"95.26126\" z=\"0\"/><_-D-_serializedShadow containerClass=\"NSMutableDictionary\"><NSMutableString serialization-dictionary-key=\"shadowOffset\" serialization-native-value=\"{1.4142135, -1.4142135}\"/><NSNumber serialization-dictionary-key=\"shadowBlurRadius\" serialization-native-value=\"2\"/><NSColor serialization-dictionary-key=\"shadowColor\" serialization-native-value=\"0 0 0 0.3333333432674408\"/></_-D-_serializedShadow><stroke containerClass=\"NSMutableDictionary\"><NSColor serialization-dictionary-key=\"RVShapeElementStrokeColorKey\" serialization-native-value=\"0 0 0 1\"/><NSNumber serialization-dictionary-key=\"RVShapeElementStrokeWidthKey\" serialization-native-value=\"1\"/></stroke></RVTextElement></displayElements><_-RVProTransitionObject-_transitionObject motionDuration=\"20\" motionEnabled=\"0\" motionSpeed=\"100\" transitionDuration=\"1\" transitionType=\"-1\"/></RVDisplaySlide>", [[NSUUID UUID] UUIDString], slideIndex, slideIndex, titleSlideData];
}

- (NSString *)_outputForSlideWithPoint:(NSString *)pointSlideData atIndex:(int)slideIndex
{
	return [NSString stringWithFormat:@"<RVDisplaySlide UUID=\"%@\" backgroundColor=\"0 0 0 1\" chordChartPath=\"\" drawingBackgroundColor=\"0\" enabled=\"1\" highlightColor=\"0 0 0 0\" hotKey=\"\" label=\"\" notes=\"\" serialization-array-index=\"%d\" slideType=\"1\" sort_index=\"%d\"><cues containerClass=\"NSMutableArray\"/><displayElements containerClass=\"NSMutableArray\"><RVTextElement RTFData=\"%@\" adjustsHeightToFit=\"0\" bezelRadius=\"0\" displayDelay=\"0\" displayName=\"\" drawingFill=\"0\" drawingShadow=\"1\" drawingStroke=\"0\" fillColor=\"0 0 0 0\" fromTemplate=\"0\" locked=\"0\" persistent=\"0\" revealType=\"0\" rotation=\"0\" serialization-array-index=\"0\" source=\"\" typeID=\"0\" verticalAlignment=\"0\"><_-RVRect3D-_position height=\"609.4775\" width=\"915.4355\" x=\"182.2823\" y=\"95.26126\" z=\"0\"/><_-D-_serializedShadow containerClass=\"NSMutableDictionary\"><NSMutableString serialization-dictionary-key=\"shadowOffset\" serialization-native-value=\"{1.4142135, -1.4142135}\"/><NSNumber serialization-dictionary-key=\"shadowBlurRadius\" serialization-native-value=\"2\"/><NSColor serialization-dictionary-key=\"shadowColor\" serialization-native-value=\"0 0 0 0.3333333432674408\"/></_-D-_serializedShadow><stroke containerClass=\"NSMutableDictionary\"><NSColor serialization-dictionary-key=\"RVShapeElementStrokeColorKey\" serialization-native-value=\"0 0 0 1\"/><NSNumber serialization-dictionary-key=\"RVShapeElementStrokeWidthKey\" serialization-native-value=\"1\"/></stroke></RVTextElement></displayElements><_-RVProTransitionObject-_transitionObject motionDuration=\"20\" motionEnabled=\"0\" motionSpeed=\"100\" transitionDuration=\"1\" transitionType=\"-1\"/></RVDisplaySlide>", [[NSUUID UUID] UUIDString], slideIndex, slideIndex, pointSlideData];
}

- (NSString *)_outputForScriptureSlidesWithBody:(NSString *)bodyTextData reference:(NSString *)referenceData atIndex:(int)slideIndex
{
	return [NSString stringWithFormat:@"<RVDisplaySlide UUID=\"%@\" backgroundColor=\"0 0 0 1\" chordChartPath=\"\" drawingBackgroundColor=\"0\" enabled=\"1\" highlightColor=\"0 0 0 0\" hotKey=\"\" label=\"\" notes=\"\" serialization-array-index=\"%d\" slideType=\"1\" sort_index=\"%d\"><cues containerClass=\"NSMutableArray\"/><displayElements containerClass=\"NSMutableArray\"><RVTextElement RTFData=\"%@\" adjustsHeightToFit=\"0\" bezelRadius=\"0\" displayDelay=\"0\" displayName=\"\" drawingFill=\"0\" drawingShadow=\"1\" drawingStroke=\"0\" fillColor=\"0 0 0 0\" fromTemplate=\"1\" locked=\"0\" persistent=\"0\" revealType=\"0\" rotation=\"0\" serialization-array-index=\"0\" source=\"\" typeID=\"0\" verticalAlignment=\"0\"><_-RVRect3D-_position height=\"564.3034\" width=\"975.8484\" x=\"152.0758\" y=\"47\" z=\"0\"/><_-D-_serializedShadow containerClass=\"NSMutableDictionary\"><NSMutableString serialization-dictionary-key=\"shadowOffset\" serialization-native-value=\"{1.4142135, -1.4142135}\"/><NSNumber serialization-dictionary-key=\"shadowBlurRadius\" serialization-native-value=\"2\"/><NSColor serialization-dictionary-key=\"shadowColor\" serialization-native-value=\"0 0 0 0.3333333432674408\"/></_-D-_serializedShadow><stroke containerClass=\"NSMutableDictionary\"><NSColor serialization-dictionary-key=\"RVShapeElementStrokeColorKey\" serialization-native-value=\"0 0 0 1\"/><NSNumber serialization-dictionary-key=\"RVShapeElementStrokeWidthKey\" serialization-native-value=\"1\"/></stroke></RVTextElement><RVTextElement RTFData=\"%@\" adjustsHeightToFit=\"0\" bezelRadius=\"0\" displayDelay=\"0\" displayName=\"\" drawingFill=\"0\" drawingShadow=\"1\" drawingStroke=\"0\" fillColor=\"1 1 1 1\" fromTemplate=\"1\" locked=\"0\" persistent=\"0\" revealType=\"0\" rotation=\"0\" serialization-array-index=\"1\" source=\"\" typeID=\"0\" verticalAlignment=\"0\"><_-RVRect3D-_position height=\"99.87567\" width=\"1009.704\" x=\"135.148\" y=\"674.592\" z=\"0\"/><_-D-_serializedShadow containerClass=\"NSMutableDictionary\"><NSMutableString serialization-dictionary-key=\"shadowOffset\" serialization-native-value=\"{1.4142135, -1.4142135}\"/><NSNumber serialization-dictionary-key=\"shadowBlurRadius\" serialization-native-value=\"2\"/><NSColor serialization-dictionary-key=\"shadowColor\" serialization-native-value=\"0 0 0 0.3333333432674408\"/></_-D-_serializedShadow><stroke containerClass=\"NSMutableDictionary\"><NSColor serialization-dictionary-key=\"RVShapeElementStrokeColorKey\" serialization-native-value=\"0 0 0 1\"/><NSNumber serialization-dictionary-key=\"RVShapeElementStrokeWidthKey\" serialization-native-value=\"1\"/></stroke></RVTextElement></displayElements><_-RVProTransitionObject-_transitionObject motionDuration=\"20\" motionEnabled=\"0\" motionSpeed=\"100\" transitionDuration=\"1\" transitionType=\"-1\"/></RVDisplaySlide>", [[NSUUID UUID] UUIDString], slideIndex, slideIndex, bodyTextData, referenceData];
}

- (NSString *)_outputForQuoteSlide:(NSString *)quoteData reference:(NSString *)referenceData atIndex:(int)slideIndex
{
	return [self _outputForScriptureSlidesWithBody:quoteData reference:referenceData atIndex:slideIndex];
}

- (NSString *)_outputForMediaSlideAtPath:(NSString *)mediaPath atIndex:(int)slideIndex
{
	NSString * slideUUID = [[NSUUID UUID] UUIDString];
	NSString * cueUUID = [[NSUUID UUID] UUIDString];
	return [NSString stringWithFormat:@"<RVDisplaySlide UUID=\"%@\" backgroundColor=\"0 0 0 1\" chordChartPath=\"\" drawingBackgroundColor=\"0\" enabled=\"1\" highlightColor=\"0 0 0 0\" hotKey=\"\" label=\"\" notes=\"\" serialization-array-index=\"%d\" slideType=\"1\" sort_index=\"%d\"><cues containerClass=\"NSMutableArray\"><RVMediaCue UUID=\"%@\" alignment=\"4\" behavior=\"2\" delayTime=\"0\" displayName=\"\" elementClassName=\"RVImageElement\" enabled=\"1\" parentUUID=\"%@\" serialization-array-index=\"0\" timeStamp=\"0\"><element bezelRadius=\"0\" blurRadius=\"0\" brightness=\"0\" colorFilter=\"1 0 0 1\" contrast=\"1\" displayDelay=\"0\" displayName=\"\" drawingFill=\"0\" drawingShadow=\"0\" drawingStroke=\"0\" edgeBlurArea=\"0\" edgeBlurRadius=\"0\" enableBlur=\"0\" enableColorFilter=\"0\" enableColorInvert=\"0\" enableEdgeBlur=\"0\" enableGrayInvert=\"0\" enableHeatSignature=\"0\" enableSepia=\"0\" fillColor=\"1 1 1 1\" flippedHorizontally=\"0\" flippedVertically=\"0\" format=\"JPEG image\" fromTemplate=\"0\" hue=\"0\" locked=\"0\" manufactureName=\"\" manufactureURL=\"\" persistent=\"0\" rotation=\"0\" saturation=\"1\" scaleBehavior=\"0\" scaleFactor=\"1\" serializedFilters=\"YnBsaXN0MDDUAQIDBAUIFhdUJHRvcFgkb2JqZWN0c1gkdmVyc2lvblkkYXJjaGl2ZXLRBgdUcm9vdIABowkKD1UkbnVsbNILDA0OViRjbGFzc1pOUy5vYmplY3RzgAKg0hAREhNYJGNsYXNzZXNaJGNsYXNzbmFtZaMTFBVeTlNNdXRhYmxlQXJyYXlXTlNBcnJheVhOU09iamVjdBIAAYagXxAPTlNLZXllZEFyY2hpdmVyCBEWHygyNTo8QEZLUl1fYGVueX2MlJ2iAAAAAAAAAQEAAAAAAAAAGAAAAAAAAAAAAAAAAAAAALQ=\" serializedImageOffset=\"0.000000@0.000000\" source=\"%@\" typeID=\"0\"><_-RVRect3D-_position height=\"800\" width=\"1280\" x=\"0\" y=\"0\" z=\"0\"/><_-D-_serializedShadow containerClass=\"NSMutableDictionary\"><NSMutableString serialization-dictionary-key=\"shadowOffset\" serialization-native-value=\"{5, -5}\"/><NSNumber serialization-dictionary-key=\"shadowBlurRadius\" serialization-native-value=\"0\"/><NSColor serialization-dictionary-key=\"shadowColor\" serialization-native-value=\"0 0 0 0.3333333432674408\"/></_-D-_serializedShadow><stroke containerClass=\"NSMutableDictionary\"><NSColor serialization-dictionary-key=\"RVShapeElementStrokeColorKey\" serialization-native-value=\"0 0 0 1\"/><NSNumber serialization-dictionary-key=\"RVShapeElementStrokeWidthKey\" serialization-native-value=\"1\"/></stroke></element><_-RVProTransitionObject-_transitionObject/></RVMediaCue></cues><displayElements containerClass=\"NSMutableArray\"/><_-RVProTransitionObject-_transitionObject motionDuration=\"20\" motionEnabled=\"0\" motionSpeed=\"100\" transitionDuration=\"1\" transitionType=\"-1\"/></RVDisplaySlide>", slideUUID, slideIndex, slideIndex, cueUUID, slideUUID, mediaPath];
}
*/
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
