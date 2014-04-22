#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <stdio.h>
#import <unistd.h>

// gcc -g -Wall -framework Foundation -o group group.m

int main(void) {
	@autoreleasepool {
		dispatch_group_t group = dispatch_group_create();

		// Fan out the work
		dispatch_group_async(group, dispatch_get_global_queue(0, 0),
				^{ printf("I seem to be a verb\n"); });
		dispatch_group_async(group, dispatch_get_main_queue(),
				^{ printf("main queue groovy!\n"); });
		dispatch_group_async(group,
				dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
				^{ sleep(5); printf("background groovy!\n"); });
		dispatch_group_notify(group, dispatch_get_global_queue(0, 0),
				^{ printf("all done!\n"); });
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
				printf("Starting to wait\n");
				long result = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
				printf("Wait returned with result: %ld\n", result);
				dispatch_release(group);
				});
		sleep(10);

		printf("starting runloop\n");
		[[NSRunLoop currentRunLoop] runUntilDate:
			[NSDate dateWithTimeIntervalSinceNow: 10]];
		printf("out of runloop\n");
	}
	return 0;
}
