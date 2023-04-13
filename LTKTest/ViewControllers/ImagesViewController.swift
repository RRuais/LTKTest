//
//  ImagesViewController.swift
//  LTKTest
//
//  Created by Rich Ruais on 4/12/23.
//

import UIKit

class ImagesViewController: UIViewController {
    
    private let viewModel: ImagesViewModel
    private let titleText = "Photos"
    
    lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    init(viewModel: ImagesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBindings()
    }
    
    private func configureBindings() {
        viewModel.newIndexPaths
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .sink { [weak self] indexPaths in
                self?.collectionView.insertItems(at: indexPaths)
            }
            .store(in: &viewModel.disposeBag)
    }

    private func configureUI() {
        title = titleText
        navigationController?.navigationBar.prefersLargeTitles = true

        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
        ])
    }
}

extension ImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.cancelLoading(for: indexPath)
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        
        let id = viewModel.image(for: indexPath)?.id
        cell.id = id
        cell.imageView.image = UIImage(systemName: "photo.fill")
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ImageCollectionViewCell else { return }

        let id = viewModel.image(for: indexPath)?.id

        viewModel.loadImageData(for: indexPath) { [weak cell] image in
            if let image = image {
                DispatchQueue.main.async { [weak cell] in
                    if cell?.id == id {
                        cell?.imageView.image = image
                        cell?.imageView.contentMode = .scaleAspectFill
                    }
                }
            }
        }

        if indexPath.row == viewModel.images.count - 10 {
            viewModel.loadImageMetadata()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectImage(for: indexPath)
    }
}

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}
