//
//  FilterView.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 30.05.2023.
//

import UIKit

class FilterView: UIView {
    
    private var view: UIView!
    
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(_ filter: String) {
        self.configureView()
        filterLabel.text = filter.capitalized
    }
    
    private func configureView() {
        guard let nibView = loadViewFromNib() else {return }
        containerView = view
        bounds = nibView.frame
        addSubview(nibView)
    }
    
    private func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let name = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
        let nib = UINib(nibName: name, bundle: bundle)
        let view = nib.instantiate(withOwner: self)[0] as! UIView
        return view
    }
}
