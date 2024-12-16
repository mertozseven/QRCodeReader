//
//  QRScannerViewController.swift
//  QRCodeReader
//
//  Created by Mert Ozseven on 16.12.2024.
//

#if canImport(UIKit)
import UIKit
import VisionKit

protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScannerDidCancel()
    func qrScanner(didScanCode code: String)
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerViewControllerDelegate?
    
    var overlayColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    var cornerColor: UIColor = .systemGreen
    var instructionText: String = "Align the QR code within the frame to scan"
    var padding: CGFloat = 8
    var windowSize: CGFloat = 250
    
    private var dataScannerViewController: DataScannerViewController?
    
    private lazy var scannerOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = overlayColor
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = instructionText
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var scannedDataLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.text = "No QR code detected"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScanner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createScannerOverlay()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(scannerOverlay)
        view.addSubview(closeButton)
        view.addSubview(instructionLabel)
        view.addSubview(scannedDataLabel)
        
        scannerOverlay.frame = view.bounds
        
        closeButton.frame = CGRect(x: 16, y: view.safeAreaInsets.top + 16, width: 44, height: 44)
        
        instructionLabel.frame = CGRect(
            x: 16,
            y: view.bounds.height / 2 - 220,
            width: view.bounds.width - 32,
            height: 44
        )
        
        let windowSize: CGFloat = 250
        scannedDataLabel.frame = CGRect(
            x: 16,
            y: (view.bounds.height + windowSize) / 2 + 20,
            width: view.bounds.width - 32,
            height: 60
        )
    }
    
    private func setupScanner() {
        let dataScanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )
        
        dataScanner.delegate = self
        
        let windowSize: CGFloat = 250
        let screenSize = UIScreen.main.bounds
        let roi = CGRect(
            x: (screenSize.width - windowSize) / 2,
            y: (screenSize.height - windowSize) / 2,
            width: windowSize,
            height: windowSize
        )
        dataScanner.regionOfInterest = roi
        
        addChild(dataScanner)
        view.insertSubview(dataScanner.view, at: 0)
        dataScanner.view.frame = view.bounds
        dataScanner.didMove(toParent: self)
        
        try? dataScanner.startScanning()
        
        self.dataScannerViewController = dataScanner
    }
    
    private func createScannerOverlay() {
        let outerWindowRect = CGRect(
            x: (view.bounds.width - windowSize) / 2 - padding,
            y: (view.bounds.height - windowSize) / 2 - padding,
            width: windowSize + (padding * 2),
            height: windowSize + (padding * 2)
        )
        
        let innerWindowRect = CGRect(
            x: (view.bounds.width - windowSize) / 2,
            y: (view.bounds.height - windowSize) / 2,
            width: windowSize,
            height: windowSize
        )
        
        let path = UIBezierPath(rect: view.bounds)
        let scannerWindow = UIBezierPath(rect: innerWindowRect)
        path.append(scannerWindow.reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        scannerOverlay.layer.mask = maskLayer
        
        addCornerLines(to: outerWindowRect)
    }
    
    private func addCornerLines(to rect: CGRect) {
        let cornerLength: CGFloat = 20
        
        let corners = [
            (rect.origin, CGSize(width: cornerLength, height: 2)),
            (rect.origin, CGSize(width: 2, height: cornerLength)),
            (CGPoint(x: rect.maxX - cornerLength, y: rect.minY), CGSize(width: cornerLength, height: 2)),
            (CGPoint(x: rect.maxX - 2, y: rect.minY), CGSize(width: 2, height: cornerLength)),
            (CGPoint(x: rect.minX, y: rect.maxY - 2), CGSize(width: cornerLength, height: 2)),
            (CGPoint(x: rect.minX, y: rect.maxY - cornerLength), CGSize(width: 2, height: cornerLength)),
            (CGPoint(x: rect.maxX - cornerLength, y: rect.maxY - 2), CGSize(width: cornerLength, height: 2)),
            (CGPoint(x: rect.maxX - 2, y: rect.maxY - cornerLength), CGSize(width: 2, height: cornerLength))
        ]
        
        corners.forEach { point, size in
            let line = UIView(frame: CGRect(origin: point, size: size))
            line.backgroundColor = cornerColor
            view.addSubview(line)
        }
    }
    
    @objc private func closeTapped() {
        delegate?.qrScannerDidCancel()
        dismiss(animated: true)
    }
    
    private func updateScannedData(_ text: String) {
        scannedDataLabel.text = text
    }
}

extension QRScannerViewController: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        handleScannedItem(item)
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        guard let firstItem = addedItems.first else { return }
        handleScannedItem(firstItem)
    }
    
    private func handleScannedItem(_ item: RecognizedItem) {
        switch item {
        case .barcode(let barcode):
            if let stringValue = barcode.payloadStringValue {
                updateScannedData(stringValue)
                delegate?.qrScanner(didScanCode: stringValue)
            }
        default:
            break
        }
    }
}

#endif
