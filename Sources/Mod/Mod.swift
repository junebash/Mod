/// Applies the provided `Mod` to a copy of the provided `Item` and returns the modified copy.
///
/// Essentially a convenience API for `Mod.apply` that may be more readable in some circumstances.
///
/// ```
/// let button = configure(UIButton(), with: .concatenate(
///   .title("Button"),
///   .border(color: .black),
///   .roundedCorners(),
///   .shadow()
/// ))
/// ```
public func configure<Item>(_ item: Item, with mod: Mod<Item>) -> Item {
  mod.applied(to: item)
}


/// Wraps a closure that applies a modification to a provided item.
///
/// Can provide a convenient namespace and API for reusability and composition of stylings.
///
/// ```
/// extension Mod where Item: UIButton {
///   static func shadow(/* ... */) -> Mod {
///     Mod { /* ... */ }
///   }
///
///   static func roundedCorners(radius: CGFloat = 8) -> Mod {}
///
///   static func border(color: UIColor = .black, width: CGFloat = 1) -> Mod {}
///
///   static func title(_ titleText: String) -> Mod { /* ... */ }
/// }
///
/// let button = UIButton()
///   |=> .title("Button")
///   <> .border(color: .black)
///   <> .roundedCorners()
///   <> .shadow()
/// ```
///
/// Alternatively,
///
/// ```
/// let button = Mod.concatenate(
///   .title("Button"),
///   .border(color: .black),
///   .roundedCorners(),
///   .shadow()
/// ).applied(to: UIButton())
/// ```
///
/// Compare this to the usual method for this sort of thing:
///
/// ```
/// let button: UIButton = {
///   let b = UIButton()
///   b.setTitle("Button", for: .normal)
///   b.layer.borderWidth = 1
///   b.layer.borderColor = UIColor.black.cgColor
///   b.layer.cornerRadius = 8
///   b.layer.shadowColor = UIColor.gray.cgColor
///   b.layer.shadowRadius = 1
///   return b
/// }()
/// ```
///
/// For further discussion and the inital inspiration, see [this article](http://jonbash.com/blog/composable-styling/).
public struct Mod<Item> {
  public typealias Block = (inout Item) -> Void

  private var _apply: Mod.Block

  /// Initiate a new Mod using the provided closure, which modifies a given `Item` in some way.
  public init(_ apply: @escaping Mod.Block) {
    self._apply = apply
  }

  public func apply(to object: Item) where Item: AnyObject {
    _ = applied(to: object)
  }

  /// Applies the Mod closure to the provided item.
  public func apply(to item: inout Item) {
    _apply(&item)
  }

  /// Copies the provided item, applies the Mod closure, and returns the mutated copy.
  public func applied(to item: Item) -> Item {
    var copy = item
    apply(to: &copy)
    return copy
  }

  /// Calls `apply(to:&)` on the provided item.
  public func callAsFunction(_ item: inout Item) {
    apply(to: &item)
  }

  /// Calls `applied(to:)` on the provided item.
  public func callAsFunction(_ item: Item) -> Item {
    applied(to: item)
  }
}

public extension Mod {

  // MARK: - Convenience

  /// Initializes a new Mod where each mod in the provided sequence is performed consecutively.
  static func concatenate<S: Sequence>(_ mods: S) -> Mod where S.Element == Mod {
    Mod { item in
      mods.forEach { $0.apply(to: &item) }
    }
  }

  /// Initializes a new Mod where each mod in the provided sequence is performed consecutively.
  static func concatenate(_ mods: Mod...) -> Mod {
    .concatenate(mods)
  }

  /// After applying the current `apply` closure, call the provided closures consecutively.
  mutating func append(_ others: (Mod.Block)...) {
    let oldApply = _apply
    self._apply = { item in
      oldApply(&item)
      others.forEach { $0(&item) }
    }
  }

  /// After applying the current `apply` closure, call the provided `Mod`s' closures consecutively.
  mutating func append(_ otherMods: Mod...) {
    let oldApply = _apply
    self._apply = { item in
      oldApply(&item)
      otherMods.forEach { $0.apply(to: &item) }
    }
  }

  /// Returns a new `Mod` with the current `apply` closure followed by each of the provided closures.
  func appending(_ others: (Mod.Block)...) -> Mod {
    Mod { item in
      self.apply(to: &item)
      others.forEach { $0(&item) }
    }
  }

  /// Returns a new `Mod` with the current `apply` closure followed by each of the provided `Mod`s' closures.
  func appending<S: Sequence>(_ otherMods: S) -> Mod where S.Element == Mod {
    Mod { item in
      self.apply(to: &item)
      otherMods.forEach { $0.apply(to: &item) }
    }
  }

  /// Returns a new `Mod` with the current `apply` closure followed by each of the provided `Mod`s' closures.
  func appending(_ otherMods: Mod...) -> Mod {
    self.appending(otherMods)
  }

  // MARK: - Operators

  /// Composes two `Mod`s' closures together.
  /// - Parameters:
  ///   - lhs: A `Mod` of any item.
  ///   - rhs: Another `Mod` of the same item type.
  /// - Returns: a `Mod` consisting of the left-hand side's `apply` closure followed by the right-hand side's.
  static func <> (_ lhs: Mod, _ rhs: Mod) -> Mod {
    Mod { item in
      lhs(&item)
      rhs(&item)
    }
  }

  /// Composes two `Mod`s' closures together.
  /// - Parameters:
  ///   - lhs: A `Mod` of any item.
  ///   - rhs: A closure that takes the same `inout Item` as the left hand side's `Mod`.
  /// - Returns: a `Mod` consisting of the left-hand side's `apply` closure followed by the right-hand side's.
  static func <> (_ lhs: Mod, _ rhs: @escaping Mod.Block) -> Mod {
    Mod { item in
      lhs(&item)
      rhs(&item)
    }
  }

  /// Composes two `Mod`s' closures together.
  /// - Parameters:
  ///   - lhs: A closure that takes the same `inout Item` as the right hand side's `Mod`.
  ///   - rhs: A `Mod` of any item.
  /// - Returns: a `Mod` consisting of the left-hand side's `apply` closure followed by the right-hand side's.
  static func <> (_ lhs: @escaping Mod.Block, _ rhs: Mod) -> Mod {
    Mod { item in
      lhs(&item)
      rhs(&item)
    }
  }

  /// Applies the right-hand `Mod`'s closure to the left hand item, mutating it in place.
  /// - Parameters:
  ///   - item: an `inout` item to be mutated by the `Mod`
  ///   - mod: a `Mod` wrapping a closure which mutates the item in place.
  ///
  /// ```
  /// func updateViews() {
  ///   UIView.animate(withDuration: 0.2) {
  ///     if showingControls {
  ///       button.isHidden = false
  ///       button => .shadow(radius: 10) <> .border(color: .green)
  ///     } else {
  ///       button.isHidden = true
  ///       button => .shadow(radius: 0) <> .border(color: .clear)
  ///     }
  ///   }
  /// }
  /// ```
  static func => (_ item: Item, _ mod: Mod<Item>) where Item: AnyObject {
    _ = mod.applied(to: item)
  }

  /// Applies the right-hand `Mod`'s closure to the left hand item, mutating it in place.
  /// - Parameters:
  ///   - item: an `inout` item to be mutated by the `Mod`
  ///   - mod: a `Mod` wrapping a closure which mutates the item in place.
  ///
  /// ```
  /// func updateViews() {
  ///   UIView.animate(withDuration: 0.2) {
  ///     if showingControls {
  ///       button.isHidden = false
  ///       button => .shadow(radius: 10) <> .border(color: .green)
  ///     } else {
  ///       button.isHidden = true
  ///       button => .shadow(radius: 0) <> .border(color: .clear)
  ///     }
  ///   }
  /// }
  /// ```
  static func => (_ item: inout Item, _ mod: Mod<Item>) {
    mod.apply(to: &item)
  }

  /// Calls the right hand `Mod`'s `applied(to:)` method on the left hand item, which copies the item,
  /// modifies it using the `Mod`'s `apply` closure, and returns that copy.
  /// - Parameters:
  ///   - item: an item to be copied and modified
  ///   - mod: a `Mod` which wraps a closure which mutates a copy of the given item.
  /// - Returns: A copy of the provided item with the `Mod`'s closure applied.
  @discardableResult static func |=> (_ item: Item, _ mod: Mod) -> Item {
    mod.applied(to: item)
  }
}

// MARK: - Transform

public extension Mod {
  /// Apply a mod that works at a level to a more "global" item.
  ///
  /// ```
  /// struct Person {
  ///   var name: String
  /// }
  /// var person = Person(name: "June")
  /// let allCapsName: Mod<Person> = Mod { $0 = $0.uppercased() }.pullback(\.name)
  /// person => allCapsName
  /// print(person.name) // "JUNE"
  /// ```
  func pullback<NewRoot>(_ keyPath: WritableKeyPath<NewRoot, Item>) -> Mod<NewRoot> {
    Mod<NewRoot> { root in
      var item = root[keyPath: keyPath]
      self(&item)
      root[keyPath: keyPath] = item
      self(&root[keyPath: keyPath])
    }
  }

  /// A version of `pullback` that applies this `Mod` to every item at the given keyPath.
  ///
  /// ```
  /// class Person {
  ///   var name: String
  ///   var friends: [Person] = []
  ///
  ///   init(name: String) { self.name = name }
  /// }
  ///
  /// let june = Person(name: "June")
  /// june.friends = [Person(name: "Elie"), Person(name: "Aria")]
  /// let uppercaseFriends: Mod<Person> = Mod { $0 = $0.uppercased() }.pullback(\.name).forEach(\.friends)
  /// june => uppercaseFriends // "ELIE", "ARIA"
  /// ```
  func forEach<Root>(_ toItems: WritableKeyPath<Root, [Item]>) -> Mod<Root> {
    Mod<Root> { root in
      root[keyPath: toItems] = root[keyPath: toItems].map(self.applied(to:))
    }
  }
}
