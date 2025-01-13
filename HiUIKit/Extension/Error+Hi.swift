//
//  Error+Hi.swift
//  HiUIKit
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation
import RxSwift
import RxOptional
import SwifterSwift
import SafariServices
import AuthenticationServices
import StoreKit
import Kingfisher
import Alamofire
import Moya
import HiCore
import HiNet
import HiBase

extension HiError {

    public var displayImage: UIImage? {
        switch self {
        case .networkNotConnected, .networkNotReachable: return UIImage.networkError
        case .server: return UIImage.serverError
        case .dataIsEmpty: return UIImage.emptyError
        case .userNotLoginedIn: return UIImage.userNotLoginedInError
        case .userLoginExpired: return UIImage.userLoginExpiredError
        default: return UIImage.serverError
        }
    }
    
}

extension NSError: HiErrorCompatible {
    public var hiError: HiError {
        print("NSError转换-> \(self.domain), \(self.code), \(self.localizedDescription)")
        
        var message = self.localizedDescription
        if let msg1 = self.userInfo["message"] as? String, msg1.isNotEmpty {
            message = msg1
        } else if let msg2 = self.userInfo["msg"] as? String, msg2.isNotEmpty {
            message = msg2
        }
        if self.domain == ASWebAuthenticationSessionError.errorDomain {
            if let compatible = self as? ASWebAuthenticationSessionError {
                return compatible.hiError
            }
        }
        if self.domain == SKError.errorDomain {
            if let compatible = self as? SKError {
                return compatible.hiError
            }
        }
        if self.domain == NSURLErrorDomain {
            // NSURLErrorDomain Code=-1020 "目前不允许数据连接。"
            // NSURLErrorUnknown                        -1
            // NSURLErrorCancelled                      -999
            // NSURLErrorBadURL                         -1000
            // NSURLErrorTimedOut                       -1001(请求超时)
            // NSURLErrorUnsupportedURL                 -1002
            // NSURLErrorCannotFindHost                 -1003
            // NSURLErrorCannotConnectToHost            -1004(无法连接服务器)
            // NSURLErrorNetworkConnectionLost          -1005
            // NSURLErrorDNSLookupFailed                -1006
            // NSURLErrorHTTPTooManyRedirects           -1007
            // NSURLErrorResourceUnavailable            -1008
            // NSURLErrorNotConnectedToInternet         -1009(似乎已断开与互联网的连接)
            // NSURLErrorRedirectToNonExistentLocation  -1010
            // NSURLErrorBadServerResponse              -1011
            // NSURLErrorUserCancelledAuthentication    -1012
            // NSURLErrorUserAuthenticationRequired     -1013
            // NSURLErrorZeroByteResource               -1014
            // NSURLErrorCannotDecodeRawData            -1015
            // NSURLErrorCannotDecodeContentData        -1016
            // NSURLErrorCannotParseResponse            -1017
            // -1202（此服务器的证书无效。）
            // print("看看错误码: \(NSURLErrorFileDoesNotExist)")

            if self.code == -1020 {
                return .networkNotConnected
            }
            // -1005 ~ -999
            if self.code >= NSURLErrorNetworkConnectionLost &&
                self.code <= NSURLErrorCancelled {
                return .networkNotConnected
            }
            if self.code == NSURLErrorCannotParseResponse {
                return .dataInvalid
            }
//            if self.code >= NSURLErrorDNSLookupFailed ||
//                        self.code <= NSURLErrorCannotParseResponse {
//                return .server(ErrorCode.serverNoResponse, self.localizedDescription)
//            }
            return .networkNotConnected
        } else {
            if self.code == 500 {
                return .networkNotReachable
            } else if self.code == 401 {
                return .userNotLoginedIn
            }
        }
        return .app(self.domain, self.code, message, self.userInfo)
    }
}

extension ASWebAuthenticationSessionError: HiErrorCompatible {
    public var hiError: HiError {
        switch self.code {
        case .canceledLogin:
            return .cancel
        default:
            return .app(ASWebAuthenticationSessionErrorDomain, self.code.rawValue, self.localizedDescription, nil)
        }
    }
}

extension SKError: HiErrorCompatible {
    public var hiError: HiError {
        switch self.code {
        case .paymentCancelled:
            return .cancel
        default:
            return .app(SKErrorDomain, self.code.rawValue, self.localizedDescription, nil)
        }
    }
}

extension RxError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case .unknown: return .unknown
        case .timeout: return .timeout
        default: return .app("RxErrorDomain", 0, self.localizedDescription, nil)
        }
    }
}

extension RxOptionalError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case .emptyOccupiable: return .dataIsEmpty
        case .foundNilWhileUnwrappingOptional: return .dataInvalid
        }
    }
}

extension AFError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case .explicitlyCancelled:
            return .timeout
        case let .sessionTaskFailed(error):
            return error.asHiError
        default:
            return .app("AFErrorDomain", 0, self.localizedDescription, nil)
        }
    }
}

extension KingfisherError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case .responseError(let reason):
            switch reason {
            case .invalidHTTPStatusCode(let response):
                return .server(
                    response.statusCode,
                    HTTPURLResponse.localizedString(forStatusCode: response.statusCode),
                    nil
                )
            default:
                return .app("KingfisherErrorDomain", 0, self.localizedDescription, nil)
            }
        default:
            return .app("KingfisherErrorDomain", 0, self.localizedDescription, nil)
        }
    }
}

extension MoyaError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case let .underlying(error, _):
            return error.asHiError
        case let .statusCode(response):
            if response.statusCode == 401 {
                return .userNotLoginedIn
            }
//            if response.statusCode == 403 {
//                return .userLoginExpired
//            }
            if let json = try? response.data.jsonObject() as? [String: Any],
               let message = json.string(for: Parameter.message), message.count != 0 {
                return .server(response.statusCode, message, nil)
            }
            return .server(response.statusCode, response.data.string(encoding: .utf8), nil)
        case .jsonMapping:
            return .dataInvalid
        default:
            return .app("MoyaErrorDomain", 0, self.localizedDescription, nil)
        }
    }
}

extension HiNetError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case .unknown: return .unknown
        case .dataInvalid: return .dataInvalid
        case .dataIsEmpty: return .dataIsEmpty
        case .userNotLoginedIn: return .userNotLoginedIn
        case .userLoginExpired: return .userLoginExpired
        case let .server(code, message, data):  return .server(code, message, data)
        }
    }
}
