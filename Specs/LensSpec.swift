//
//  LensSpec.swift
//  Pistachio
//
//  Created by Robert Böhnke on 1/17/15.
//  Copyright (c) 2015 Robert Böhnke. All rights reserved.
//

import Monocle

import Quick
import Nimble

struct Inner: Equatable {
    var count: Int
}

func == (lhs: Inner, rhs: Inner) -> Bool {
    return lhs.count == rhs.count
}

struct Outer: Equatable {
    var count: Int

    var inner: Inner

    init(count: Int = 0, inner: Inner = Inner(count: 0)) {
        self.count = count
        self.inner = inner
    }
}

func == (lhs: Outer, rhs: Outer) -> Bool {
    return lhs.count == rhs.count && lhs.inner == rhs.inner
}

struct OuterLenses {
    static let count = Lens<Outer, Int>(get: { $0.count }, set: { (inout outer: Outer, count) in
        outer.count = count
    })

    static let inner = Lens<Outer, Inner>(get: { $0.inner }, set: { (inout outer: Outer, inner) in
        outer.inner = inner
    })
}

struct InnerLenses {
    static let count = Lens<Inner, Int>(get: { $0.count }, set: { (inout inner: Inner, count) in
        inner.count = count
    })
}

class LensSpec: QuickSpec {
    override func spec() {
        describe("A Lens") {
            let example: Outer = Outer(count: 2)

            let count = OuterLenses.count

            it("should get values") {
                expect(get(count, a: example)!).to(equal(2))
            }

            it("should set values") {
                expect(set(count, a: example, b: 4)).to(equal(Outer(count: 4)))
            }

            it("should modify values") {
                expect(mod(count, a: example, f: { $0 + 2 })).to(equal(Outer(count: 4)))
            }
        }

        describe("A composed Lens") {
            let example = Outer(count: 0, inner: Inner(count: 2))

            let innerCount = OuterLenses.inner >>> InnerLenses.count

            it("should get values") {
                expect(get(innerCount, a: example)!).to(equal(2))
            }

            it("should set values") {
                expect(set(innerCount, a: example, b: 4)).to(equal(Outer(count: 0, inner: Inner(count: 4))))
            }

            it("should modify values") {
                expect(mod(innerCount, a: example, f: { $0 + 2 })).to(equal(Outer(count: 0, inner: Inner(count: 4))))
            }
        }

        describe("Lifted lenses") {
            context("for arrays") {
                let inner = [
                    Inner(count: 1),
                    Inner(count: 2),
                    Inner(count: 3),
                    Inner(count: 4)
                ]

                let lifted = lift(InnerLenses.count)

                it("should get values") {
                    let result = get(lifted, a: inner)

                    expect(result).to(equal([ 1, 2, 3, 4 ]))
                }

                it("should set values") {
                    let result = set(lifted, a: inner, b: [ 2, 4, 6, 8 ])

                    expect(result).to(equal([
                        Inner(count: 2),
                        Inner(count: 4),
                        Inner(count: 6),
                        Inner(count: 8)
                    ]))
                }

                it("should reduce the resulting array size accordingly") {
                    // Does this make sense?
                    let result = set(lifted, a: inner, b: [ 42 ])

                    expect(result).to(equal([
                        Inner(count: 42)
                    ]))
                }
            }
        }

        describe("Split lenses") {
            let outer = Outer(count: 2, inner: Inner(count: 4))
            let inner = Inner(count: 9)

            let both = OuterLenses.count *** InnerLenses.count

            it("should get values") {
                let result = get(both, a: (outer, inner))

                expect(result.0).to(equal(2))
                expect(result.1).to(equal(9))
            }

            it("should set values") {
                let result = set(both, a: (outer, inner), b: (12, 34))

                expect(result.0.count).to(equal(12))
                expect(result.0.inner.count).to(equal(4))
                expect(result.1.count).to(equal(34))
            }
        }

        describe("Fanned out lenses") {
            let example = Outer(count: 0, inner: Inner(count: 2))

            let both = OuterLenses.count &&& (OuterLenses.inner >>> InnerLenses.count)

            it("should get values") {
                let result = get(both, a: example)

                expect(result.0).to(equal(0))
                expect(result.1).to(equal(2))
            }

            it("should set values") {
                let result = set(both, a: example, b: (12, 34))

                expect(result.count).to(equal(12))
                expect(result.inner.count).to(equal(34))
            }
        }
    }
}
