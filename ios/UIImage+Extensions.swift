import UIKit

extension UIImage {

    convenience init?(fromEnvironmentStaticPath path: String) {
        let url = Environment.base.appendingPathComponent(path)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        self.init(data: data)
    }

    func rounded(in imageView: UIImageView) -> UIImage? {
        UIGraphicsBeginImageContext(imageView.bounds.size)
        let path = UIBezierPath(roundedRect: imageView.bounds,
                                cornerRadius: imageView.frame.size.width / 2)
        path.addClip()
        draw(in: imageView.bounds)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage
    }
}
