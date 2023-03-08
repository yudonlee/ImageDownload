//
//  ImageDownloadUnitView.swift
//  ImageDownload
//
//  Created by yudonlee on 2023/03/08.
//

import UIKit

class ImageDownloadUnitView: UIView, URLSessionTaskDelegate {

    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var progressView: UIProgressView!
    @IBOutlet weak private var loadButton: UIButton!
    private var observation: NSKeyValueObservation!
    override func awakeFromNib() {
        super.awakeFromNib()
        loadButton.setTitle("Load", for: .normal)
        loadButton.setTitle("Stop", for: .selected)
    }
    
    func tapLoadButton() {
        loadButton.sendActions(for: .touchUpInside)
    }
    @IBAction private func loadButtonTapped(_ sender: UIButton) {
        loadButton.isSelected = !loadButton.isSelected
        sender.configuration?.showsActivityIndicator = true
        
        Task {
            do {
                let image = try await downloadImage()
                sender.configuration?.showsActivityIndicator = false
                imageView.image = image
                loadButton.isSelected = !loadButton.isSelected
            } catch {
                sender.configuration?.showsActivityIndicator = false
                imageView.image = UIImage(systemName: "photo")
                loadButton.isSelected = !loadButton.isSelected
            }
        }
    }
    
    func downloadImage() async throws -> UIImage {
        guard let url = URL(string: "https://source.unsplash.com/random/") else { throw ErrorLiteral.HttpError.invalidURL}
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url), delegate: self)
        guard let httpStatusCode = response as? HTTPURLResponse else { throw ErrorLiteral.HttpError.invalidHttpResponse}
        
        guard httpStatusCode.statusCode == 200 else { throw ErrorLiteral.HttpError.invalidStatusCode(code: httpStatusCode.statusCode)}
        
        guard let image = UIImage(data: data) else { throw ErrorLiteral.HttpError.failedToConvertDataToImage }
        return image
    }
    
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        observation = task.progress.observe(\.fractionCompleted, options: .new) { progress, value in
            DispatchQueue.main.async {
                self.progressView.progress = Float(progress.fractionCompleted)
            }
        }
    }
}
