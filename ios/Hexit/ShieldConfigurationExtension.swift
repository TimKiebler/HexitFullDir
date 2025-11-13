//
//  ShieldConfigurationExtension.swift
//  Hexit
//
//  Created by Tim Kiebler on 12.11.25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    private func loud() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor.systemRed.withAlphaComponent(0.25),
            icon: .init(systemName: "lock.trianglebadge.exclamationmark"),
            title: .init(text: "Locked by Hexit", color: .white),
            primaryButtonLabel: .init(text: "OK", color: .white),
            primaryButtonBackgroundColor: .systemRed
        )
    }
    override func configuration(shielding application: Application) -> ShieldConfiguration { loud() }
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration { loud() }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration { loud() }
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration { loud() }
}
