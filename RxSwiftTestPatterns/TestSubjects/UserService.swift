import Alamofire
import RxSwift

struct User: Decodable, Equatable {
    let id: Int
    let name: String
}

class UserService {
    func fetchUser(by userId: Int) -> Single<User> {
        return Single.create { single in
            Alamofire.request("https://api.example.com/users/\(userId)").responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        let user = try JSONDecoder().decode(User.self, from: data)
                        single(.success(user))
                    } catch {
                        single(.error(error))
                    }
                case let .failure(error):
                    single(.error(error))
                }
            }
            
            return Disposables.create()
        }
    }
}
