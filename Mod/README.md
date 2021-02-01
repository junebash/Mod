# Mod

Mod is a tiny library for functional styling in Swift.

What does that mean?

I'm sure you've gone through the pain of using UIKit, writing tons of subclasses, writing the same or similar boilerplate in all your view controllers.

```
let button: UIButton = {
  let b = UIButton()
  b.setTitle("Button", for: .normal)
  b.layer.borderWidth = 1
  b.layer.borderColor = UIColor.black.cgColor
  b.layer.cornerRadius = 8
  b.layer.shadowColor = UIColor.gray.cgColor
  b.layer.shadowRadius = 1
  return b
}()
```

`Mod` provides an easy way to break apart your various view styles (or other modifiers) into reusable components that can be mixed and matched.

At its base, the `Mod` type is just a wrapper around a closure that applies a modification to a provided item. But it can also provide a convenient namespace and API for reusability and composition of stylings. It even comes with some custom operators that make for a convenient and readable DSL.
```
extension Mod where Item: UIButton {
  static func shadow(/* ... */) -> Mod {
    Mod { /* ... */ }
  }
  static func roundedCorners(radius: CGFloat = 8) -> Mod {}
  static func border(color: UIColor = .black, width: CGFloat = 1) -> Mod {}
  static func title(_ titleText: String) -> Mod { /* ... */ }
}

let button = UIButton()
  |=> .title("Button")
  <> .border(color: .black)
  <> .roundedCorners()
  <> .shadow()
```
Alternatively, if you're allergic to new operators:
```
let button = Mod.concatenate(
  .title("Button"),
  .border(color: .black),
  .roundedCorners(),
  .shadow()
).applied(to: UIButton())
```
or
```
let button = configure(UIButton(), with: .concatenate(
  .title("Button"),
  .border(color: .black),
  .roundedCorners(),
  .shadow()
))
```

For further discussion and the inital inspiration, see [this article](http://jonbash.com/blog/composable-styling/). Also inspired by one of [Pointfree](https://www.pointfree.co/)'s first episodes on [UIKit Styling with Functions](https://www.pointfree.co/episodes/ep3-uikit-styling-with-functions).

