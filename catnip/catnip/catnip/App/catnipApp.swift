//
//  catnipApp.swift
//  catnip
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

@main
struct AppMain {

    static func main() {

        if isRunningUnitTests {

            UIApplicationMain(CommandLine.argc,
                              CommandLine.unsafeArgv,
                              nil,
                              NSStringFromClass(TestAppDelegate.self))

        } else {

            CatnipApp.main()
        }
    }
}

private extension AppMain {
    
    struct CatnipApp: App {
        
        @MainActor
        let core: Core = {
            
            let core = Core.liveValue
            
            if isRunningUITests,
               let catGateway = core.managers.catGateway as? CatGateway {
                
                do { try catGateway.clear() }
                catch {}
            }
            
            return core
        }()
        
        private var store: StoreOf<CoordinatorFeature> {
            Store(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.core = core
            }
        }
        
        var body: some Scene {
            WindowGroup {
                CoordinatorView(store: store)
            }
            .modelContainer(core.managers.catGateway.modelContainer)
        }
    }
    
    final class TestAppDelegate: UIResponder, UIApplicationDelegate {

        var window: UIWindow?

        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {

            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = UIViewController()
            window?.makeKeyAndVisible()
            window?.backgroundColor = .accent

            return true
        }
    }
}

private extension AppMain {
    
    static var isRunningUnitTests: Bool {
        
        NSClassFromString("XCTestCase") != nil
    }
    
    static var isRunningUITests: Bool {
        
        CommandLine.arguments.contains("-uitesting")
    }
}
