import Foundation
import CoreData

enum BackupService {
    private static let backupFileName = "vaccTrack_backup.json"
    private static let lastBackupKey = "backup_last_timestamp"
    private static let lastRestoreKey = "backup_last_restore_timestamp"
    
    static var backupURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        return appSupport.appendingPathComponent(backupFileName)
    }
    
    static var hasBackup: Bool {
        FileManager.default.fileExists(atPath: backupURL.path)
    }
    
    static var lastBackupDate: Date? {
        UserDefaults.standard.object(forKey: lastBackupKey) as? Date
    }
    
    static var lastRestoreDate: Date? {
        UserDefaults.standard.object(forKey: lastRestoreKey) as? Date
    }
    
    static func createBackup(context: NSManagedObjectContext) throws {
        // Ensure context is saved before backup
        try context.performAndWait {
            if context.hasChanges { try context.save() }
        }
        
        // Export all patients with their doses
        let data = try ExportImportService.exportAllPatientsJSON(context: context)
        
        // Overwrite previous backup (always overwrite as requested)
        try data.write(to: backupURL)
        
        // Set file protection to ensure backup persists
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: backupURL.path
        )
        
        UserDefaults.standard.set(Date(), forKey: lastBackupKey)
    }
    
    static func restoreBackup(context: NSManagedObjectContext) throws -> Date {
        guard hasBackup else {
            throw NSError(domain: "BackupService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No backup found"])
        }
        
        // Get backup timestamp before restore
        let backupDate = lastBackupDate ?? Date()
        
        // Clear existing data first to ensure authoritative restore (patients, doses, vaccines)
        try context.performAndWait {
            // Delete all existing doses
            let doseReq: NSFetchRequest<NSFetchRequestResult> = Dose.fetchRequest() as! NSFetchRequest<NSFetchRequestResult>
            let deleteDoses = NSBatchDeleteRequest(fetchRequest: doseReq)
            deleteDoses.resultType = .resultTypeObjectIDs
            if let result = try? context.execute(deleteDoses) as? NSBatchDeleteResult,
               let ids = result.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: ids]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            }
            
            // Delete all existing patients (doses are cascade deleted)
            let patientReq: NSFetchRequest<NSFetchRequestResult> = Patient.fetchRequest() as! NSFetchRequest<NSFetchRequestResult>
            let deletePatients = NSBatchDeleteRequest(fetchRequest: patientReq)
            deletePatients.resultType = .resultTypeObjectIDs
            if let result = try? context.execute(deletePatients) as? NSBatchDeleteResult,
               let ids = result.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: ids]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            }

            // Delete all existing vaccines (will be recreated from backup data)
            let vaccineReq: NSFetchRequest<NSFetchRequestResult> = Vaccine.fetchRequest() as! NSFetchRequest<NSFetchRequestResult>
            let deleteVaccines = NSBatchDeleteRequest(fetchRequest: vaccineReq)
            deleteVaccines.resultType = .resultTypeObjectIDs
            if let result = try? context.execute(deleteVaccines) as? NSBatchDeleteResult,
               let ids = result.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: ids]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            }
            
            try context.save()
            
            // Read backup data and restore exact snapshot
            let data = try Data(contentsOf: backupURL)
            try ExportImportService.importData(data, context: context)
            
            if context.hasChanges {
                try context.save()
            }
            
            // Refresh all objects to ensure UI updates
            context.refreshAllObjects()
        }
        
        // Record restore timestamp for downstream flows to react (e.g., suppress backfill temporarily)
        UserDefaults.standard.set(backupDate, forKey: lastRestoreKey)
        return backupDate
    }
    
    static func deleteBackup() throws {
        guard hasBackup else { return }
        try FileManager.default.removeItem(at: backupURL)
    }
    
    static func restoreIfAvailable(context: NSManagedObjectContext) async throws {
        guard hasBackup else { return }
        try restoreBackup(context: context)
    }
}

