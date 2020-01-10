//
//  CountryListTableViewController.swift
//  CountryListExample
//
//  Created by Juan Pablo on 9/8/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit

protocol CountryListDelegate: class {
    func selectedCountry(country: Country)
}

class CountryList: HOBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var tableView: UITableView!
    var searchController: UISearchController?
    var resultsController = UITableViewController()
    var filteredCountries = [Country]()
    
    weak var delegate: CountryListDelegate?
    
    private var countryList: [Country] {
        let countries = Countries()
        let countryList = countries.countries
        return countryList
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Countries"
        self.view.backgroundColor = .white
        
        let naviTintColor = UIColor(red: 31/255, green: 61/255, blue: 84/255, alpha: 1)
        navigationController?.navigationBar.tintColor = naviTintColor
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Font.boldFontName, size: 16)!,
            NSAttributedString.Key.foregroundColor: naviTintColor
        ]
        
        tableView = UITableView(frame: view.frame)
        tableView.register(CountryCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        
        self.view.addSubview(tableView)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleCancel))
        
        setUpSearchBar()
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        
        filteredCountries.removeAll()
        
        let text = searchController.searchBar.text!.lowercased()
        
        for country in countryList {
            guard let name = country.name else { return }
            if name.lowercased().contains(text) {
                
                filteredCountries.append(country)
            }
        }
        
        tableView.reloadData()
    }
    
    func setUpSearchBar() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.tableView.tableHeaderView = searchController?.searchBar
        self.searchController?.hidesNavigationBarDuringPresentation = false
        
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.placeholder = "Search"
        self.searchController?.searchResultsUpdater = self
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CountryCell
        let country = cell.country!
        
        self.searchController?.isActive = false
        self.delegate?.selectedCountry(country: country)
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController!.isActive && searchController!.searchBar.text != "" {
            return filteredCountries.count
        }
        
        return countryList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! CountryCell
        
        if searchController!.isActive && searchController!.searchBar.text != "" {
            cell.country = filteredCountries[indexPath.row]
            return cell
        }
        
        cell.country = countryList[indexPath.row]
        return cell
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
