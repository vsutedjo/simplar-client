#  SimplificAR Frontend App
The Frontend App is written in Flutter. It shows the camera feed and when the user takes a photo, the image is analyzed for text. The found text is then sent to the backend using REST API, and the app awaits the response. When the simplified text returns, it is shown in the image as a replacement of the original text.



# How to run the code
Install Android Studio and the Flutter SDKs according to the Flutter install guide. 

Clone this repository and open the project in Android Studio. Connect your phone/emulator and build the project. After a while, you will be able to use the app on your device. 

Keep in mind that we are limiting access to our backend to save costs, so if you want to try it out, follow the install guide on https://github.com/sutedalm/simplar-server.
