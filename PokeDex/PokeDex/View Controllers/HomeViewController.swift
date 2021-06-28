//
//  ViewController.swift
//  PokeDex
//
//  Created by Nicholas Alba on 6/20/21.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        searchBar.delegate = self
        loadStoredPokemon()
    }
    
    // MARK: UI Set-Up
    
    private func setUpUI() {
        view.backgroundColor = UIColor(named: "PokeCream")
        overrideUserInterfaceStyle = .light
        setUpHeader()
        setUpSearchBar()
        setUpTableView()
    }
    
    private func setUpHeader() {
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        headerView.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setUpSearchBar() {
        view.addSubview(searchBarDescriptionLabel)
        NSLayoutConstraint.activate([
            searchBarDescriptionLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 32),
            searchBarDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBarDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        
        stackView.addArrangedSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0),
            searchBar.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0)
        ])
        
        stackView.addArrangedSubview(searchButton)
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0),
        ])
        searchButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: searchBarDescriptionLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }
    
    private func setUpTableView() {
        view.addSubview(pokemonTableView)
        pokemonTableView.dataSource = self
        pokemonTableView.delegate = self
        pokemonTableView.register(PokemonTableViewCell.self, forCellReuseIdentifier: "pokemonCell")
        
        NSLayoutConstraint.activate([
            pokemonTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            pokemonTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pokemonTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            pokemonTableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.40)
        ])
        
        view.addSubview(pokemonTableLabel)
        NSLayoutConstraint.activate([
            pokemonTableLabel.bottomAnchor.constraint(equalTo: pokemonTableView.topAnchor, constant: -16),
            pokemonTableLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: CoreData Management
    
    public func savePokemon(_ pokemon: Pokemon) {
        guard let existingPokemon = pokemonCaught, !existingPokemon.contains(pokemon) else {
            return
        }
        let newPokemon = PokemonEntity(context: self.context)
        newPokemon.name = pokemon.name
        do {
            try self.context.save()
        } catch {
            print("Couldn't save new pokemon named \(String(describing: newPokemon.name))")
        }
        pokemonCaught?.append(pokemon)
        pokemonCaught?.sort {$0.id < $1.id}
        pokemonTableView.reloadData()
    }
    
    public func deletePokemon(_ pokemon: Pokemon) {
        guard let existingPokemon = pokemonCaught,
              let indexOfSelectedPokemon = existingPokemon.firstIndex(of: pokemon) else {
            return
        }
        do {
            // pokemonCaught?.remove(at: index)
            let pokemonEntities = try context.fetch(PokemonEntity.fetchRequest()) as! [PokemonEntity]
            let selectedPokemonEntityList = pokemonEntities.filter {$0.name == pokemon.name}
            if let selectedPokemonEntity = selectedPokemonEntityList.first, selectedPokemonEntityList.count == 1 {
                context.delete(selectedPokemonEntity)
                try context.save()
            }
        } catch {
            print("Failed to delete selected pokemon.")
        }
        pokemonCaught?.remove(at: indexOfSelectedPokemon)
        pokemonTableView.reloadData()
    }
    
    private func loadStoredPokemon() {
        var pokemonEntities:[PokemonEntity] = []
        do {
            pokemonEntities = try context.fetch(PokemonEntity.fetchRequest()) as! [PokemonEntity]
        } catch {
            print("Failed to fetch stored Pokemon entities.")
        }
        let pokemonNames = pokemonEntities.filter{$0.name != nil}.map({$0.name!})
        pokemonNames.forEach({
            fetchPokemonRequest(for: $0) {pokemon, error in
                guard let pokemon = pokemon, error == nil else {
                    print("Fetch pokemon response failed due to error: \(String(describing: error?.localizedDescription))")
                    return
                }
                DispatchQueue.main.async {
                    self.pokemonCaught?.append(pokemon)
                    self.pokemonCaught?.sort {$0.id < $1.id}
                    self.pokemonTableView.reloadData()
                }
            }
        })
    }
    
    // MARK: Interactivity
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.endEditing(true)
        return false
    }
    
    @objc func goButtonPressed() {
        guard let pokemonName = searchBar.text, !pokemonName.isEmpty else {return}
        fetchPokemonRequest(for: pokemonName) {pokemon, error in
            guard let pokemon = pokemon, error == nil else {
                print("Fetch pokemon response failed due to error: \(String(describing: error?.localizedDescription))")
                DispatchQueue.main.async {
                    self.presentAlertForFailedRequest(forPokemonNamed: pokemonName)
                }
                return
            }
            DispatchQueue.main.async {
                self.presentAlertForSuccessfulRequest(forPokemon: pokemon)
            }
        }
    }
    
    private func fetchPokemonRequest(for pokemonName: String, completion: @escaping (Pokemon?, Error?) -> Void) {
        guard let pokemonURL = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonName.lowercased())") else {
            print("Expected Pokemon API URL but failed.")
            return
        }
        var request = URLRequest(url: pokemonURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            do {
                let pokemonDecodable = try JSONDecoder().decode(PokemonDecodable.self, from: data)
                let pokemon = Pokemon(from: pokemonDecodable, with: data)
                completion(pokemon, nil)
            } catch {
                completion(nil, error)
                print("Failed to decode Pokemon data with error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func presentAlertForSuccessfulRequest(forPokemon pokemon: Pokemon) {
        let alert = UIAlertController(title: "Pokemon Found", message: "Show me more information for \(pokemon.name)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        var isNew = true
        if let caughtPokemon = self.pokemonCaught {
            isNew = !caughtPokemon.contains(pokemon)
        }
        let pokemonDetailsViewController = PokemonDetailsViewController(withPokemon: pokemon, isNew: isNew)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) {_ in
            self.present(pokemonDetailsViewController, animated: true, completion: nil)
        })
        self.present(alert, animated: true)
    }
    
    private func presentAlertForFailedRequest(forPokemonNamed pokemonName: String) {
        let alert = UIAlertController(title: "Pokemon Not Found", message: "Could not find pokemon details for pokemon named \(pokemonName).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonCaught?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pokemonCell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath) as? PokemonTableViewCell, let selectedPokemon = pokemonCaught?[indexPath.row] else {
            return UITableViewCell()
        }
        pokemonCell.loadPokemon(selectedPokemon)
        return pokemonCell
    }
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedPokemon = pokemonCaught?[indexPath.row] else {
            return
        }
        present(PokemonDetailsViewController(withPokemon: selectedPokemon, isNew: false), animated: true, completion: nil)
    }
    
    // MARK: Properties
    
    private var pokemonCaught: [Pokemon]? = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pokedex"
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = UIColor(named: "PokeBlue")
        return label
    }()
    
    private let searchBarDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.text = "Search for pokemon and bookmark\nthose that you've caught!\nGotta catch em all!"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(named: "PokeBlue")
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        return stackView
    }()
    
    private let searchBar: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Pokemon to search."
        textField.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        textField.backgroundColor = .white
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "PokeBlue")
        button.setTitle("GO", for: .normal)
        button.layer.cornerRadius = 0
        return button
    }()
    
    private let pokemonTableLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pokemon Caught"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(named: "PokeBlue")
        return label
    }()
    
    private let pokemonTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
}
