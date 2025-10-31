//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

/// Device Activity monitor used by the Screen Time extension to re-apply shields.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        switch activity.rawValue {
        case "lock":
            applyLockRestrictions()
        case "unlock":
            applyLockRestrictions()
        default:
            break
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        switch activity.rawValue {
        case "unlock":
            applyLockRestrictions()
        default:
            break
        }
    }
    
    private func applyLockRestrictions() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.appblocker")
        
        if let appData = sharedDefaults?.data(forKey: "applicationTokensData") {
            if let appTokens = try? JSONDecoder().decode(Set<ApplicationToken>.self, from: appData) {
                store.shield.applications = appTokens
            }
        }
        
        if let categoryData = sharedDefaults?.data(forKey: "categoryTokensData") {
            if let categoryTokens = try? JSONDecoder().decode(Set<ActivityCategoryToken>.self, from: categoryData) {
                store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categoryTokens)
            }
        }
        
        if let webData = sharedDefaults?.data(forKey: "webDomainTokensData") {
            if let webTokens = try? JSONDecoder().decode(Set<WebDomainToken>.self, from: webData) {
                store.shield.webDomains = webTokens
            }
        }
    }
} 
