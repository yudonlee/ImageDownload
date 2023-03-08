//
//  UpgradeViewController.swift
//  ImageDownload
//
//  Created by yudonlee on 2023/03/08.
//

import UIKit

class UpgradeViewController: UIViewController {
    
    @IBOutlet private var views: [ImageDownloadUnitView]!
    @IBOutlet weak var loadAllImageButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func loadAllImages(_ sender: UIButton) {
        views.forEach { $0.tapLoadButton() }
    }

}
