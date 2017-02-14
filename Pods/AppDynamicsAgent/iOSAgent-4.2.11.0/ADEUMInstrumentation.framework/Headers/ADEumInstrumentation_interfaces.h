//  Copyright (c) 2013 AppDynamics Technologies. All rights reserved.

#import <Foundation/Foundation.h>
#import "ADEumCollectorChannel.h"
#import "ADEumCrashReportCallback.h"
#import "ADEumCommons.h"

typedef NS_ENUM(NSInteger, ADEumBreadcrumbVisibility) {
    ADEumBreadcrumbVisibilityCrashesOnly,
    ADEumBreadcrumbVisibilityCrashesAndSessions,
    CrashesOnly
    __deprecated_enum_msg("CrashesOnly is deprecated. Please use ADEumBreadcrumbVisibilityCrashesOnly.")
    OBJC_SWIFT_UNAVAILABLE("Don’t create swift version.") = ADEumBreadcrumbVisibilityCrashesOnly,
    CrashesAndSessions
    __deprecated_enum_msg("CrashesAndSessions is deprecated. Please use ADEumBreadcrumbVisibilityCrashesAndSessions.")
    OBJC_SWIFT_UNAVAILABLE("Don’t create swift version.") = ADEumBreadcrumbVisibilityCrashesAndSessions
};

typedef NS_OPTIONS(NSUInteger, ADEumInteractionCaptureMode) {
    ADEumInteractionCaptureModeNone = 0UL,
    ADEumInteractionCaptureModeButtonPressed = (1UL << 0),
    ADEumInteractionCaptureModeTableCellSelected = (1UL << 1),
    ADEumInteractionCaptureModeTextFieldSelected = (1UL << 2),
    ADEUmInteractionCaptureModeTextViewSelected = (1UL << 3),
    ADEumInteractionCaptureModeAll = ~0UL,
};

ADEUM_ASSUME_NONNULL_BEGIN

/** The configuration of the AppDynamics SDK
 */
@interface ADEumAgentConfiguration : NSObject

/**
 * The application key.
 *
 * @warning This property is required.
 */
@property (nonatomic, copy) NSString *appKey;

/**
 * The URL of the collector.
 *
 * The SDK will send beacons to this collector.
 */
@property (nonatomic, copy) NSString * ADEUM_NULLABLE collectorURL;

/**
 * The hostname used to determine whether the device is connected to the internet.
 *
 * In order to determine if a device is connected to the internet, the agent SDK
 * checks if a network route to the specific host is available. If that host is
 * not reachable, the device is marked as "offline".
 *
 * If the application has restrictions on the IP addresses it is allowed to freely
 * access, then this property should be used with a host the application can reach
 * that is expected to be available to ensure the connection type is accurate.
 *
 * The default hostname is www.google.com.
 */
@property (nonatomic, copy) NSString * ADEUM_NULLABLE reachabilityHostName;

/**
 * Boolean value that indicates whether debug logging is enabled.
 *
 * @warning Not recommended for production.
 */
@property (nonatomic) BOOL enableLogging;

/**
 * The custom collector channel, if used.
 *
 * This is only needed when customizing the communication channel between the SDK and the collector.
 * Most users will not need this.
 */
@property (nonatomic, strong) id<ADEumCollectorChannel> ADEUM_NULLABLE collectorChannel;

/**
 * The name of this mobile application, if used.
 *
 * If set, all data reported from this application is associated with the given application
 * name, and appears together in dashboards. If not set, the mobile application name is
 * determined automatically based on the identifier of the main application bundle.
 * Most users will not need this.
 *
 * @warning `applicationName` must not be an empty string, and must contain only
 * alphanumeric characters, hyphens, and periods in reverse-DNS format.
 */
@property (nonatomic, strong) NSString * ADEUM_NULLABLE applicationName;

/**
 * The url regex patterns for excluding url request tracking, if used
 *
 * If set, any url matching one of defined patterns won't be tracked.
 */
@property (nonatomic, strong) NSSet * ADEUM_NULLABLE excludedUrlPatterns;

/**
 * Bitmask value that indicates what types of user interaction events should be captured.
 * The default value is ADEumInteractionCaptureModeNone which means no interactions are captured.
 *
 * @warning Using ADEumInteractionCaptureModeAll means that all currently known and to-be implemented 
 * interactions are captured. This could conceivably include personal user information. If you have any
 * concerns around this, we recommend turning on only the interactions you want captured by using the
 * individual specific constants.
 *
 * @discussion The enumerated values for ADEumInteractionCaptureMode are described below.
 * ADEumInteractionCaptureModeButtonPressed - Tracks "press" on UIButton or UIBarButtonItem or any of
 * their subclasses
 */
@property (nonatomic) ADEumInteractionCaptureMode interactionCaptureMode;

/**
 * The agent supports the use of a "callback" to send notifications of
 * crashes being reported. You can use this callback to get these reports.
 *
 * @see ADEumCrashReportCallback
 *
 */
@property (nonatomic, weak) id<ADEumCrashReportCallback> ADEUM_NULLABLE crashReportCallback;

/**
 * Returns a configuration with the specified app key and defaults for the other properties.
 *
 * @param appKey The application key to use.
 */
- (id)initWithAppKey:(NSString *)appKey;

/**
 * Returns a configuration with the specified app key and collector URL,
 * and defaults for the other properties.
 *
 * @param appKey The application key to use.
 * @param collectorURL The URL of the collector.
 */
- (id)initWithAppKey:(NSString *)appKey collectorURL:(NSString * ADEUM_NULLABLE)collectorURL;

@end

/** AppDynamics iOS SDK
 */
@interface ADEumInstrumentation : NSObject

///---------------------
/// @name Initialization
///---------------------

/**
 * Initializes the SDK.
 *
 * This method should be called once, early in your application's startup sequence.
 *
 * @param appKey The application key.
 *
 * @warning `appKey` must not be `nil`.
 */
+ (void)initWithKey:(NSString *)appKey;

/**
 * Initializes the SDK.
 *
 * This method should be called once, early in your application's startup sequence.
 *
 * @param appKey The application key.
 * @param collectorUrl The URL of the collector. The SDK will send beacons to this collector.
 *
 * @warning `appKey` must not be `nil`.
 * @warning `collectorUrl` must not be `nil`. Otherwise, an NSInvalidArgumentException will be thrown.
 */
+ (void)initWithKey:(NSString *)appKey collectorUrl:(NSString *)collectorUrl;

/**
 * Initializes the SDK.
 *
 * This method should be called once, early in your application's startup sequence.
 *
 * @param agentConfiguration The configuration to use.
 *
 * @warning `agentConfiguration` must not be `nil`. Otherwise, an NSException will be thrown.
 */
+ (void)initWithConfiguration:(ADEumAgentConfiguration *)agentConfiguration;

/**
 * Changes the application key.
 *
 * The SDK doesn't send all instrumentation data immediately, and calling this method causes all unsent
 * data to be discarded. Use this method sparingly.
 *
 * @param appKey The new application's key.
 *
 * @warning `appKey` must not be `nil`. Otherwise, an NSException will be thrown.
 */
+ (void)changeAppKey:(NSString *)appKey;

///---------------------
/// @name Instrumenting application methods
///---------------------

/**
 * Call this method at the beginning of a method's execution to track that method invocation.
 *
 * @param receiver The object to which this message was sent.
 * @param selector The selector describing the message that was sent.
 * @param arguments The values of the arguments of this method call. This parameter is optional and may be nil.
 *                   Additionally, you are free to send only a subset of the actual arguments.
 *
 * @return An object that must be passed to endCall:.
 *
 * @warning `receiver` must not be `nil`.
 * @warning `selector` must not be `nil`.
 *
 * @see +endCall:
 * @see +endCall:withValue:
 */
+ (id ADEUM_NULLABLE)beginCall:(id)receiver selector:(SEL)selector withArguments:(NSArray * ADEUM_NULLABLE)arguments;

/**
 * Call this method at the beginning of a method's execution to track that method invocation.
 *
 * Equivalent to beginCall:receiver selector:selector arguments:nil.
 *
 * @param receiver The object to which this message was sent.
 * @param selector The selector describing the message that was sent.
 *
 * @see +beginCall:selector:withArguments:
 */
+ (id ADEUM_NULLABLE)beginCall:(id)receiver selector:(SEL)selector;

/**
 * Call this method right before returning from a method to finish tracking the method invocation.
 *
 * @param call The object returned from beginCall:Selector:withArguments:.
 * @param returnValue The return value of the method. This is optional, and may be nil.
 */
+ (void)endCall:(id ADEUM_NULLABLE)call withValue:(id ADEUM_NULLABLE)returnValue;

/**
 * Call this method right before returning from a method to finish tracking the method invocation.
 *
 * Equivalent to endCall:call withValue:nil.
 *
 * @param call The object returned from beginCall:Selector:withArguments:.
 *
 * @see +endCall:withValue:
 */
+ (void)endCall:(id ADEUM_NULLABLE)call;

///---------------------
/// @name Timing events
///---------------------

/**
 * Starts a timer for tracking a user-defined event with a duration.
 *
 * If this method is called multiple times without a corresponding call to stopTimerWithName,
 * every call after the first will reset the timer.
 *
 * @param name The name of the timer, which will determine the name of the corresponding metric.
 *             Generally, timers that are logically separate should have distinct names.
 *
 * @warning `name` must not be `nil` or the empty string, and must consist of only alphanumeric characters.
 *           Otherwise, an NSException will be thrown.
 */
+ (void) startTimerWithName:(NSString *)name;

/**
 * Stops a timer for tracking a user-defined event with a duration.
 *
 * If you haven't called startTimerWithName with the given name before calling this method, this method has no effect.
 *
 * @param name The name of the timer, which will determine the name of the corresponding metric.
 *              Generally, timers that are logically separate should have distinct names.
 *
 * @warning `name` must not be `nil` or the empty string, and must consist of only alphanumeric characters.
 *           Otherwise, an NSException will be thrown.
 */
+ (void) stopTimerWithName:(NSString *)name;

///---------------------
/// @name Reporting metrics
///---------------------

/**
 * Reports the value of a custom metric.
 *
 * @param name The name of the metric.
 * @param value The value of the metric.
 *
 * @warning `name` must not be `nil` or the empty string, and it must consist of only alphanumeric characters.
 *           Otherwise, an NSException will be thrown.
 */
+ (void)reportMetricWithName:(NSString *)name value:(int64_t)value;


///---------------------
/// @name Breadcrumbs tracking for crash reports
///---------------------

/**
 * Records the value of breadcrumb and assigns it a current timestamp.
 *
 * Call this method when something interesting happens in your application.
 * If your application crashes at some point in the future, the breadcrumb
 * will be included in the crash report, to help you understand the problem.
 * Each crash report displays the most recent 99 breadcrumbs.
 *
 * @param breadcrumb The value of breadcrumb.
 *
 * @warning The breadcrumb will not be recorded if it is `nil` or the empty string.
 *           The breadcrumb will be truncated if it is longer than 2048 characters.
 */
+ (void)leaveBreadcrumb:(NSString * ADEUM_NULLABLE)breadcrumb;

/**
 * Records the value of breadcrumb and assigns it a current timestamp.
 *
 * Call this method when something interesting happens in your application.
 * The breadcrumb will be included in different reports depending on the 'mode'.
 * Each crash report displays the most recent 99 breadcrumbs.
 *
 * @param breadcrumb The value of breadcrumb.
 * @param mode The visibility mode, which is either `ADEumBreadcrumbVisibilityCrashesOnly` or
 *        `ADEumBreadcrumbVisibilityCrashesAndSessions`.
 *
 * @warning The breadcrumb will not be recorded if it is `nil` or the empty string.
 *           The breadcrumb will be truncated if it is longer than 2048 characters.
 * @warning `mode` must be either `ADEumBreadcrumbVisibilityCrashesOnly` or
 *          `ADEumBreadcrumbVisibilityCrashesAndSessions`.
 *           Otherwise, an NSException will be thrown.
 */
+ (void)leaveBreadcrumb:(NSString * ADEUM_NULLABLE)breadcrumb mode:(ADEumBreadcrumbVisibility)mode;


///---------------------
/// @name UserData tracking
///---------------------

/**
 * Sets a key-value pair identifier that will be included in all snapshots.
 * The identifier can be used to add any data you wish.
 *
 * The key must be unique across your application.  Re-using the same key overwrites the previous value.
 *
 * A value of null will clear the data.
 *
 * If persist is set to YES, this data is stored across multiple app instances.
 * If persist is set to NO, this data is only sent during this app instance, and is removed when the
 * instance is terminated.
 *
 * Once the whole application is destroyed, the non-persisted data is removed.
 *
 * @param key       Your unique key.
 * @param value     Your value, or null to clear this data.
 * @param persist   A boolean value indicating whether this key-value pair persists through app terminations.
 *
 * @warning Both the key and the value will if be truncated if they are longer than 2048 characters.
 */
+ (void)setUserData:(NSString *)key value:(NSString * ADEUM_NULLABLE)value persist:(BOOL)persist;


// Undocumented methods, useful for debugging. These are subject to change in future releases.
+ (void)initWithKey:(NSString *)appKey enableLogging:(BOOL)enableLogging;

+ (void)initWithKey:(NSString *)appKey collectorUrl:(NSString * ADEUM_NULLABLE)collectorUrl enableLogging:(bool)enableLogging;

@end

ADEUM_ASSUME_NONNULL_END
