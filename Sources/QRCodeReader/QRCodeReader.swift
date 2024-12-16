// The Swift Programming Language
// https://docs.swift.org/swift-book

#if canImport(UIKit)
import UIKit
import VisionKit

public class QRCodeReader: NSObject {
    public typealias ScanCompletion = (String) -> Void
    
    private var scanCompletion: ScanCompletion?
    private var dataScannerViewController: DataScannerViewController?
    
    public var overlayColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    public var cornerColor: UIColor = .systemGreen
    public var instructionText: String = "Align the QR code within the frame to scan"
    public var padding: CGFloat = 8
    public var windowSize: CGFloat = 250
    
    public override init() {
        super.init()
    }
    
    @MainActor public func isScanningAvailable() -> Bool {
        return DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }
    
    @MainActor public func presentScanner(from viewController: UIViewController, completion: @escaping ScanCompletion) {
        self.scanCompletion = completion
        
        guard isScanningAvailable() else {
            print("Scanner not available on this device")
            return
        }
        
        let scannerVC = QRScannerViewController()
        scannerVC.delegate = self
        scannerVC.overlayColor = overlayColor
        scannerVC.cornerColor = cornerColor
        scannerVC.instructionText = instructionText
        scannerVC.padding = padding
        scannerVC.windowSize = windowSize
        
        viewController.present(scannerVC, animated: true)
    }
}

extension QRCodeReader: QRScannerViewControllerDelegate {
    func qrScannerDidCancel() {
        
    }
    
    func qrScanner(didScanCode code: String) {
        scanCompletion?(code)
    }
}
#endif
