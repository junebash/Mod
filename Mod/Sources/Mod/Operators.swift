precedencegroup ForwardApplicationPrecedence
{
  associativity: left
  higherThan: AssignmentPrecedence
  lowerThan: NilCoalescingPrecedence
}

precedencegroup CombinatorialCompositionPrecedence {
  higherThan: ForwardApplicationPrecedence
  associativity: left
}

infix operator =>: ForwardApplicationPrecedence // mutate in place
infix operator |=>: ForwardApplicationPrecedence // copy; mutate; return copy
infix operator <>: CombinatorialCompositionPrecedence
