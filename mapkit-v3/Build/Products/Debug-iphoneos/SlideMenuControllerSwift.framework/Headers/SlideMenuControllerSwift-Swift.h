// Generated by Apple Swift version 2.2 (swiftlang-703.0.18.8 clang-703.0.31)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if defined(__has_include) && __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
# if defined(__has_feature) && __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
@import CoreGraphics;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class UIView;
@class UIPanGestureRecognizer;
@class UITapGestureRecognizer;
@class NSCoder;
@class NSBundle;
@protocol UIViewControllerTransitionCoordinator;
@class UIGestureRecognizer;
@class UITouch;
@protocol SlideMenuControllerDelegate;

SWIFT_CLASS("_TtC24SlideMenuControllerSwift19SlideMenuController")
@interface SlideMenuController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id <SlideMenuControllerDelegate> _Nullable delegate;
@property (nonatomic, strong) UIView * _Nonnull opacityView;
@property (nonatomic, strong) UIView * _Nonnull mainContainerView;
@property (nonatomic, strong) UIView * _Nonnull leftContainerView;
@property (nonatomic, strong) UIView * _Nonnull rightContainerView;
@property (nonatomic, strong) UIViewController * _Nullable mainViewController;
@property (nonatomic, strong) UIViewController * _Nullable leftViewController;
@property (nonatomic, strong) UIPanGestureRecognizer * _Nullable leftPanGesture;
@property (nonatomic, strong) UITapGestureRecognizer * _Nullable leftTapGesture;
@property (nonatomic, strong) UIViewController * _Nullable rightViewController;
@property (nonatomic, strong) UIPanGestureRecognizer * _Nullable rightPanGesture;
@property (nonatomic, strong) UITapGestureRecognizer * _Nullable rightTapGesture;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithMainViewController:(UIViewController * _Nonnull)mainViewController leftMenuViewController:(UIViewController * _Nonnull)leftMenuViewController;
- (nonnull instancetype)initWithMainViewController:(UIViewController * _Nonnull)mainViewController rightMenuViewController:(UIViewController * _Nonnull)rightMenuViewController;
- (nonnull instancetype)initWithMainViewController:(UIViewController * _Nonnull)mainViewController leftMenuViewController:(UIViewController * _Nonnull)leftMenuViewController rightMenuViewController:(UIViewController * _Nonnull)rightMenuViewController;
- (void)awakeFromNib;
- (void)initView;
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator> _Nonnull)coordinator;
- (void)viewDidLoad;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (void)viewWillLayoutSubviews;
- (void)openLeft;
- (void)openRight;
- (void)closeLeft;
- (void)closeRight;
- (void)addLeftGestures;
- (void)addRightGestures;
- (void)removeLeftGestures;
- (void)removeRightGestures;
- (BOOL)isTagetViewController;
- (void)openLeftWithVelocity:(CGFloat)velocity;
- (void)openRightWithVelocity:(CGFloat)velocity;
- (void)closeLeftWithVelocity:(CGFloat)velocity;
- (void)closeRightWithVelocity:(CGFloat)velocity;
- (void)toggleLeft;
- (BOOL)isLeftOpen;
- (BOOL)isLeftHidden;
- (void)toggleRight;
- (BOOL)isRightOpen;
- (BOOL)isRightHidden;
- (void)changeMainViewController:(UIViewController * _Nonnull)mainViewController close:(BOOL)close;
- (void)changeLeftViewWidth:(CGFloat)width;
- (void)changeRightViewWidth:(CGFloat)width;
- (void)changeLeftViewController:(UIViewController * _Nonnull)leftViewController closeLeft:(BOOL)closeLeft;
- (void)changeRightViewController:(UIViewController * _Nonnull)rightViewController closeRight:(BOOL)closeRight;
- (void)closeLeftNonAnimation;
- (void)closeRightNonAnimation;
- (BOOL)gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldReceiveTouch:(UITouch * _Nonnull)touch;
- (BOOL)gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer * _Nonnull)otherGestureRecognizer;
@end


SWIFT_PROTOCOL("_TtP24SlideMenuControllerSwift27SlideMenuControllerDelegate_")
@protocol SlideMenuControllerDelegate
@optional
- (void)leftWillOpen;
- (void)leftDidOpen;
- (void)leftWillClose;
- (void)leftDidClose;
- (void)rightWillOpen;
- (void)rightDidOpen;
- (void)rightWillClose;
- (void)rightDidClose;
@end

@class UIImage;
@class UIScrollView;

@interface UIViewController (SWIFT_EXTENSION(SlideMenuControllerSwift))
- (SlideMenuController * _Nullable)slideMenuController;
- (void)addLeftBarButtonWithImage:(UIImage * _Nonnull)buttonImage;
- (void)addRightBarButtonWithImage:(UIImage * _Nonnull)buttonImage;
- (void)toggleLeft;
- (void)toggleRight;
- (void)openLeft;
- (void)openRight;
- (void)closeLeft;
- (void)closeRight;
- (void)addPriorityToMenuGesuture:(UIScrollView * _Nonnull)targetScrollView;
@end

#pragma clang diagnostic pop
