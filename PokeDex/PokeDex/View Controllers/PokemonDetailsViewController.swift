//
//  PokemonDetailsViewController.swift
//  PokeDex
//
//  Created by Nicholas Alba on 6/22/21.
//

import UIKit

class PokemonDetailsViewController: UIViewController {

    // MARK: Initializers
    
    init(withPokemon pokemon: Pokemon, isNew: Bool) {
        self.pokemon = pokemon
        nameLabel.text = pokemon.name
        artworkView.image = pokemon.artwork
        if let height = pokemon.height, let weight = pokemon.weight {
            heightValueLabel.text = String(height) + " dm"
            weightValueLabel.text = String(weight) + " hg"
        }
        isBookmarked = !isNew
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let windows = UIApplication.shared.windows
        if isBookmarked, let rootViewController = windows.first?.rootViewController {
            if let homeViewController = rootViewController as? HomeViewController {
                homeViewController.savePokemon(pokemon)
            }
        } else if !isBookmarked, let rootViewController = windows.first?.rootViewController {
            if let homeViewController = rootViewController as? HomeViewController {
                homeViewController.deletePokemon(pokemon)
            }
        }
    }
    
    // Question: Order of constraints (subviews before superviews, or superviews before subviews?)
    
    // MARK: UI Set-Up
    private func setUpUI() {
        view.backgroundColor = UIColor(named: "PokeCream")
        overrideUserInterfaceStyle = .light
        setUpHeader()
        setUpArtworkView()
        setUpHeightViews()
        setUpWeightViews()
    }
    
    private func setUpHeader() {
        headerView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
    
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        if isBookmarked {
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
        headerView.addSubview(bookmarkButton)
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonPressed), for: .touchUpInside)
        NSLayoutConstraint.activate([
            bookmarkButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            bookmarkButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 50),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    private func setUpArtworkView() {
        view.addSubview(artworkView)
        NSLayoutConstraint.activate([
            artworkView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            artworkView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            artworkView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            artworkView.heightAnchor.constraint(equalTo: artworkView.widthAnchor)
        ])
    }
    
    private func setUpHeightViews() {
        guard let heightValue = heightValueLabel.text, heightValue.count != 0 else {
            return
        }
        
        heightSuperview.addSubview(heightKeyLabel)
        NSLayoutConstraint.activate([
            heightKeyLabel.centerYAnchor.constraint(equalTo: heightSuperview.centerYAnchor),
            heightKeyLabel.leadingAnchor.constraint(equalTo: heightSuperview.leadingAnchor, constant: 32)
        ])
        
        heightSuperview.addSubview(heightValueLabel)
        NSLayoutConstraint.activate([
            heightValueLabel.leadingAnchor.constraint(equalTo: heightKeyLabel.trailingAnchor, constant: 16),
            heightValueLabel.firstBaselineAnchor.constraint(equalTo: heightKeyLabel.firstBaselineAnchor)
        ])
        
        view.addSubview(heightSuperview)
        NSLayoutConstraint.activate([
            heightSuperview.topAnchor.constraint(equalTo: artworkView.bottomAnchor, constant: 32),
            heightSuperview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heightSuperview.heightAnchor.constraint(equalTo: heightKeyLabel.heightAnchor, constant: 16),
            heightSuperview.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpWeightViews() {
        guard let weightValue = weightValueLabel.text, weightValue.count != 0 else {
            return
        }
        
        weightSuperview.addSubview(weightKeyLabel)
        NSLayoutConstraint.activate([
            weightKeyLabel.centerYAnchor.constraint(equalTo: weightSuperview.centerYAnchor),
            weightKeyLabel.leadingAnchor.constraint(equalTo: weightSuperview.leadingAnchor, constant: 32)
        ])
        
        weightSuperview.addSubview(weightValueLabel)
        NSLayoutConstraint.activate([
            weightValueLabel.firstBaselineAnchor.constraint(equalTo: weightKeyLabel.firstBaselineAnchor)
        ])
        
        view.addSubview(weightSuperview)
        NSLayoutConstraint.activate([
            weightValueLabel.leadingAnchor.constraint(equalTo: heightValueLabel.leadingAnchor),
            weightSuperview.topAnchor.constraint(equalTo: heightSuperview.bottomAnchor, constant: 0),
            weightSuperview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weightSuperview.heightAnchor.constraint(equalTo: weightKeyLabel.heightAnchor, constant: 16),
            weightSuperview.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }

    // MARK: Interactivity
    @objc func bookmarkButtonPressed() {
        if isBookmarked {
            isBookmarked = false
            bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        } else {
            isBookmarked = true
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
    
    // MARK: Properties
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        return button
    }()
    
    private let pokemon: Pokemon
    private var isBookmarked = false
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = UIColor(named: "PokeBlue")
        label.textAlignment = .center
        return label
    }()
    
    private let artworkView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let heightSuperview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let heightKeyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(named: "PokeBlue")
        label.text = "Height:"
        return label
    }()
    
    private let heightValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: .regular)
        label.textColor = UIColor(named: "PokeBlue")
        label.text = ""
        return label
    }()
    
    private let weightSuperview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let weightKeyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(named: "PokeBlue")
        label.text = "Weight:"
        return label
    }()
    
    private let weightValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: .regular)
        label.textColor = UIColor(named: "PokeBlue")
        label.text = ""
        return label
    }()
}
