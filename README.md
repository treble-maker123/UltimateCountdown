A MacOS app that keeps a list of tasks with a countdown clock. It was created as a result of me not being able to find a free one that works.


#### TODO for V1.0

- Figure out a way to alternate color in NSCollectionViewItem
- Find a better way to sync all of the countdown clocks. Currently each countdown clock is on a separate Timer
- If the entire test suite is run, a mysterious error is sometimes thrown in CDListViewController where I'm attaching a lambda block to _manager.onItemAdded. No issue when running. More details can be found [here](https://stackoverflow.com/questions/47141143/cocoa-unittest-throws-error-for-object-0x600000001240-invalid-pointer-dequeued).

#### For future
- The UI could look a bit better
- Create a notification center widget
