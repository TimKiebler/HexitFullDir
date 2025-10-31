//
//  AppBlockerModel.swift
//  AppBlocker
//

import Foundation
import ManagedSettings
import DeviceActivity
import FamilyControls
import SwiftUI

private let _AppBlockerModel = AppBlockerModel()

class AppBlockerModel: ObservableObject {
    public let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    
    @Published var selectionToDiscourage: FamilyActivitySelection
    @AppStorage("categoryTokensData", store: UserDefaults(suiteName: "group.com.yourcompany.appblocker")) private var categoryTokensData: Data?
    @AppStorage("applicationTokensData", store: UserDefaults(suiteName: "group.com.yourcompany.appblocker")) private var applicationTokensData: Data?
    @AppStorage("webDomainTokensData", store: UserDefaults(suiteName: "group.com.yourcompany.appblocker")) private var webDomainTokensData: Data?
    
    // Schedule names
    private let lockScheduleName = DeviceActivityName("lock")
    private let unlockScheduleName = DeviceActivityName("unlock")
    
    // Computed properties for tokens
    var categoryTokens: Set<ActivityCategoryToken>? {
        get {
            if let data = categoryTokensData {
                let decoder = JSONDecoder()
                if let decodedTokens = try? decoder.decode(Set<ActivityCategoryToken>.self, from: data) {
                    return decodedTokens
                }
            }
            return nil
        }
        set {
            if let newTokens = newValue {
                let encoder = JSONEncoder()
                if let encodedData = try? encoder.encode(newTokens) {
                    categoryTokensData = encodedData
                } else {
                    categoryTokensData = nil
                }
            } else {
                categoryTokensData = nil
            }
        }
    }
    
    var applicationTokens: Set<ApplicationToken>? {
        get {
            if let data = applicationTokensData {
                let decoder = JSONDecoder()
                if let decodedTokens = try? decoder.decode(Set<ApplicationToken>.self, from: data) {
                    return decodedTokens
                }
            }
            return nil
        }
        set {
            if let newTokens = newValue {
                let encoder = JSONEncoder()
                if let encodedData = try? encoder.encode(newTokens) {
                    applicationTokensData = encodedData
                } else {
                    applicationTokensData = nil
                }
            } else {
                applicationTokensData = nil
            }
        }
    }
    
    var webDomainTokens: Set<WebDomainToken>? {
        get {
            if let data = webDomainTokensData {
                let decoder = JSONDecoder()
                if let decodedTokens = try? decoder.decode(Set<WebDomainToken>.self, from: data) {
                    return decodedTokens
                }
            }
            return nil
        }
        set {
            if let newTokens = newValue {
                let encoder = JSONEncoder()
                if let encodedData = try? encoder.encode(newTokens) {
                    webDomainTokensData = encodedData
                } else {
                    webDomainTokensData = nil
                }
            } else {
                webDomainTokensData = nil
            }
        }
    }
    
    init() {
        selectionToDiscourage = FamilyActivitySelection()
        
        if let applicationTokens = applicationTokens {
            selectionToDiscourage.applicationTokens = applicationTokens
        }
        
        if let categoryTokens = categoryTokens {
            selectionToDiscourage.categoryTokens = categoryTokens
        }
        
        if let webDomainTokens = webDomainTokens {
            selectionToDiscourage.webDomainTokens = webDomainTokens
        }
    }
    
    class var shared: AppBlockerModel {
        return _AppBlockerModel
    }
    
    func setShieldRestrictions() {
        applicationTokens = selectionToDiscourage.applicationTokens
        categoryTokens = selectionToDiscourage.categoryTokens
        webDomainTokens = selectionToDiscourage.webDomainTokens
        
        store.shield.applications = selectionToDiscourage.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selectionToDiscourage.categoryTokens)
        store.shield.webDomains = selectionToDiscourage.webDomainTokens
    }
    
    func setShieldRestrictionsFromStorage() {
        store.shield.applications = applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categoryTokens ?? [])
        store.shield.webDomains = webDomainTokens
    }
    
    // Lock apps immediately
    func lockApps() {
        setShieldRestrictions()
        
        // Start daily lock schedule
        startDailyLockSchedule()
    }
    
    // Unlock apps for 30 minutes
    func unlockApps() {
        // Clear current restrictions
        store.clearAllSettings()
        
        // Schedule re-lock in 30 minutes
        scheduleRelock()
    }
    
    // Start daily lock schedule (runs every day)
    private func startDailyLockSchedule() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try center.startMonitoring(lockScheduleName, during: schedule)
        } catch {
            print("Failed to start daily lock schedule: \(error)")
        }
    }
    
    // Schedule apps to be locked again after 30 minutes
    private func scheduleRelock() {
        let now = Date()
        let relockTime = Calendar.current.date(byAdding: .minute, value: 30, to: now)!
        
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: relockTime)
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: Calendar.current.date(byAdding: .minute, value: 1, to: relockTime)!)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )
        
        do {
            try center.startMonitoring(unlockScheduleName, during: schedule)
        } catch {
            print("Failed to schedule relock: \(error)")
        }
    }
    
    // Stop all monitoring
    func stopMonitoring() {
        center.stopMonitoring([lockScheduleName, unlockScheduleName])
        
        // Clear restrictions
        store.clearAllSettings()
    }
} 
