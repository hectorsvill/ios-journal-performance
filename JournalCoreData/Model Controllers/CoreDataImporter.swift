//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
		let timer1 = Date()
		print("sync start")
        self.context.perform {
            for entryRep in entries {
                guard let identifier = entryRep.identifier else { continue }
                
                let entry = self.fetchSingleEntryFromPersistentStore(with: identifier, in: self.context)
                if let entry = entry, entry != entryRep {
                    self.update(entry: entry, with: entryRep)
                } else if entry == nil {
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                }
            }
			let timer2 = Date()
			
			let syncDuration = timer2.timeIntervalSinceReferenceDate - timer1.timeIntervalSinceReferenceDate

			print("Print Time To sync duration: \(syncDuration.description)")
			print("sync complete")
            completion(nil)
        }
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    
    private func fetchSingleEntryFromPersistentStore(with identifier: String?, in context: NSManagedObjectContext) -> Entry? {
        
        guard let identifier = identifier else { return nil }
		
		
		
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
		
		
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", [identifier])
        
        var result: Entry? = nil
		var resultDict: [String: Entry] = [:]
		
        do {
            let results = try context.fetch(fetchRequest)
			
			for entry in results {
				resultDict[entry.identifier!] = entry
				result = entry
			}
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        return result
    }
    
    let context: NSManagedObjectContext
}
