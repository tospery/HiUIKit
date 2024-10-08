//
//  ScrollViewController+Hi.swift
//  HiUIKit
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator_Hi
import DZNEmptyDataSet
import BonMot
import MJRefresh
import HiTheme

extension ScrollViewController {
    
    @objc dynamic open func setupRefresh(should: Bool) {
        if should {
            self.scrollView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
                guard let `self` = self else { return }
                self.refreshSubject.onNext(())
            })
        } else {
            self.scrollView.mj_header?.removeFromSuperview()
            self.scrollView.mj_header = nil
        }
    }
    
    @objc dynamic open func setupLoadMore(should: Bool) {
        if should {
            self.scrollView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { [weak self] in
                guard let `self` = self else { return }
                self.loadMoreSubject.onNext(())
            })
        } else {
            self.scrollView.mj_footer?.removeFromSuperview()
            self.scrollView.mj_footer = nil
        }
    }
    
    func handle(theme: ThemeType) {
        self.scrollView.reloadEmptyDataSet()
    }
    
}
