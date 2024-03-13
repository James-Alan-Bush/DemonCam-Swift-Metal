//
//  CameraManager.swift
//  DemonCam-Swift-Metal
//
//  Created by Xcode Developer on 3/6/24.
//

import Foundation
import AVFoundation
import UIKit
import CoreMedia

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureDevice: AVCaptureDevice?
    private var captureSession: AVCaptureSession?
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var videoDeviceRotationCoordinator: AVCaptureDevice.RotationCoordinator?
    @Published var image: UIImage?
    
    @Published var videoZoomFactor: Double = 1.0
    @Published var minVideoZoomFactor: CGFloat = 1.0
    @Published var maxVideoZoomFactor: CGFloat = 1.0
    
    @Published var lensPosition: Float = 0.5 // Default lens position
    
    // Method to adjust lens position
    func setLensPosition(_ position: Float) {
        guard let device = captureDevice else { return }
        
        // Check if the device supports the locked focus mode and adjusting lens position
        if device.isFocusModeSupported(.locked) && device.isLockingFocusWithCustomLensPositionSupported {
            if !device.isAdjustingFocus {
                do {
                    try device.lockForConfiguration()
                    
                    device.setFocusModeLocked(lensPosition: position) { _ in
                        // Update the lens position
                        // DispatchQueue.main.async if needed for UI update
                        self.lensPosition = position
                    }
                    
                    device.unlockForConfiguration()
                } catch {
                    print("Unable to set lensPosition: \(error)")
                }
            }
        } else {
            print("Locked focus mode or lens position adjustment not supported on this device.")
        }
    }
    
    
    override init() {
        super.init()
        self.setupCamera()
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return
        }
        
        self.captureDevice = device
        self.minVideoZoomFactor = device.minAvailableVideoZoomFactor
        self.maxVideoZoomFactor = device.activeFormat.videoMaxZoomFactor
        self.lensPosition = device.lensPosition
        
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: Int32(kCVPixelFormatType_32BGRA))]
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        self.captureSession = session
    }
    
    func setVideoZoomFactor(_ factor: Double) {
        guard let device = captureDevice else { return }
        if !device.isRampingVideoZoom {
            do {
                try device.lockForConfiguration()
                let zoomFactor = CGFloat(factor)
                if zoomFactor >= device.minAvailableVideoZoomFactor && zoomFactor <= device.activeFormat.videoMaxZoomFactor {
                    device.videoZoomFactor = zoomFactor
                    self.videoZoomFactor = Double(zoomFactor)
                }
                device.unlockForConfiguration()
            } catch {
                print("Unable to set videoZoomFactor: \(error)")
            }
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
    
    func stopSession() {
        captureSession?.stopRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        guard let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer) else { return }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard var newContext = CGContext(data: baseAddress, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else { return }
        guard let newImage = newContext.makeImage() else { return }

        DispatchQueue.main.async {
#if targetEnvironment(macCatalyst)
        self.image = UIImage(cgImage: newImage, scale: 1.0, orientation: .up)
#else
        self.image = UIImage(cgImage: newImage, scale: 1.0, orientation: .right)
#endif
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }
    
    // RECORDING
    
    func setupVideoWriter() {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: NSNumber(value: Float(1920)), // Adjust based on your camera's output
            AVVideoHeightKey: NSNumber(value: Float(1080)) // Adjust based on your camera's output
        ]
        
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            assetWriterInput?.expectsMediaDataInRealTime = true
            
            let pixelBufferAttributes: [String: Any] = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32ARGB),
                String(kCVPixelBufferWidthKey): 1920,
                String(kCVPixelBufferHeightKey): 1080,
                String(kCVPixelBufferCGImageCompatibilityKey): true,
                String(kCVPixelBufferCGBitmapContextCompatibilityKey): true
            ]
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput!, sourcePixelBufferAttributes: pixelBufferAttributes)
            
            if assetWriter!.canAdd(assetWriterInput!) {
                assetWriter!.add(assetWriterInput!)
            }
        } catch {
            print("Could not create AVAssetWriter: \(error)")
        }
    }
    
    func startRecording() {
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: CMTime.zero)
    }
    
    func finishRecording(completion: @escaping (URL?) -> Void) {
        assetWriterInput?.markAsFinished()
        assetWriter?.finishWriting { [weak self] in
            DispatchQueue.main.async {
                completion(self?.assetWriter?.outputURL)
            }
        }
    }
    
    
}
