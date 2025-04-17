# ImageCarousel

Carousel - Swift

## Features
* ***Infinite*** scrolling
* ***Automatic*** scrolling
* SwiftUI support

### Configuration Options

- `itemSize`: CGSize - Size of each item in the carousel. Default is CollectionViewSize
- `interItemSpacing`: CGFloat - Spacing between carousel items. Default is 0
- `isInfinite`: Bool - Whether to enable infinite carousel. Default is false
- `autoScrollInterval`: TimeInterval - Setting a value greater than 0 will automatically scroll the carousel at that interval in seconds. Default is 0

**e.g**

```swift
carousel.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.80, height: 300)
carousel.interItemSpacing = 8.0
carousel.isInfinite = true
carousel.autoScrollInterval = 3.0
```

## How to use UIKit
Import `ImageCarousel` to use.

### 1. First

```swift
import ImageCarousel

let carousel = ImageCarousel()
carousel.dataSource = self
carousel.delegate = self
// Register CollectionViewCell containing the ImageView you want to display
carousel.register(ImageCarouselCell.self, forCellWithReuseIdentifier: "cell")
view.addSubview(carousel)
```

### 2. Implement LoopImageCarouselDataSource

```swift
    func numberOfItems(in imageCarousel: ImageCarousel) -> Int {
        carouselImages.count
    }
    
    func imageCarousel(_ imageCarousel: ImageCarousel, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = carousel.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! ImageCarouselCell
        cell.imageView?.image = carouselImages[index].image
        return cell
    }
```

### 3. Implement LoopImageDelegate

```swift 
    func imageCarousel(_ imageCarousel: ImageCarousel, didSelectItemAt index: Int)
```
> Delegate method called when an item is tapped

```swift 
    func imageCarousel(_ imageCarousel: ImageCarousel, didChangeItemAt index: Int)
```
> Delegate method called when an item changes

## How to use SwiftUI
Import `ImageCarousel` to use.

```swift
import ImageCarousel

private let data = ["1", "2", "3"]

var body: some View {
    Carousel(data) { element in
        Image(element)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(8.0)
    }
    .isInfinite(true) // Whether to enable infinite carousel
    .itemSize(CGSize(width: geometry.size.width * 0.80, height: geometry.size.height)) // itemSize
    .interItemSpacing(8.0) // Spacing between items
    .autoScrollInterval(3.0) // Auto-scroll interval
}
```

## Installation
Edit your `Package.swift` to install.

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/Yudai-ASANO/ImageCarousel", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "<your-target-name>",
            dependencies: ["ImageCarousel"]),
    ]
)
```
