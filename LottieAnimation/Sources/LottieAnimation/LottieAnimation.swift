// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Lottie

public struct LottieView: UIViewRepresentable {
    let animationName: String
    var completion: (() -> Void)? = nil
    
    public init(animationName: String, completion: (() -> Void)? = nil) {
            self.animationName = animationName
            self.completion = completion
        }


    public func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play { finished in
            if finished {
                completion?()
            }
        }
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
