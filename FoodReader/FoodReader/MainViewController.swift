import UIKit
import AVFoundation
import Photos

func loadShutterSound() -> AVAudioPlayer?
{
    let theMainBundle = Bundle.main
    let filename = "Shutter sound"
    let fileType = "mp3"
    let soundfilePath: String? = theMainBundle.path(forResource: filename,
                                                    ofType: fileType,
                                                    inDirectory: nil)
    if soundfilePath == nil
    {
        return nil
    }
    //println("soundfilePath = \(soundfilePath)")
    let fileURL = URL(fileURLWithPath: soundfilePath!)
    var error: NSError?
    let result: AVAudioPlayer?
    do {
        result = try AVAudioPlayer(contentsOf: fileURL)
    } catch let error1 as NSError {
        error = error1
        result = nil
    }
    if let requiredErr = error
    {
        print("AVAudioPlayer.init failed with error \(requiredErr.debugDescription)")
    }
    if result?.settings != nil
    {
        //println("soundplayer.settings = \(settings)")
    }
    result?.prepareToPlay()
    return result
}

class MainViewController:
    UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIPopoverControllerDelegate {
    
    var shutterSoundPlayer = loadShutterSound()
    
    var imagePicker: UIImagePickerController!
    
    var pictureTaken: Bool = false
    
    var textFound: String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        if(!pictureTaken) {
            setUpPicker()
        }
//        cropImageView.cropDelegate = self;
        
        // Do any additional setup after loading the view.
    }
    
    enum ImageSource: Int
    {
        case camera = 1
        case photoLibrary
    }
    
    @IBAction func retakePressed(_ sender: Any) {
        setUpPicker()
    }
    
    func setUpPicker() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: false, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            print("No image found")
            return
        }
        
        
        picker.dismiss(animated: true)
        pictureTaken = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    @IBAction func donePressed(_ sender: Any) {

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        print("In \(#function)")
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
