import UIKit
import Flutter
import AVKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var aria2Process: Process?
    private var aria2Channel: FlutterMethodChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // Intent channel for opening videos with referer
        let intentChannel = FlutterMethodChannel(name: "com.predidit.kazumi/intent",
                                           binaryMessenger: controller.binaryMessenger)
        intentChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "openWithReferer" {
                guard let args = call.arguments else { return }
                if let myArgs = args as? [String: Any],
                   let url = myArgs["url"] as? String,
                   let referer = myArgs["referer"] as? String {
                    self.openVideoWithReferer(url: url, referer: referer)
                }
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        // aria2 channel for download management
        aria2Channel = FlutterMethodChannel(name: "com.predidit.kazumi/aria2_ios",
                                           binaryMessenger: controller.binaryMessenger)
        aria2Channel?.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch call.method {
            case "isAppStoreVersion":
                result(self.isAppStoreVersion())
            case "isAria2Available":
                result(self.isAria2Available())
            case "startAria2":
                if let args = call.arguments as? [String: Any],
                   let arguments = args["args"] as? [String] {
                    self.startAria2(arguments: arguments, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for startAria2",
                                      details: nil))
                }
            case "stopAria2":
                self.stopAria2(result: result)
            case "isAria2Running":
                result(self.aria2Process != nil && self.aria2Process!.isRunning)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        // Stop aria2 when app terminates
        if let process = aria2Process, process.isRunning {
            process.terminate()
            aria2Process = nil
        }
        super.applicationWillTerminate(application)
    }
    
    // MARK: - aria2 Management Methods
    
    /// Check if this is an App Store build (embedded.mobileprovision missing = App Store)
    private func isAppStoreVersion() -> Bool {
        guard let provisioningPath = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") else {
            // No provisioning profile = App Store build
            return true
        }
        
        // Check if it's an App Store provisioning profile
        do {
            let provisioningData = try String(contentsOfFile: provisioningPath, encoding: .ascii)
            // App Store profiles contain "ProvisionsAllDevices" or specific identifiers
            // Development/Ad Hoc profiles have different characteristics
            if provisioningData.contains("ProvisionedDevices") {
                // Has device list = Development or Ad Hoc (self-signed)
                return false
            }
            // No device list might be enterprise or App Store
            // For safety, we check for App Store specific markers
            return provisioningData.contains("ProvisionsAllDevices") == false
        } catch {
            // If we can't read it, assume App Store for safety
            return true
        }
    }
    
    /// Check if aria2 binary is available in the bundle
    private func isAria2Available() -> Bool {
        // Check if we're in an App Store build first
        if isAppStoreVersion() {
            return false
        }
        
        // Look for aria2c binary in bundle
        guard let aria2Path = Bundle.main.path(forResource: "aria2c", ofType: nil) else {
            return false
        }
        
        // Check if file exists and is executable
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: aria2Path) && fileManager.isExecutableFile(atPath: aria2Path)
    }
    
    /// Start aria2 process with given arguments
    private func startAria2(arguments: [String], result: @escaping FlutterResult) {
        // Don't start if it's already running
        if let process = aria2Process, process.isRunning {
            result(true)
            return
        }
        
        // Check if aria2 is available
        guard isAria2Available() else {
            result(FlutterError(code: "ARIA2_NOT_AVAILABLE",
                              message: "aria2 is not available (App Store build or binary not found)",
                              details: nil))
            return
        }
        
        guard let aria2Path = Bundle.main.path(forResource: "aria2c", ofType: nil) else {
            result(FlutterError(code: "ARIA2_NOT_FOUND",
                              message: "aria2c binary not found in bundle",
                              details: nil))
            return
        }
        
        // Create process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: aria2Path)
        process.arguments = arguments
        
        // Set up pipes for output (optional, for logging)
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Launch the process
        do {
            try process.run()
            aria2Process = process
            result(true)
            
            // Log output asynchronously
            outputPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                    NSLog("aria2: \(output)")
                }
            }
            
            errorPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                    NSLog("aria2 error: \(output)")
                }
            }
        } catch {
            result(FlutterError(code: "START_FAILED",
                              message: "Failed to start aria2: \(error.localizedDescription)",
                              details: nil))
        }
    }
    
    /// Stop aria2 process
    private func stopAria2(result: @escaping FlutterResult) {
        guard let process = aria2Process, process.isRunning else {
            result(true)
            return
        }
        
        process.terminate()
        aria2Process = nil
        result(true)
    }
    
    // MARK: - Video Player Methods
    
    // TODO: ADD VLC SUPPORT
    // VLC can be downloaded from iOS App Store, but don't know how to build selectable app lists, while checking if it is installled.
    // VLC supports more video formats than AVPlayer but does not support referer while AVPlayer does
    private func openVideoWithReferer(url: String, referer: String) {
        if let videoUrl = URL(string: url) {
            let headers: [String: String] = [
                "Referer": referer,
            ]
            let asset = AVURLAsset(url: videoUrl, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.videoGravity = AVLayerVideoGravity.resizeAspect
            
            UIApplication.shared.keyWindow?.rootViewController?.present(playerViewController, animated: true, completion: {
                playerViewController.player!.play()
            })
        }
        
//        guard let appURL = URL(string: "vlc-x-callback://x-callback-url/stream?url=" + url) else {
//            return
//        }
//        if UIApplication.shared.canOpenURL(appURL) && referer.isEmpty {
//            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
//        }
    }
}
