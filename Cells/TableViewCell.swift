//
//  TableViewCell.swift
//  TableCamera
//
//  Created by Nikita Kudinovich on 14.01.24.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var imageViewCell: UIImageView!
    
    public func configureCell(_ model: Content) {
        
        nameLabel.text = model.name
        idLabel.text = "ID: \(model.id)"

        if model.image != nil {
            
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: URL(string: model.image!)!)
                if let data = imageData {
                    DispatchQueue.main.async {
                        self.imageViewCell.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.idLabel.text = nil
        self.imageViewCell.image = nil
    }
}
