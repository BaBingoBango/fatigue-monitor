## Opening Xcode

In order to create a build of the app, you'll need to have Xcode downloaded from the Mac App Store. Once you open it, you should see this welcome window:

<img width="786" alt="Screenshot 2024-06-27 at 7 32 35 PM" src="https://github.com/BaBingoBango/fatigue-monitor/assets/40375449/392de63d-54b6-4321-b32f-caaba0e7821a">

Select _"Open Existing Project..."_ if you already have the code downloaded to your computer. If not, select _"Clone Git Repository..."_ and use the URL for the branch & repository you want.

You also may need to sign in to Xcode using your developer account. To do this, select Xcode > Settings in the menu bar and navigate to the Accounts tab.

## Building the App

Once you have the code open, you should see a window like this one:

![Screenshot 2024-06-27 at 7 36 12 PM](https://github.com/BaBingoBango/fatigue-monitor/assets/40375449/055b1207-0b55-4862-9b00-c888bacf67cf)

Next, click the bar at the top of the screen and select _"Any iOS Device (arm64)"_ as the destination:

![Screenshot 2024-06-27 at 7 44 23 PM](https://github.com/BaBingoBango/fatigue-monitor/assets/40375449/880041d6-19bf-43b0-be98-a9cec64b5e81)

Then, in the top menu bar, select Product > Archive. This will start the build process.

When the build process is done, the Organizer window will open! If you encounter any errors, they will appear in the left-hand sidebar.

## Uploading Using the Organizer

The Orgnanizer window looks like this:

![Screenshot 2024-06-27 at 7 46 11 PM](https://github.com/BaBingoBango/fatigue-monitor/assets/40375449/7be74162-2216-40aa-a2db-7ec077f3a72d)

Once you see this, select the build you would like to upload to App Store Connect and click _"Distribute App"_.

In the dialog that appears, select "App Store Connect". Then, follow the on-screen prompts until you reach the upload stage.

## Articles

Here are some articles that might help too!

https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/

https://designcode.io/swiftui-advanced-handbook-archive-a-build-in-xcode
