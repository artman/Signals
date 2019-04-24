import Foundation
#if os(Linux)
import Dispatch
#endif

public extension Signal {
  /// http://rxmarbles.com/#merge
  static func merge<T, U, V>(_ signalOne: Signal<T>, _ signalTwo: Signal<U>, _ signalThree: Signal<V>, retainLastData: Bool = true) -> Signal<(T?, U?, V?)> {
    return MergeSignals3(signalOne, signalTwo, signalThree)
  }

  /// http://rxmarbles.com/#combineLatest
  static func combineLatest<T, U, V>(_ signalOne: Signal<T>, _ signalTwo: Signal<U>, _ signalThree: Signal<V>, retainLatestData: Bool = true) -> Signal<(T, U, V)> {
    return CombineLatestSignals3(signalOne, signalTwo, signalThree)
  }
}

private class MergeSignals3<A, B, C>: Signal<(A?, B?, C?)> {
  private var oneLastData: A?
  private var twoLastData: B?
  private var threeLastData: C?

  let signalOne: Signal<A>
  let signalTwo: Signal<B>
  let signalThree: Signal<C>

  init(_ signalOne: Signal<A>, _ signalTwo: Signal<B>, _ signalThree: Signal<C>, retainLastData: Bool = true) {
    self.signalOne = signalOne
    self.signalTwo = signalTwo
    self.signalThree = signalThree
    super.init(retainLastData: retainLastData)

    signalOne.subscribePast(with: self) { a in
      self.oneLastData = a
      self.forwardSignal()
    }
    signalTwo.subscribePast(with: self) { b in
      self.twoLastData = b
      self.forwardSignal()
    }
    signalThree.subscribe(with: self) { c in
      self.threeLastData = c
      self.forwardSignal()
    }
  }

  private func forwardSignal() {
    self.fire((oneLastData, twoLastData, threeLastData))
  }
}

private class CombineLatestSignals3<A, B, C>: Signal<(A, B, C)> {
  private var oneLastData: A?
  private var twoLastData: B?
  private var threeLastData: C?

  let signalOne: Signal<A>
  let signalTwo: Signal<B>
  let signalThree: Signal<C>

  init(_ signalOne: Signal<A>, _ signalTwo: Signal<B>, _ signalThree: Signal<C>, retainLastData: Bool = true) {
    self.signalOne = signalOne
    self.signalTwo = signalTwo
    self.signalThree = signalThree
    super.init(retainLastData: retainLastData)

    signalOne.subscribePast(with: self) { a in
      self.oneLastData = a
      self.forwardToCombinedIfAppropriate()
    }
    signalTwo.subscribePast(with: self) { b in
      self.twoLastData = b
      self.forwardToCombinedIfAppropriate()
    }
    signalThree.subscribe(with: self) { c in
      self.threeLastData = c
      self.forwardToCombinedIfAppropriate()
    }
  }

  internal func forwardToCombinedIfAppropriate() {
    guard let oneData = oneLastData,
      let twoData = twoLastData,
      let threeData = threeLastData else { return }

    self.fire((oneData, twoData, threeData))
  }
}
