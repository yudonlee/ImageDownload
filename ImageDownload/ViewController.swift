//
//  ViewController.swift
//  ImageDownload
//
//  Created by yudonlee on 2023/03/02.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var loadButton1: UIButton!
    @IBOutlet weak var loadButton2: UIButton!
    @IBOutlet weak var loadButton3: UIButton!
    @IBOutlet weak var loadButton4: UIButton!
    @IBOutlet weak var allLoadButton: UIButton!
    var buttons: [UIButton]!
    var imageViews: [UIImageView]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        [imageView1, imageView2, imageView3, imageView4].forEach {
            $0?.contentMode = .scaleAspectFit
            $0?.image = UIImage(systemName: "photo")
            $0?.backgroundColor = .lightGray
        }
        
        loadButton1.tag = 0
        loadButton2.tag = 1
        loadButton3.tag = 2
        loadButton4.tag = 3
        buttons = [loadButton1, loadButton2, loadButton3, loadButton4]
        imageViews = [imageView1, imageView2, imageView3, imageView4]
        
    }

    
    @IBAction func loadButtonTapped(_ sender: UIButton) {
        buttons[sender.tag].isEnabled = false
        buttons[sender.tag].configuration?.showsActivityIndicator = true
        imageViews[sender.tag].image = UIImage(systemName: "photo")
        Task {
            do {
                let image = try await downloadImage(id: sender.tag)
                buttons[sender.tag].isEnabled = true
                buttons[sender.tag].configuration?.showsActivityIndicator = false
                imageViews[sender.tag].image = image
            } catch {
                buttons[sender.tag].isEnabled = true
                buttons[sender.tag].configuration?.showsActivityIndicator = false
            }
        }
    }
    
    @IBAction func allLoadButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        sender.configuration?.showsActivityIndicator = true
        buttons.forEach {
            $0.isEnabled = false
            $0.configuration?.showsActivityIndicator = true
        }
        Task {
            do {
                let result = try await downloadAllImages(for: [0, 1, 2, 3])
                result.forEach {
                    imageViews[$0].image = $1
                }
                buttons.forEach {
                    $0.isEnabled = true
                    $0.configuration?.showsActivityIndicator = false
                }
                sender.isEnabled = true
                sender.configuration?.showsActivityIndicator = false
            } catch {
                buttons.forEach {
                    $0.isEnabled = true
                    buttons[sender.tag].configuration?.showsActivityIndicator = false
                }
                sender.isEnabled = true
                sender.configuration?.showsActivityIndicator = false
            }
        }
        
    }
                            
    func downloadAllImages(for ids: [Int]) async throws -> [Int: UIImage] {
        return try await withThrowingTaskGroup(of: (Int, UIImage).self) { group in
            var images: [Int: UIImage] = [:]
            
            for id in ids {
                group.addTask {
                    return (id, try await self.downloadImage(id: id))
                }
            }
            
            for try await imageUnit in group {
                images[imageUnit.0] = imageUnit.1
            }
            return images
        }
    }
    
    func downloadImage(id: Int) async throws -> UIImage {
        guard let url = URL(string: "https://source.unsplash.com/random/\(id)") else { throw ErrorLiteral.HttpError.invalidURL}
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard let httpStatusCode = response as? HTTPURLResponse else { throw ErrorLiteral.HttpError.invalidHttpResponse}
        
        guard httpStatusCode.statusCode == 200 else { throw ErrorLiteral.HttpError.invalidStatusCode(code: httpStatusCode.statusCode)}
        
        guard let image = UIImage(data: data) else { throw ErrorLiteral.HttpError.failedToConvertDataToImage }
        return image
    }
    
}

enum ErrorLiteral {
    enum HttpError: Error {
        case invalidURL
        case invalidHttpResponse
        case invalidStatusCode(code: Int)
        case failedToConvertDataToImage
    }
}
