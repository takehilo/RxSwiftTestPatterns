import RxSwift
import RxCocoa

class LoginViewModel {
    let email = BehaviorRelay<String>(value: "")

    var isValidEmail: Driver<Bool> {
        return email.asDriver().map { !$0.isEmpty }
    }
}
