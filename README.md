![image (4)](https://github.com/inventhq/dot-globe/assets/69051988/44fd8847-66ea-43ca-84dd-1865a6ddb53b)
# dot-globe

A SceneKit and Metal Powered interactive globe for UIKit and SwiftUI
## Features

- Display an interactive 3D globe
- Customize the appearance of the globe, including earth color, glow color, and reflection color etc.
- Control the radius of the earth and size of the dots on the globe.
- Enable/disable particle effects, such as stars.
- Works with SwiftUI.

## TODOs:
- Add animation and interaction with the globe -- Working on
- Add country grouping and add necessary methods to SwiftUI and UIKit

# Showroom
https://github.com/inventhq/dot-globe/assets/69051988/63a86a5a-8994-4b4d-ae23-8aba5ec9777a

# Usage

## UIKit

```swift
import UIKit
import DotGlobe

class ViewController: UIViewController {
    override func viewDidLoad() {
      // initialize controller here
       let globeController = GlobeViewController()
       globeController.earthColor = UIColor(red: 0.0, green: 0.482, blue: 0.871, alpha: 1.0)
       globeController.glowColor = UIColor(red: 0.0, green: 0.22, blue: 0.482, alpha: 1.0)
       globeController.reflectionColor =  UIColor(red: 0.0, green: 0.482, blue: 0.871, alpha: 1.0)
        
       present(globeController, animated: true, completion: nil)
    }
}
```
![Screenshot 2023-05-25 at 14 50 06](https://github.com/inventhq/dot-globe/assets/69051988/0477fd22-13d2-4a0c-84f1-7ff3295f1722)

Customization:
- dotCount: Amounts of dots used to draw the earth map, adjust it for your needs
- earthRadius: Adjusts the radius of the earth in the globe.
- dotSize: Sets the size of the dots displayed on the globe, by default, it is 0.005.
- enablesParticles: Enables or disables particle effects, by default, background is starry.
- particles: Sets the particle system for the globe's background.
- background
- earthNode: You can directly access to the earthNode to customize the earth itself
- earthColor: Sets the color of the earth on the globe.
- glowColor: Sets the color of the earth's glow effect.
- reflectionColor: Sets the color of the earth's reflection effect.
- glowShininess: Adjusts the shininess of the earth's glow effect.

## SwiftUI 

```swift
import SwiftUI
import DotGlobe

struct ContentView: View {
    var body: some View {
        GlobeView()
    }
}
```
