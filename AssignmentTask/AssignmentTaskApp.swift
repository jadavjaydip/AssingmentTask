//
//  AssignmentTaskApp.swift
//  AssignmentTask
//
//  Created by j on 11/09/24.
//

import SwiftUI

@main
struct AssignmentTaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
