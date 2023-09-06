
import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    

    var slides: [OnboardingSlide] = []

    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                let buttonImage = UIImage(named: "onboardingButton")
                nextBtn.setImage(buttonImage, for: .normal)
            }
            if currentPage == slides.count - 2 {
                let buttonImage = UIImage(named: "onboardingButton1")
                nextBtn.setImage(buttonImage, for: .normal)
            }
            else {
                let buttonImage = UIImage(named: "onboardingButton2")
                nextBtn.setImage(buttonImage, for: .normal)
            }
        }
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slides = [
            OnboardingSlide(title: Localizer.localize("welcome_favMap"), description: Localizer.localize("This application provides you with information about your location."), image: UIImage(named: "welcome_1")!),
            OnboardingSlide(title: Localizer.localize("Many different options"), description: Localizer.localize("You can choose from gas stations, cafes, restaurants, and many more options."), image: UIImage(named: "welcome_2")!),
            OnboardingSlide(title: Localizer.localize("Customized view"), description:Localizer.localize("It provides a more enhanced view with customized location pins and options."), image: UIImage(named: "welcome_3")!)
        ]
        
        pageControl.numberOfPages = slides.count
    }
    
    @IBAction func nextBtnClicked(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
            //dismiss
            Core.shared.setIsNotNewUser()
            dismiss(animated: true, completion: nil)
            let controller = storyboard?.instantiateViewController(identifier: "SignInVC") as! UIViewController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .flipHorizontal
            present(controller, animated: true, completion: nil)
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    

    
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        
    }
    
}


