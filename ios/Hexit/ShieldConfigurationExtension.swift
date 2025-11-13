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

    private func hexitConfig() -> ShieldConfiguration {
        ShieldConfiguration(
            // Dark look to mimic the mockup
            backgroundBlurStyle: .systemChromeMaterialDark,
            backgroundColor: UIColor.black.withAlphaComponent(0.85),

            // Top icon (system controls size). Use your asset if available.
            icon: UIImage(named: "HexStoneFrontal") ?? UIImage(systemName: "hexagon.fill"),

            // Big headline (line break forces two lines)
            title: .init(
                text: "BLEIB STARK –\nDER ALGORITHMUS KANN WARTEN",
                color: .white
            ),

            // Smaller, lighter body copy (two lines)
            subtitle: .init(
                text: "DEIN HANDY IST GERADE IM HEXIT MODUS.\nTAP DEIN HEXIT UM DIESE APP WIEDER ZU BENUTZEN.",
                color: .tertiaryLabel
            ),

            // Black pill button feel (system rounds, you can’t control radius)
            primaryButtonLabel: .init(
                text: "ZURÜCK ZU DEN WICHTIGEN DINGEN IM LEBEN",
                color: .white
            ),
            primaryButtonBackgroundColor: .black,

            // No secondary button in your mock
            secondaryButtonLabel: nil
        )
    }

    // Apps
    override func configuration(shielding application: Application) -> ShieldConfiguration { hexitConfig() }
    // Apps via category
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration { hexitConfig() }
    // Web domains
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration { hexitConfig() }
    // Web domains via category
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration { hexitConfig() }
}
