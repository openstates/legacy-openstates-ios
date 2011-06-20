//
//  VTPGAdvancedLog.h
//  TexLege
//
//  Found at Vincent Gable's Blog
//  http://vgable.com/blog/2010/08/19/the-most-useful-objective-c-code-ive-ever-written/
//
//

/*
 USAGE:
	Stop using logs like this:
	NSLog(@"actionURL = %@", actionURL))

	And start using logs like this:

	LOG_EXPR(self.window.screen);
	>>> self.window.screen = <UIScreen: 0x6d20780; bounds = {{0, 0}, {320, 480}}; mode = <UIScreenMode: 0x6d20c50; size = 320.000000 x 480.000000>>

	LOG_EXPR(self.tabBarController.viewControllers);
	>>> self.tabBarController.viewControllers = (
											 “<UINavigationController: 0xcd02e00>”,
											 “<SavingsViewController: 0xcd05c40>”,
											 “<SettingsViewController: 0xcd05e90>”
											 )

	**** It even works on scalars and structs ****

	LOG_EXPR(self.window.windowLevel);
	>>> self.window.windowLevel = 0.000000

	LOG_EXPR(self.window.frame.size);
	>>> self.window.frame.size = {320, 480}

*/

#import <Foundation/Foundation.h>


NSString * VTPG_DDToStringFromTypeAndValue(const char * typeCode, void * value);

// WARNING: if NO_LOG_MACROS is #defined, then THE ARGUMENT WILL NOT BE EVALUATED
#ifndef NO_LOG_MACROS

#define LOG_EXPR(_X_) do{\
	__typeof__(_X_) _Y_ = (_X_);\
	const char * _TYPE_CODE_ = @encode(__typeof__(_X_));\
	NSString *_STR_ = VTPG_DDToStringFromTypeAndValue(_TYPE_CODE_, &_Y_);\
	if(_STR_)\
		NSLog(@"%s = %@", #_X_, _STR_);\
	else\
		NSLog(@"Unknown _TYPE_CODE_: %s for expression %s in function %s, file %s, line %d", _TYPE_CODE_, #_X_, __func__, __FILE__, __LINE__);\
}while(0)

#define LOG_NS(...) NSLog(__VA_ARGS__)
#define LOG_FUNCTION()	NSLog(@"%s", __func__)
#else /* NO_LOG_MACROS */
#define LOG_EXPR(_X_)
#define LOG_NS(...)
#define LOG_FUNCTION()
#endif /* NO_LOG_MACROS */

