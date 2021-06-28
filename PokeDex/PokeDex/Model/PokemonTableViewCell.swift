//
//  PokemonTableViewCell.swift
//  PokeDex
//
//  Created by Nicholas Alba on 6/21/21.
//

import UIKit

class PokemonTableViewCell: UITableViewCell {

    // MARK: Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier:  reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Set-Up
    
    func loadPokemon(_ pokemon: Pokemon) {
        nameLabel.text = pokemon.name
        spriteView.image = pokemon.sprite
    }
    
    // Weird Part
    
    private func setUpUI() {
        contentView.addSubview(spriteView)
        // let squareConstraint = NSLayoutConstraint(item: spriteView, attribute: .width, relatedBy: .equal, toItem: spriteView, attribute: .height, multiplier: 1, constant: 0)
        // squareConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            spriteView.topAnchor.constraint(equalTo: contentView.topAnchor),
            spriteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            spriteView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            spriteView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            // squareConstraint
        ])
        
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: spriteView.trailingAnchor, constant: 32),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    // MARK: Properties
    
    private let spriteView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = UIColor(named: "PokeBlue")
        label.textAlignment = .left
        return label
    }()
}
