import UIKit

class photoViewVC: UIViewController {
    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        let imageShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "", message: "Done", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)

                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            return
        }


    }

    
}
