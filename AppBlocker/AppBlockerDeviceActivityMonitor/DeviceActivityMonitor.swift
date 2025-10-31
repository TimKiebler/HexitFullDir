//
//  DeviceActivityMonitor.swift
//  AppBlockerDeviceActivityMonitor
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

class DeviceActivityMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        switch activity.rawValue {
        case "lock":
            // Lock apps when the lock schedule starts
            applyLockRestrictions()
        case "unlock":
            // Re-lock apps when the unlock period ends
            applyLockRestrictions()
        default:
            break
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        switch activity.rawValue {
        case "unlock":
            // Re-apply restrictions when unlock period ends
            applyLockRestrictions()
        default:
            break
        }
    }
    
    private func applyLockRestrictions() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.appblocker")
        
        // Load application tokens
        if let appData = sharedDefaults?.data(forKey: "applicationTokensData") {
            if let appTokens = try? JSONDecoder().decode(Set<ApplicationToken>.self, from: appData) {
                store.shield.applications = appTokens
            }
        }
        
        // Load category tokens
        if let categoryData = sharedDefaults?.data(forKey: "categoryTokensData") {
            if let categoryTokens = try? JSONDecoder().decode(Set<ActivityCategoryToken>.self, from: categoryData) {
                store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categoryTokens)
            }
        }
        
        // Load web domain tokens
        if let webData = sharedDefaults?.data(forKey: "webDomainTokensData") {
            if let webTokens = try? JSONDecoder().decode(Set<WebDomainToken>.self, from: webData) {
                store.shield.webDomains = webTokens
            }
        }
    }
} 