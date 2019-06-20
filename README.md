# PulsePartner

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/1f90bc42ba684620913d3d0eed08322c)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Ragyal/PulsePartner&amp;utm_campaign=Badge_Grade)

## Funktionen

* Login
* Profil
  * Bild
  * Alter
  * Fitness-Level
* Matching
  * Puls
  * Ort
  * Profil
  * Anzahl Apple Produkte
* Pushnotifikation
  * Puls-Vibration vom Match
  * Bild vom Match
* Chatfunktion

## Technologien

* Persistence (Datenbank/Firebase)
* HealthKit/WatchKit
* GPS (location-aware)
* Pushnotifikation
* Cloud-Functions


## Quickstart

For a quick start we recommend to use our existing Firebase project. Because there are important settings that cannot be changed and uploaded via local code. To give you an insight into the backend, we have released the Firebase project.

The project folder contains the Xcode Workspace (PulsePartner.xcworkspace), which should be used to open the project, as well as all programmable Firebase settings in the subfolder "Firebase".

First the Firestore and Storage rules are defined in a JS similar language. In the subfolder "functions/src" you can find the Cloud Functions, which are written in Typescript.

The Xcode project is roughly divided into three sections based on Apple's MVC.

In Model you can find managers (e.g. UserManager) and classes (e.g. FullUser) divided by areas. Most of them are singletons with a static variable called "shared", which provides the shared instance of the manager.

The View section is quite small and contains the LayoutHelper, which we used to change the values of the constraints during runtime. This helps us to edit the layout for different display sizes.
A scaling of the constraints for different display sizes is unfortunately not possible in the storyboard of Xcode, only the arrangement of the individual components in portrait or landscape format can be adjusted in the storyboard.
The only way to adjust constraints to different sizes is to change them in the program code.

Finally, under (View)Controller is the logic that distributes the user's input to the managers or DataAccessObjects.

## Features
- Start screen with selection of login and registration
- Registration process including image selection
- Permission request for Health-Kit, Push Notifications and GPS
- MainView with current matches
    - Matching-process 
        - Every 2 minutes (14:00, 14:02, ...) 
        - Match criteria
            - Appropriate gender, which corresponds to the sexual orientation of both users
            - Position within a radius of 300 m
            - Pulse value is similar to +-5
    - Change the profile picture by clicking on it
    - Background location update
    - Chat function for communication with existing matches


## Libraries and Code-snippets
### FirebaseSDK ([Link](https://firebase.google.com/docs/ios/setup))

Since our app uses Firebase as backend, we need the corresponding FirebaseSDK. With different sub-packages (e.g. Auth, Firestore or Storage) we can use the corresponding modules. The FirebaseSDK must be initialised in AppDelegate.

## FirestoreModel ([Link](https://medium.com/@tonisucic/type-safe-models-with-firestore-swift-4-1cd38a9afd49))

In order to easily convert Firestore documents into type-safe own Swift classes, we use a concept from the linked medium blog post. Before we could use the concept, we had to fix bugs with the current Swift version and FirebaseSDK.

## Observer Protokoll ([Link](https://www.swiftbysundell.com/posts/observers-in-swift-part-1))

From this blog post we have taken a sample implementation of the observer pattern. We have modified it in such a way that an observer gets the current value of the observable directly at registration.

## TOCropViewController ([Link](https://github.com/TimOliver/TOCropViewController))

We use Tim Oliver's CropViewController to give the user the possibility to select a certain (round) section of his image as a profile image before uploading it.

## Kingfisher ([Link](https://github.com/onevcat/Kingfisher/))

Kingfisher is a library that can handle the caching of images. Images can be requested with an URL and Kingfisher takes care of the download, placeholder images and caching in memory and/or on disk. We chose Kingfisher because the caching of the FirebaseSDK was slower and less transparent.

## Checkbox ([Link](https://www.iostutorialjunction.com/2018/01/create-checkbox-in-swift-ios-sdk-tutorial-for-beginners.html))

Since Swift does not provide the developer with its own checkboxes, we used this method from "iostutorialjunction.com".

## MessageKit ([Link](https://messagekit.github.io/))

MessageKit is a framework that provides the layout for a chatview. Using this framework, styles can be quickly used and modified to create a decent chat application.

## LayoutHelper ([Link](https://github.com/tryWabbit/Layout-Helper))

With the LayoutHelper library constraints can be changed during runtime. This function helps us to adjust the layout for different devices.
