import Mod
import UIKit


struct Person {
  var name: String
  var age: Int
  var career: String

  func getThing() -> String { String(age) }
}

var jon = Person(name: "Jon", age: 30, career: "Composer")
print(jon)

let myMod: Mod<Person> = .init {
    $0.name = "June"
    $0.age = 31
    $0.career = "iOS Developer"
}

let june = jon |=> myMod

let upper: Mod<String> = Mod { $0 = $0.uppercased() }

let upperName: Mod<Person> = upper.pullback(\.name)

var person = Person(name: "blob", age: 78, career: "")
person => upperName
print(person.name) 


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

extension Mod where Item: UIButton {
    static func title(_ text: String) -> Self {
        Mod { $0.setTitle(text, for: .normal) }
    }
    static func border(color: UIColor) -> Self {
        Mod { $0.layer.borderColor = color.cgColor }
    }
    static func roundedCorners() -> Self {
        Mod { $0.layer.cornerRadius = 8 }
    }
    static func shadow() -> Self {
        Mod { $0.layer.shadowRadius = 2 }
    }
}

let button2 = configure(UIButton(), with: .concatenate(
  .title("Button"),
  .border(color: .black),
  .roundedCorners(),
  .shadow()
))
