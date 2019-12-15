//
//  ResourceViewController.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 15/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit

class ResourceViewController: UITableViewController {

    var resource: Resource!
    var analogues: [Resource] = []
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        analogues.count > 0 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return min((resource.offers?.count ?? 0), 5) + 1
        } else {
            var numberOfRowsInAnalogues = 0
            for resource in analogues {
                numberOfRowsInAnalogues += min((resource.offers?.count ?? 0), 5) + 1
            }
            return numberOfRowsInAnalogues
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Искомый товар" : "Аналоги"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resourceCell", for: indexPath)

        return cell
    }
    
    func fetchResources(for article: String, brand: String) {
        guard let escapedArticle = article.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let escapedBrand = brand.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let apiUrl = "https://api.berg.ru/ordering/get_stock.json?items[0][resource_article]=\(escapedArticle)&items[0][brand_name]=\(escapedBrand)&analogs=1&key=2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e730"
        
        guard let url = URL(string: apiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(error)
            //            print(response)
            //            print(data)

            guard let data = data else { return }

            do {
                let apiResult = try JSONDecoder().decode(SearchResult.self, from: data)
                for resource in (apiResult.resources ?? []) {
                    if resource.isEquals(by: article) {
                        self.resource = resource
                    } else {
                        self.analogues.append(resource)
                    }
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error.localizedDescription)
                print(error)
            }
        }.resume()
    }
}
