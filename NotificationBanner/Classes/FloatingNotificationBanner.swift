/*
 
 The MIT License (MIT)
 Copyright (c) 2018 Denis Kozhukhov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

import UIKit
import SnapKit

open class FloatingNotificationBanner: GrowingNotificationBanner {
    
    var cachedTitle: String?
    
    public convenience init(currentImage: UIImage? = nil,
                            imageUrl: URL? = nil,
                            title: String? = nil,
                            subtitle: String? = nil,
                            titleFont: UIFont? = nil,
                            titleColor: UIColor? = nil,
                            titleTextAlign: NSTextAlignment? = nil,
                            subtitleFont: UIFont? = nil,
                            subtitleColor: UIColor? = nil,
                            subtitleTextAlign: NSTextAlignment? = nil,
                            leftView: UIView? = nil,
                            rightView: UIView? = nil,
                            style: BannerStyle = .info,
                            colors: BannerColorsProtocol? = nil,
                            iconPosition: IconPosition = .center) {

        self.init(title: title, subtitle: subtitle, titleFont: titleFont, titleColor: titleColor, titleTextAlign: titleTextAlign, subtitleFont: subtitleFont, subtitleColor: subtitleColor, subtitleTextAlign: subtitleTextAlign, leftView: leftView, rightView: rightView, style: style, colors: colors, iconPosition: iconPosition)
        
        var titleToUse = title ?? ""
        cachedTitle = titleToUse
        
        var attach = NSTextAttachment()
        attach.image = currentImage?.rounded(radius: 20, doCircleIfSquare: true)
        attach.setImageHeight(height: 40)
        var attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: attach))
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        let dict1:[NSAttributedString.Key:Any] = [
            NSAttributedString.Key.font:UIFont(name: "AvenirNextItsme-ItsmeBold", size: 14),
            NSAttributedString.Key.paragraphStyle:style,
            NSAttributedString.Key.foregroundColor:UIColor.black
        ]
        attributedString.append(NSAttributedString(string: titleToUse, attributes: dict1))
        
        if let titleLabel = self.titleLabel {
            titleLabel.attributedText = attributedString
        }
        
        if let subtitleLabel = self.subtitleLabel {
            subtitleLabel.textColor = UIColor.black
        }
        
        if let imageUrl = imageUrl {
            downloadImage(from: imageUrl)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                
                guard let strongSelf = self else { return }
                
                if let titleLabel = strongSelf.titleLabel {
                    var attach = NSTextAttachment()
                    var currentImage = UIImage(data: data)
                    attach.image = currentImage?.rounded(radius: 20, doCircleIfSquare: true)
                    attach.setImageHeight(height: 40)
                    var titleToUse = strongSelf.cachedTitle ?? ""
                    
                    var attributedString = NSMutableAttributedString(string: "")
                    attributedString.append(NSAttributedString(attachment: attach))
                    
                    let style = NSMutableParagraphStyle()
                    style.alignment = .left
                    let dict1:[NSAttributedString.Key:Any] = [
                        NSAttributedString.Key.font:UIFont(name: "AvenirNextItsme-ItsmeBold", size: 18),
                        NSAttributedString.Key.paragraphStyle:style,
                        NSAttributedString.Key.foregroundColor:UIColor.black
                    ]
                    attributedString.append(NSAttributedString(string: titleToUse, attributes: dict1))
                    
                    titleLabel.attributedText = attributedString
                }
            }
        }
    }
    
    public init(title: String? = nil,
                subtitle: String? = nil,
                titleFont: UIFont? = nil,
                titleColor: UIColor? = nil,
                titleTextAlign: NSTextAlignment? = nil,
                subtitleFont: UIFont? = nil,
                subtitleColor: UIColor? = nil,
                subtitleTextAlign: NSTextAlignment? = nil,
                leftView: UIView? = nil,
                rightView: UIView? = nil,
                style: BannerStyle = .info,
                colors: BannerColorsProtocol? = nil,
                iconPosition: IconPosition = .center) {

        super.init(title: title, subtitle: subtitle, leftView: leftView, rightView: rightView, style: style, colors: colors, iconPosition: iconPosition)
        
        if let titleFont = titleFont {
            self.titleFont = titleFont
            titleLabel!.font = titleFont
        }
        
        if let titleColor = titleColor {
            titleLabel!.textColor = titleColor
        }
        
        if let titleTextAlign = titleTextAlign {
            titleLabel!.textAlignment = titleTextAlign
        }
        
        if let subtitleFont = subtitleFont {
            self.subtitleFont = subtitleFont
            subtitleLabel!.font = subtitleFont
        }
        
        if let subtitleColor = subtitleColor {
            subtitleLabel!.textColor = subtitleColor
        }
        
        if let subtitleTextAlign = subtitleTextAlign {
            subtitleLabel!.textAlignment = subtitleTextAlign
        }
    }
    
    public init(customView: UIView) {
        super.init(style: .customView)
        self.customView = customView
        
        contentView.addSubview(customView)
        customView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        spacerView.backgroundColor = customView.backgroundColor
    }
    
    /**
     Convenience function to display banner with non .zero default edge insets
     */
    public func show(queuePosition: QueuePosition = .back,
                     bannerPosition: BannerPosition = .top,
                     queue: NotificationBannerQueue = NotificationBannerQueue.default,
                     on viewController: UIViewController? = nil,
                     edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
                     cornerRadius: CGFloat? = nil,
                     shadowColor: UIColor = .black,
                     shadowOpacity: CGFloat = 1,
                     shadowBlurRadius: CGFloat = 0,
                     shadowCornerRadius: CGFloat = 0,
                     shadowOffset: UIOffset = .zero,
                     shadowEdgeInsets: UIEdgeInsets? = nil) {

        self.bannerEdgeInsets = edgeInsets
        
        if let cornerRadius = cornerRadius {
            contentView.layer.cornerRadius = cornerRadius
            contentView.subviews.last?.layer.cornerRadius = cornerRadius
        }
        
        if style == .customView, let customView = contentView.subviews.last {
           customView.backgroundColor = customView.backgroundColor?.withAlphaComponent(transparency)
        }

        show(queuePosition: queuePosition,
             bannerPosition: bannerPosition,
             queue: queue,
             on: viewController)
        
        applyShadow(withColor: shadowColor,
                    opacity: shadowOpacity,
                    blurRadius: shadowBlurRadius,
                    cornerRadius: shadowCornerRadius,
                    offset: shadowOffset,
                    edgeInsets: shadowEdgeInsets)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension FloatingNotificationBanner {
    
    /**
     Add shadow for notification with specified parameters.
     */
    private func applyShadow(withColor color: UIColor = .black,
                             opacity: CGFloat = 1,
                             blurRadius: CGFloat = 0,
                             cornerRadius: CGFloat = 0,
                             offset: UIOffset = .zero,
                             edgeInsets: UIEdgeInsets? = nil) {

        guard blurRadius >= 0 else { return }

        contentView.layer.shadowColor = color.cgColor
        contentView.layer.shadowOpacity = Float(opacity)
        contentView.layer.shadowRadius = blurRadius
        contentView.layer.shadowOffset = CGSize(width: offset.horizontal, height: offset.vertical)
        
        if let edgeInsets = edgeInsets {
            var shadowRect = CGRect(origin: .zero, size: bannerPositionFrame.startFrame.size)
            shadowRect.size.height -= (spacerViewHeight() - spacerViewDefaultOffset) // to proper handle spacer height affects
            shadowRect.origin.x += edgeInsets.left
            shadowRect.origin.y += edgeInsets.top
            shadowRect.size.width -= (edgeInsets.left + edgeInsets.right)
            shadowRect.size.height -= (edgeInsets.top + edgeInsets.bottom)
            contentView.layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: cornerRadius).cgPath
        }
        
        contentView.layer.rasterizationScale = UIScreen.main.scale
        contentView.layer.shouldRasterize = true
    }
    
}

private extension NSTextAttachment {
    
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height

        bounds = CGRect(x: bounds.origin.x, y: -0.14 * height, width: ratio * height, height: height)
    }
}

private extension UIImage {

    public func rounded(radius: CGFloat, doCircleIfSquare: Bool = false) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        var r = radius
        
        if doCircleIfSquare {
            if abs(size.width - size.height) < 0.01 {
                r = size.width / 2
            }
        }
        
        UIBezierPath(roundedRect: rect, cornerRadius: r).addClip()
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

