//
//  AppSelectionPickerView.swift
//  HexitFresh
//
//  SwiftUI wrapper that exposes the FamilyActivityPicker as a React Native view.
//

import FamilyControls
import SwiftUI
import UIKit

private struct AppSelectionPickerContainer: View {
  @ObservedObject private var model = EmbeddedAppBlockerModel.shared

  var body: some View {
    FamilyActivityPicker(selection: $model.selectionToDiscourage)
      .ignoresSafeArea()
  }
}

final class AppSelectionPickerHostingView: UIView {
  private var hostingController: UIHostingController<AppSelectionPickerContainer>?

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    embedPicker()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    backgroundColor = .clear
    embedPicker()
  }

  private func embedPicker() {
    let controller = UIHostingController(rootView: AppSelectionPickerContainer())
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
