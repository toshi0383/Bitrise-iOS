//
//  LoadingFooterView.swift
//  BitriseClient
//
//  Created by 鈴木俊裕 on 2018/07/04.
//

import Continuum
import UIKit

final class LoadingFooterView: UITableViewHeaderFooterView {

    private lazy var indicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: .gray)

        self.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            v.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            v.widthAnchor.constraint(equalToConstant: 44),
            v.heightAnchor.constraint(equalToConstant: 44),
        ])

        return v
    }()

    private var disposeBag = NotificationCenterContinuum.Bag()

    func configure(_ viewModel: BuildsListViewModel) {

        disposeBag = NotificationCenterContinuum.Bag()

        notificationCenter.continuum
            .observe(viewModel.isMoreDataIndicatorHidden, on: .main) { [weak self] isHidden in
                guard let me = self else { return }

                if isHidden {
                    me.indicator.stopAnimating()
                } else {
                    me.indicator.startAnimating()
                }
            }
            .disposed(by: disposeBag)
    }
}
