// SingleInstance.swift
import Foundation

/// ⚠️ Do not instantiate `SingleInstanceRoot`
/// This root class exists to facilitate `SingleInstance` subclasses.
open class SingleInstanceRoot {
    fileprivate struct WeakValue {
        weak var value: AnyObject?
    }

    static fileprivate var instance = [String: WeakValue]()

    private var key: String {"\(type(of: self))"}
    private var rejected = true

    func exemptedFromSingleInstance() -> Bool {
        let isRunningSwiftUIPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        // future exemptions here...
        return isRunningSwiftUIPreviews // || future exemption || future exemption || ...
    }

    fileprivate init?() {
        guard type(of: self) !== SingleInstanceRoot.self
        else {
            fatalError("FATAL ERROR: Do not create direct instances of SingleInstanceRoot class, instantiate subclasses instead.")
            return nil
        }

        guard SingleInstanceRoot.instance[key] == nil
        else {
            // extant instance detected. Once that object is destroyed, another one can be created.
            print("rejected = true")
            return nil
        }
        if !exemptedFromSingleInstance() {
            SingleInstanceRoot.instance[key] = WeakValue(value: self)
        }
        rejected = false
    }

    deinit {
        print("DEINIT: rejected = \(rejected)")
        if !rejected {
            SingleInstanceRoot.instance[key] = nil
        }
    }
}

/// SingleInstances differ from the Singleton `.shared()` pattern by
/// requiring failable initialzation. If initialization fails, there is an extant
/// single instance somewhere.
///
/// Guidelines:
///
/// - Use Singleton pattern to share a Utility object
/// - Use SingleInstance pattern for non-shared objects (esp. dependency injection)
/// - Parent object should have at least same lifespan as SingleInstance and hold strong reference throughout. References at injection site should be `unowned` to call out that these values are injected.
///
/// Unlike Singletons which are lazily initialized and shared, the lifecycle of SingleInstances
/// are explicit in the code and few lines of code should have access to the object, reducing
/// potential down-the-line technical debt when original coders are replaced, and also providing
/// a clean state for each test case, since the Singleton's typically do not deinitialize.
open class SingleInstance: SingleInstanceRoot {
    public override required init?() {
        guard type(of: self) !== SingleInstance.self
        else {
            fatalError("FATAL ERROR: Do not create direct instances of SingleInstance class, instantiate subclasses instead.")
            return nil
        }
    }
}
