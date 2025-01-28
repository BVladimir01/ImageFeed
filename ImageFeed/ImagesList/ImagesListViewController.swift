//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 27.01.2025.
//

import UIKit

class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 200
//        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        // Do any additional setup after loading the view.
    }
    
    func configCell(for cell: ImagesListCell) {
        
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            fatalError("Could not type cast cell to ImagesListCell")
//            return ImagesListCell()
        }
        configCell(for: cell)
        return cell
    }
    
    
}
