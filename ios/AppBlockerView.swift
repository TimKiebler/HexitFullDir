//
//  AppBlockerView.swift
//  HexitFresh
//
//  UIKit wrapper that hosts the SwiftUI AppBlocker experience so we can attach it to
//  an RCTViewManager and render it inside React Native.
//

import SwiftUI
import UIKit

final class AppBlockerHostingView: UIView {
  private var hostingController: UIHostingController<AppBlockerRootView>?

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    embedSwiftUIView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    backgroundColor = .clear
    embedSwiftUIView()
  }

  private func embedSwiftUIView() {
    let controller = UIHostingController(rootView: AppBlockerRootView())
    controller.view.backgroundColor = .clear
    hostingController = controller

    guard let hostedView = controller.view else { return }
    hostedView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hostedView)

    NSLayoutConstraint.activate([
      hostedView.topAnchor.constraint(equalTo: topAnchor),
      hostedView.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostedView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    guard
      let controller = hostingController,
      let parentVC = parentViewController,
      controller.parent !== parentVC
    else { return }

    parentVC.addChild(controller)
    controller.didMove(toParent: parentVC)
  }

  private var parentViewController: UIViewController? {
    var responder: UIResponder? = self
    while responder != nil {
      if let viewController = responder as? UIViewController {
        return viewController
      }
      responder = responder?.next
    }
    return nil
  }
}
