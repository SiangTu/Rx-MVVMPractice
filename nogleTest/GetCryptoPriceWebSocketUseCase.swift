//
//  GetCryptoPriceWebSocketUseCase.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/23.
//

import Foundation
import RxCocoa
import RxSwift
import Combine
class foo {
    var a: BehaviorRelay<Int>?
    func get() -> Observable<Int>? {
        a = BehaviorRelay<Int>(value: 0)
        return a?.asObservable()
    }
}
class GetCryptoPriceWebSocketUseCase: NSObject {
    
    struct ResponseValue: Decodable {
        struct dictionaryValue: Decodable {
            let id: String
            let price: Double
        }
        let data: [String: dictionaryValue]
    }
    var bag = DisposeBag()
    func execute() async throws -> Published<[String: CryptoModel]>.Publisher {
        let fo = foo()
        let p = fo.get()
        p?.subscribe(onNext: { value in
            print("recive: \(value)")
        }).disposed(by: bag)
        fo.a?.accept(10)
        fo.a?.accept(100)
//        try await connect()
//        sendMessage()
//        subscribe()
        return $cryptoModelDict
    }
    
    private var webSocketTask: URLSessionWebSocketTask?

    @Published
    private var cryptoModelDict: [String: CryptoModel] = [:]
    
    private var conneceContinuation: CheckedContinuation<Void, Error>?
    
    private func connect() async throws {
        guard let url = URL(string: "wss://ws.btse.com/ws/futures") else {
            throw WebError.urlInvalid
        }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let request = URLRequest(url: url)
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        return try await withCheckedThrowingContinuation { continuation in
            self.conneceContinuation = continuation
        }
    }
    
    private func sendMessage() {
        let args = ["coinIndex"]
        let messageStr = "{\"op\": \"subscribe\",\"args\": \(args)}"
        let message = URLSessionWebSocketTask.Message.string(messageStr)
        webSocketTask?.send(message) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
//    private func receive() {
//           webSocketTask?.receive { result in
//               switch result {
//               case .success(let message):
//                   switch message {
//                   case .string(let text):
//                       if let responseValue = self.deccodeResponse(text: text) {
//                           self.cryptoModelDict = self.convert(responseValue)
//                           print(1)
//                       }
//                   case .data(let data):
//                       print("Received data: \(data)")
//                   @unknown default:
//                       fatalError()
//                   }
//               case .failure(let error):
//                   print(error)
//               }
//               self.receive()
//           }
//       }
    
    private func subscribe() {
        Task {
            let message =  try? await webSocketTask?.receive()
            subscribe()
            guard let message = message,
                  case let .string(text) = message,
                  let responseValue = deccodeResponse(text: text) else {
                return
            }
            cryptoModelDict = convert(responseValue)
        }
    }
    
    private func deccodeResponse(text: String) -> ResponseValue? {
        let data = text.data(using: .utf8)
        let decoder = JSONDecoder()
        let responseData = try? decoder.decode(ResponseValue.self, from: data!)
        return responseData
    }
    
    private func convert(_ data: ResponseValue) -> [String: CryptoModel] {
        let modelList: [CryptoModel] = data.data.compactMap { (_, value) in
            guard value.price > 0 else { return nil }
            return CryptoModel(symbol: value.id, price: String(value.price))
        }
        var dict: [String: CryptoModel] = [:]
        modelList.forEach {
            dict[$0.symbol] = CryptoModel(symbol: $0.symbol, price: $0.price)
        }
        return dict
    }
}

extension GetCryptoPriceWebSocketUseCase: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.conneceContinuation?.resume(returning: ())
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.conneceContinuation?.resume(throwing: WebError.webSocketConnectFailed)
    }
}
