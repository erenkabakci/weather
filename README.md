# weather
A dead-simple weather preview app, showing the current weather forecast for the user's location *(with a beautiful(!) UI)* 🎊

## Getting Started
Just hit the "Run" button in Xcode 🔨
  - Do not forget to set/change the 'location simulation" in Xcode, if you are running on a simulator and want to see results, also for different cities ⚠️
  
### UI States
Although the UI speaks for itself, there are two UI states visible in the app.
  1. Error mode where the error message and "Retry" button appears in case of a location/internet connection issue. ⛔️
  2. Success mode where the forecast details can be seen. 🌤

## Technical Details
- Due to the simplicity of the app, no external dependencies are used. 🧩
- The architecture mostly fits to the MVP pattern with a tiny resemblance of MVVM. It can be easily iterated through VIPER based on the further needs. 🏛
- No IB/Storyboards have been used. 🎨
- There is a comprehensive unit test suite for the business logic. 🧪 
