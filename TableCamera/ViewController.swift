//
//  ViewController.swift
//  TableCamera
//
//  Created by Nikita Kudinovich on 14.01.24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    
    private let networkService = NetworkService()
     
    private var currentData: ResponseModel! {
        didSet {
            if allModels.isEmpty {
                allModels = currentData.content
            } else {
                allModels.append(contentsOf: currentData.content)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private var currentPage: Int = 0
    private var isEndPage: Bool = false
    private var allModels: [Content] = [Content]()
    private var selectedModel: Content?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 141
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "TableViewCell")
        
        setupUI()
        
        loadData()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .secondarySystemBackground
    }
    
    private func loadData(_ page: Int = 0) {
        
        networkService.loadData(page: page) { [unowned self] data, err in
            
            guard let models = data, !models.content.isEmpty else {
                isEndPage = true
                return
            }
            self.currentData = models
        }
    }
    
    private func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self

        present(picker, animated: true)
    }
    
    private func showAlert(with message: String) {
        let alertController = UIAlertController(title: "Congratulations",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok",
                                                style: .default,
                                                handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, 
                   numberOfRowsInSection section: Int) -> Int {
        return allModels.count
    }
    
    func tableView(_ tableView: UITableView, 
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", 
                                                 for: indexPath) as! TableViewCell
        let model = allModels[indexPath.row]
        cell.configureCell(model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, 
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row == (allModels.count - 1) && !isEndPage {
            currentPage += 1
            loadData(currentPage)
        }
    }
    
    func tableView(_ tableView: UITableView, 
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = allModels[indexPath.row]
        self.selectedModel = model
                
        openCamera()
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.selectedModel = nil
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, 
                               didFinishPickingMediaWithInfo 
                               info: [UIImagePickerController.InfoKey : Any]) {
         picker.dismiss(animated: true)
        
        if 
         let image = info[UIImagePickerController.InfoKey.originalImage]
            as? UIImage,
         let id = selectedModel?.id {
            
            let compressImage = image.resizeWithPercent(percentage: 0.50)!
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.networkService.uploadData(id: id, image: compressImage) { [weak self] in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        self.showAlert(with: "The response has been received")
                    }
                }
            }
        }
    }
}

//MARK: - UIImage ResizeWithWidth
extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
            let imageView = UIImageView(frame: CGRect(
                origin: .zero,
                size: CGSize(width: size.width * percentage,
                             height: size.height * percentage)))
        
            imageView.contentMode = .scaleAspectFit
            imageView.image = self
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            imageView.layer.render(in: context)
        
            guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
            UIGraphicsEndImageContext()
            return result
        }
}
