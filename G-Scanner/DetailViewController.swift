//
//  DetailViewController.swift
//  G-Scanner
//
//  Created by Nikhil Gohil on 23/01/2019.
//  Copyright © 2019 Gohil. All rights reserved.
//

import UIKit
import AVFoundation

class DetailViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    
    private var codes : [AVMetadataObject.ObjectType]?
    
    var captureSession = AVCaptureSession()
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var codeFrameView: UIView?
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            
            self.title = detail

            switch detail {
            case AVMetadataObject.ObjectType.upce.rawValue:
                 self.codes = [AVMetadataObject.ObjectType.upce]
            case AVMetadataObject.ObjectType.code39.rawValue:
                self.codes = [AVMetadataObject.ObjectType.code39]
            case AVMetadataObject.ObjectType.code39Mod43.rawValue:
                self.codes = [AVMetadataObject.ObjectType.code39Mod43]
            case AVMetadataObject.ObjectType.code93.rawValue:
                self.codes = [AVMetadataObject.ObjectType.code93]
            case AVMetadataObject.ObjectType.code128.rawValue:
                self.codes = [AVMetadataObject.ObjectType.code128]
            case AVMetadataObject.ObjectType.ean8.rawValue:
                self.codes = [AVMetadataObject.ObjectType.ean8]
            case AVMetadataObject.ObjectType.ean13.rawValue:
                self.codes = [AVMetadataObject.ObjectType.ean13]
            case AVMetadataObject.ObjectType.aztec.rawValue:
                self.codes = [AVMetadataObject.ObjectType.aztec]
            case AVMetadataObject.ObjectType.pdf417.rawValue:
                self.codes = [AVMetadataObject.ObjectType.pdf417]
            case AVMetadataObject.ObjectType.itf14.rawValue:
                self.codes = [AVMetadataObject.ObjectType.itf14]
            case AVMetadataObject.ObjectType.dataMatrix.rawValue:
                self.codes = [AVMetadataObject.ObjectType.dataMatrix]
            case AVMetadataObject.ObjectType.qr.rawValue:
                self.codes = [AVMetadataObject.ObjectType.qr]
            case AVMetadataObject.ObjectType.interleaved2of5.rawValue:
                self.codes = [AVMetadataObject.ObjectType.interleaved2of5]
            default:
                self.codes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
            }
        }
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = codes
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(cameraPreviewLayer!)
        
        captureSession.startRunning()
        
        view.bringSubviewToFront(statusLabel)
        
        codeFrameView = UIView()
        
        if let qrCodeFrameView = codeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        configureView()
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func stopScanning(){
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Scanned Result", message: "\(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Copy / Open", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
}


extension DetailViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        stopScanning()

        if metadataObjects.count == 0 {
            codeFrameView?.frame = CGRect.zero
            statusLabel.text = "No code detected :( Try Again."
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if codes?.contains(metadataObj.type) ?? false {
            let barCodeObject = cameraPreviewLayer?.transformedMetadataObject(for: metadataObj)
            codeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                launchApp(decodedURL: metadataObj.stringValue!)
                statusLabel.text = metadataObj.stringValue
                let pasteboard = UIPasteboard.general
                pasteboard.string = metadataObj.stringValue
            }
        }
    }
    
}
