import Foundation
#if os(Linux)
import Dispatch
#endif

public extension Signal {
  /// http://rxmarbles.com/#merge
  static func merge<T, U>(_ signalOne: Signal<T>, _ signalTwo: Signal<U>, retainLastData: Bool = true) -> Signal<(T?, U?)> {
    return MergeSignals(signalOne, signalTwo)
  }

  /// http://rxmarbles.com/#combineLatest
  static func combineLatest<T, U>(_ signalOne: Signal<T>, _ signalTwo: Signal<U>, retainLatestData: Bool = true) -> Signal<(T, U)> {
    return CombineLatestSignals(signalOne, signalTwo)
  }
}

private class CombineLatestSignals<A, B>: Signal<(A, B)> {
  private var oneLastData: A? = .none
  private var twoLastData: B? = .none

  let signalOne: Signal<A>
  let signalTwo: Signal<B>

  init(_ signalOne: Signal<A>, _ signalTwo: Signal<B>, retainLastData: Bool = true) {
    self.signalOne = signalOne
    self.signalTwo = signalTwo
    super.init(retainLastData: retainLastData)

    signalOne.subscribePast(with: self) { a in
      self.oneLastData = a
      self.forwardToCombinedIfAppropriate()
    }
    signalTwo.subscribePast(with: self) { b in
      self.twoLastData = b
      self.forwardToCombinedIfAppropriate()
    }
  }

  internal func forwardToCombinedIfAppropriate() {
    guard let oneData = oneLastData, let twoData = twoLastData else { return }

    self.fire((oneData, twoData))
  }
}

private class MergeSignals<A, B>: Signal<(A?, B?)> {
  private var oneLastData: A? = .none
  private var twoLastData: B? = .none

  let signalOne: Signal<A>
  let signalTwo: Signal<B>

  init(_ signalOne: Signal<A>, _ signalTwo: Signal<B>, retainLastData: Bool = true) {
    self.signalOne = signalOne
    self.signalTwo = signalTwo
    super.init(retainLastData: retainLastData)

    signalOne.subscribePast(with: self) { a in
      self.oneLastData = a
      self.forwardSignal()
    }
    signalTwo.subscribePast(with: self) { b in
      self.twoLastData = b
      self.forwardSignal()
    }
  }

  private func forwardSignal() {
    self.fire((oneLastData, twoLastData))
  }
}
