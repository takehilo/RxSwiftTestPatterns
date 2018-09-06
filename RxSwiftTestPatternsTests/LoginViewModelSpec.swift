import RxSwift
import RxCocoa

@testable import RxSwiftTestPatterns
import Quick
import Nimble
import RxTest

class LoginViewModelSpec: QuickSpec {
    override func spec() {
        var scheduler: TestScheduler!
        var loginViewModel: LoginViewModel!

        let disposeBag = DisposeBag()

        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            loginViewModel = LoginViewModel()
        }

        describe("isValidEmail") {
            it("should be true when email is not empty") {
                let xs = scheduler.createHotObservable([
                    Recorded.next(10, ""),
                    Recorded.next(20, "a@example.com"),
                    Recorded.next(30, "")
                ])

                xs.bind(to: loginViewModel.email).disposed(by: disposeBag)

                let observer = scheduler.createObserver(Bool.self)
                loginViewModel.isValidEmail.drive(observer).disposed(by: disposeBag)

                scheduler.start()

                expect(observer.events).to(equal([
                    Recorded.next(0, false),
                    Recorded.next(10, false),
                    Recorded.next(20, true),
                    Recorded.next(30, false)
                ]))
            }
        }
        
        describe("isValidForm") {
            it("should be true when both email and password are valid") {
                let xs1 = scheduler.createHotObservable([
                    Recorded.next(10, ""),
                    Recorded.next(30, "a@example.com"),
                    Recorded.next(50, "")
                ])
                
                let xs2 = scheduler.createHotObservable([
                    Recorded.next(20, ""),
                    Recorded.next(40, "passw0rd"),
                    Recorded.next(60, "")
                ])
                
                xs1.bind(to: loginViewModel.email).disposed(by: disposeBag)
                xs2.bind(to: loginViewModel.password).disposed(by: disposeBag)
                
                let observer = scheduler.createObserver(Bool.self)
                loginViewModel.isValidForm.drive(observer).disposed(by: disposeBag)
                
                scheduler.start()
                
                expect(observer.events).to(equal([
                    Recorded.next(0, false),
                    Recorded.next(10, false),
                    Recorded.next(20, false),
                    Recorded.next(30, false),
                    Recorded.next(40, true),
                    Recorded.next(50, false),
                    Recorded.next(60, false)
                ]))
            }
        }
    }
}
