//
//  BindCollectionViewController.swift
//  HiUIKit
//
//  Created by 杨建祥 on 2024/3/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import RxSwiftExt
import RxDataSources
import ReactorKit
import URLNavigator_Hi
import ObjectMapper
import Kingfisher
import RxDataSources
import HiCore
import HiBase
import HiTheme
import HiNav

open class BindCollectionViewController: CollectionViewController, ReactorKit.View {
    
    required public init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        defer {
            self.reactor = reactor as? BindCollectionViewReactor
        }
        super.init(navigator, reactor)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.theme.backgroundColor = themeService.attribute { $0.lightColor }
    }

    open func bind(reactor: BindCollectionViewReactor) {
        super.bind(reactor: reactor)
        // action
        self.rx.load.map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        self.rx.viewWillAppear.skip(1).map { _ in Reactor.Action.update }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        self.rx.refresh.map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        self.rx.loadMore.map { Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        // state
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.rx.title)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: self.rx.loading)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: self.rx.refreshing)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isLoadingMore }
            .distinctUntilChanged()
            .bind(to: self.rx.loadingMore)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isActivating }
            .distinctUntilChanged()
            .bind(to: self.rx.activating)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.noMoreData }
            .distinctUntilChanged()
            .bind(to: self.rx.noMoreData)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.error }
            .distinctUntilChanged({ $0?.asHiError == $1?.asHiError })
            .bind(to: self.rx.error)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.profile?.loginedUser?.isValid }
            .distinctUntilChanged()
            .skip(1)
            .delay(.milliseconds(20), scheduler: MainScheduler.asyncInstance)
            .subscribeNext(weak: self, type(of: self).handleLogin)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.profile?.loginedUser }
            .distinctUntilChanged { HiCore.compareAny($0, $1) }
            .skip(1)
            .delay(.milliseconds(10), scheduler: MainScheduler.asyncInstance)
            .subscribeNext(weak: self, type(of: self).handleUser)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.profile }
            .distinctUntilChanged { HiCore.compareAny($0, $1) }
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleProfile)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.data }
            .distinctUntilChanged { HiCore.compareAny($0, $1) }
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleData)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.contents }
            .distinctUntilChanged { HiCore.compareAny($0, $1) }
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleContents)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.target }
            .distinctUntilChanged()
            .filterNil()
            .subscribeNext(weak: self, type(of: self).handleTarget)
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - handle
    open func handleProfile(profile: (any ProfileType)?) {
        print("handleProfile: (\(self.reactor?.host ?? ""), \(self.reactor?.path ?? ""))")
    }
    
    open func handleTarget(target: String?) {
        guard let url = target?.url else { return }
        if url.host == .back {
            let type = url.queryValue(for: Parameter.backType)?.int ?? 0
            let animated = url.queryValue(for: Parameter.animated)?.bool
            let result = url.queryValue(for: Parameter.result)
            let message = url.queryValue(for: Parameter.message)
            self.back(type: .init(rawValue: type), result: result, message: message, animated: animated ?? true)
            return
        }
        self.navigator.jump(url)
    }
    
    open func handleLogin(isLogined: Bool?) {
        print("\(#function), (\(self.reactor?.host ?? ""), \(self.reactor?.path ?? "")): \(isLogined ?? false)")
        MainScheduler.asyncInstance.schedule(()) { [weak self] _ -> Disposable in
            guard let `self` = self else { fatalError() }
            self.reactor?.action.onNext(.reload)
            return Disposables.create {}
        }.disposed(by: self.disposeBag)
    }
    
    open func handleUser(user: (any UserType)?) {
    }
    
    open func handleData(data: Any?) {
    }
    
    open func handleContents(contents: [HiContent]) {
    }
}

extension BindCollectionViewController: UICollectionViewDelegateFlowLayout {

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .zero
    }
    
    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        .zero
    }
    
    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        .init(width: collectionView.sectionWidth(at: section), height: safeArea.bottom)
    }

}
