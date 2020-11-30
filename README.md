# Reddit App

This repository contains the code for an iOS app I built for a coding challenge. The idea was to build an app consuming the Reddit API retrieving the tops posts on the platform.

https://www.reddit.com/dev/api/

## Reddit information:
* Title
* Author name
* Relative entry date
* Thumbnail
* Full size image (when the image is open)
* Number of comments
* Unread status

## Implementation details:
* Xcode 12 / iOS 14
* Storyboard / UITableView
* No external library
* Support all Device Orientation
* Support iPhone and iPad (navigation controller on iPhone and split view on iPad)
* Use Storyboards
* Pull to Refresh
* Pagination support
* Open picture in full size
* Saving pictures in the picture gallery
* Indicator of unread/read post
* Dismiss Post Button (with animation)
* Dismiss All Posts Button (with animation)

## Architecture decisions

The architecture decisions I made, created a good separation of concerns, allowing the app to have a good testability and reusability. For the data management I used a **offline-first** strategy, where my features always save/fetch information from the local database (don't fill the user interface with info coming from a network call directly). To make this work I use a separated mechanism that make this sync between the cloud and the local database.

This strategy allows the app to provide a better user experience, always trying to display local data first, before trying to reach the cloud.

For the views, I used a MVVM approach removing many responsibilities from the view controller and allowing me to better unit test my business logics.
To separate concerns, I splitted my app into different frameworks: **Core**, **Cloud**, **Database**, **PostUI**.

To get the data from the local database I set up reactive calls. Every time a new data is available the view gets notified and reload with the proper data, using view bindings. These bindings were created using the **Swift Combine** framework.

All my views and view models lives in the **PostUI** framework. If the this application grows, its advised put the code into other independent features, to improve the separation of concerns and build performance.

The following frameworks, I call Infrastructure layers: **Cloud**, **Database**. They deal with a very specific task being:
* **Cloud** - Network requests
* **Database** - Core Data database access

To make sure the code is isolated and the features, doesn't access them directly, the **PostUI** framework can't access the infrastructure layers directly.
There's an additional framework called **Core** that helps with that. The **Core** framework exposes public protocols that can be used to apply a
Dependency Injection mechanism in order for the view models to access the infrastructure mechanisms.

This is really interesting because later, it makes easier to create mocks and write unit tests properly.

This architecture overview is best described with the image below:

![](https://github.com/fernandodelrio/RedditApp/blob/master/Architecture%20Overview.png "Architecture Overview")

## Core Data strategy

Core Data is a super efficient local data mechanism on iOS, but is also a source of many issues when using it wrong.
In order to create a safer API in this project, I took the following decisions:

* Use a private queue for the NSManagedObjectContext. It needs to run with the **perform** method to ensure we are in the correct thread.
This way we never block the main thread providing a more fluid user interface. Because of this decision the calls to Core Data are always async
and we return a combine publisher every time.
* Save the context only when necessary. This decision ensures we have the best possible performance as we are dealing with in memory data as
much as possible
* Keep core data isolated in its framework. Parse the NSManagedObject to a simple data structure, before returning to the features. Using this approach,
we keep the features 100% isolated from the concepts of the Core Data and it creates a safer enviroment for when we deal with the database. Also makes easier to mock and create unit tests as I mentioned above.

## Network strategy

To make sure we don't face issues with the Reddit API, I took the following decisions:

* When performing a request and it returns and error, retry that request 3 times.
* Returns a combine publisher for each network request. This allows me to deal with the network calls with a common API as we do for the database.
With that, its easier to compose the data to display in the user interface.
* Whenever we download an image, we save it in a NSCache instance. So the next time that image is requested, we can just return the cached image and avoid network usage.

## Listing informations to the user

Whenever I needed to display a list of informations to the user I make sure to don't wait until all information are available in memory.

This is important to create a more **fluid user interface**. So whenever the local database already saved or returned from Reddit API, I immediately
display to the user the text and start to load the images separatedly. Because of this decision the data always appears as fast as possible to the user.

## Unit Tests

With all the strategy I mentioned above, unit testing was an easy task. The **Core** framework exposes an **Dependency** class that can be used to resolve any protocol exposed there: **PostProvider**,
**OfflinePostProvider**, **OnlinePostProvider**, **RequestProvider**, **ImageCacheProvider**, **EndpointProvider**.

In the app delegate another class called **Injector** register all these **abstract** types to its **concrete** implementations in the infrastructure layer.
But when we come to do unit tests, another class called **TestInjector** register a different **concrete** implementation for these types.
These implementations are the mock classes that helps us to isolate and unit test each class individually.

Because of the short time, I didn't wrote a full coverage of all classes in the project, but I could cover with unit test the majority of the flows of
my main view models, demonstrating how to use this mocking mechanism:

![](https://github.com/fernandodelrio/RedditApp/blob/master/Code%20Coverage.png "Code Coverage")

## Finally, the working app

In this last section I will put a link for a video demonstrations of the app + a set of images of the app's user interface, I hope you enjoy. Feel free to get the project and run to check it yourself.

### Demonstration videos
iPhone:
https://drive.google.com/file/d/1dKyHpq-Ltdlh1HFbUoAyQs35lAW8qDjr/view?usp=sharing

iPad:
https://drive.google.com/file/d/1tLibB5_v86CSMsNgeE8O7cHh6cPxt3dl/view?usp=sharing
