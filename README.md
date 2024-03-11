# HarvardArt
HarvardArt displays art pieces from the [Harvard Art Museum API](https://github.com/harvardartmuseums/api-docs?tab=readme-ov-file). It's a multi-platform project so you can download and build and run the app locally for any supported device (iOS, macOS). The project uses environment variables for the API key; more information on the Harvard Art Museum API key can be found [here](https://api-toolkit.herokuapp.com/4).

The an app built in SwiftUI to demonstrate [CAP (Composable Architecture Pattern)](https://github.com/jonnyholland/ComposableArchitecturePattern) *(To understand more details of CAP, please visit the repository)*. 

The idea is for the app to be super composable, follow generally accepted programming guidelines (such as separation of concerns, etc), and be super fast and responsive - hopefully that is quickly noticable. Although an overall basic application, it highlights how you can scale a SwiftUI appliation without having to depend or use any library or framework. The CAP package does include a very lightweight library that is designed to be more protocol driven rather than object driven. This allows you as the developer to customize and dictate how the implementation is actually done. 

## iPad
|Split View| List |
| --- | --- |
| ![Simulator Screenshot - iPad Pro (12 9-inch) (6th generation) - 2024-03-10 at 20 07 43](https://github.com/jonnyholland/HarvardArt/assets/26751945/c5d46ab8-2e2c-487f-a477-1cad51d29f11) | ![Simulator Screenshot - iPad Pro (12 9-inch) (6th generation) - 2024-03-10 at 20 08 11](https://github.com/jonnyholland/HarvardArt/assets/26751945/d209acb4-eafb-480d-9ce6-570d422a915a) |

## macOS
| Split View | List |
| --- | --- |
| ![Screenshot 2024-03-10 at 8 12 34 PM](https://github.com/jonnyholland/HarvardArt/assets/26751945/78ab42c7-9fe5-4045-96b6-493fd5b6a474) | ![Screenshot 2024-03-10 at 8 13 11 PM](https://github.com/jonnyholland/HarvardArt/assets/26751945/24817559-49b6-474e-8331-f5e0a042faff) |

# Structure
Every app should have a control system. For this app, the main control system is `Application`. This class provides the main view. All initial setup can be found in `HarvardArtMuseumsApp`'s `-init`.

To ensure separation of concerns, this app uses a protocol approach for views where data sources are needed and all the views are correlated to an `enum` that acts as the holder for the feature and functionality. All features have `Actions` that dictate all actions supported for the feature (there can be multiple actions for a feature/view. I chose a single actions enum for simplicity). This ensures that any of the views used can be tested thoroughly (because all user based "main" actions flow through the closure<sup>1</sup>) but also makes the view very reusable.

You may notice that the main objects that display and control functionality inherit from a protocol called [`ViewCoordinator`](https://github.com/jonnyholland/ComposableArchitecturePattern/blob/main/Sources/ComposableArchitecturePattern/ViewCoordinator.swift). This borrows from some terminology Apple has used since early on in SwiftUI when you needed a "Coordinator` for advanced functionality in `UIViewRepresentable`s or `NSViewRepresentable`s. The view coordinator's main function is to...well, coordinate. It should coordinate between the model, view, and any networking or other additional functionality the view/you may need. This protocol is part of CAP.

All networking occurs through actors conforming to [`Server`](https://github.com/jonnyholland/ComposableArchitecturePattern/blob/main/Sources/ComposableArchitecturePattern/Server.swift) that use [`ServerAPI`s](https://github.com/jonnyholland/ComposableArchitecturePattern/blob/main/Sources/ComposableArchitecturePattern/Server%2BAPI.swift) for knowing how to communicate to backend servers *(both protocols provided by CAP)*.

#Footnotes
<sup>1: It may be best for some user actions to be handled in the view, such as sorting, filtering, etc, while other, more important actions, to be handled in the action handler closure. Again, the point is testability and reusability.</sup>
