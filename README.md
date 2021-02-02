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
extension Mod where Item: UIView {
  static func shadow(
    radius: CGFloat = 1,
    offset: CGSize = CGSize(width: 0, height: 1),
    color: UIColor = UIColor.black,
    opacity: Float = 0.6
  ) -> Self {
    Mod {
      $0.layer.shadowRadius = radius
      $0.layer.shadowColor = color.cgColor
      $0.layer.shadowOffset = offset
      $0.layer.shadowOpacity = opacity
    }
  }

  static func border(
    color: UIColor?,
    width: CGFloat = 1
  ) -> Self {
    Mod {
      $0.layer.borderColor = color?.cgColor
      $0.layer.borderWidth = width
    }
  }

  static func roundedCorners(
    radius: CGFloat = 8,
    curve: CALayerCornerCurve = .continuous
  ) -> Self {
    Mod {
      $0.layer.cornerRadius = radius
      $0.layer.cornerCurve = curve
    }
  }
}

extension Mod where Item: UIButton {
  static func title(_ text: String) -> Self {
    Mod { $0.setTitle(text, for: .normal) }
  }
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

You could even combine these Mods into its own standard, app-wide, reusable style you can use throughout your codebase, or combine mods from superclasses. You can use it to configure table view cells, or date formatters, or perform state transformations... the possibilities are endless!

For further discussion and the inital inspiration, see [this article](http://jonbash.com/blog/composable-styling/). Also inspired by one of [Pointfree](https://www.pointfree.co/)'s first episodes on [UIKit Styling with Functions](https://www.pointfree.co/episodes/ep3-uikit-styling-with-functions).

