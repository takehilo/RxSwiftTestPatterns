import RxSwift

@testable import RxSwiftTestPatterns
import Quick
import Nimble
import RxTest
import RxBlocking

class BasicPatterns: QuickSpec {
    override func spec() {
        var scheduler: TestScheduler!
        let disposeBag = DisposeBag()
    
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
        }
        
        it("HotObservable + start") {
            let xs = scheduler.createHotObservable([
                Recorded.next(110, 10),
                Recorded.next(210, 20),
                Recorded.next(310, 30)
            ])
            
            let res = scheduler.start(created: 100, subscribed: 200, disposed: 1000) {
                xs.map { $0 * 2 }
            }
            
            expect(res.events).to(equal([
                Recorded.next(210, 40),
                Recorded.next(310, 60)
            ]))
        }
        
        it("ColdObservable + start") {
            let xs = scheduler.createColdObservable([
                Recorded.next(110, 10),
                Recorded.next(210, 20),
                Recorded.next(310, 30)
            ])
            
            let res = scheduler.start(created: 100, subscribed: 200, disposed: 1000) {
                xs.map { $0 * 2 }
            }
            
            expect(res.events).to(equal([
                Recorded.next(310, 20),
                Recorded.next(410, 40),
                Recorded.next(510, 60)
            ]))
        }
        
        it("HotObservable + scheduleAt + start") {
            let xs = scheduler.createHotObservable([
                Recorded.next(110, 10),
                Recorded.next(210, 20),
                Recorded.next(310, 30)
            ])
            
            let observer = scheduler.createObserver(Int.self)
            
            scheduler.scheduleAt(200) {
                xs.map { $0 * 2 }.subscribe(observer).disposed(by: disposeBag)
            }
            
            scheduler.start()

            expect(observer.events).to(equal([
                Recorded.next(210, 40),
                Recorded.next(310, 60)
            ]))
        }
        
        it("ColdObservable + scheduleAt + start") {
            let xs = scheduler.createColdObservable([
                Recorded.next(110, 10),
                Recorded.next(210, 20),
                Recorded.next(310, 30)
            ])
            
            let observer = scheduler.createObserver(Int.self)
            
            scheduler.scheduleAt(200) {
                xs.map { $0 * 2 }.subscribe(observer).disposed(by: disposeBag)
            }
            
            scheduler.start()
            
            expect(observer.events).to(equal([
                Recorded.next(310, 20),
                Recorded.next(410, 40),
                Recorded.next(510, 60)
            ]))
        }
        
        it("Blocking") {
            // 非同期にイベントが発行されるObservable
            let observable = Observable.of(10, 20, 30)
                .map { $0 * 2 }
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    
            let blocking = observable.toBlocking()
    
            expect(try! blocking.first()).to(equal(20))
            expect(try! blocking.last()).to(equal(60))
            expect(try! blocking.toArray()).to(equal([20, 40, 60]))
            expect { try blocking.single() }.to(throwError(RxError.moreThanOneElement))
    
            let materialized = blocking.materialize()
            if case let .completed(elements) = materialized {
                expect(elements).to(equal([20, 40, 60]))
            } else {
                fail("expected completed but got \(materialized)")
            }
        }
        
        xit("Don't do this") {
            let xs = scheduler.createHotObservable([
                Recorded.next(110, 10),
                Recorded.next(210, 20),
                Recorded.next(310, 30),
                Recorded.completed(40)
            ])
            
            // ブロックされたままになりテストが終了しない
            expect(try! xs.toBlocking().toArray()).to(equal([10, 20, 30]))
        }
    }
}
