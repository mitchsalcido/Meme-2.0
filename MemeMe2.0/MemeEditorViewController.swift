//
//  MemeEditorViewViewController.swift
//  MemeMe2.0
//
//  Created by 1203 Broadway on 5/21/21.
//
/*
 About MemeEditorViewViewController.swift:
 UIViewController subclass used to manage Meme creation. Handles launching imagePicker to select a photo, Meme text editing, and meme sharing.
 */

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // completion block passed from table/collection VC..used to update UI (tableView, collectionView, meme detail) upon
    // dismissal after meme saved. Implemented to accomodate .pagesheet modal presentation style which can result in
    // viewWillAppear not firing when parentVC appears
    var updateUIBlock: ((Meme?) -> Void)!
        
    // non-nil means that meme is passed in to be edited..camera/album not implemented. Steers UI appearance
    var memeToBeEdited: Meme? = nil
    
    // Misc constants
    let DEFAULT_SHARED_MEME_MESSAGE = "Check out my Meme !" // default text to share along with meme image
    let DEFAULT_PHOTO = "DefaultImage"          // name for default image

    // default textField constants
    let DEFAULT_TOP_TEXT = "TOP TEXT"           // default top text
    let DEFAULT_BOTTOM_TEXT = "BOTTOM TEXT"     // default bottom tex
    let DEFAULT_TEXT_SIZE: CGFloat = 40.0       // default text size
    let MINIMUM_TEXT_SIZE: CGFloat = 20.0       // textField adjust font size. Place a limit
    let TEXT_STROKE_WIDTH: CGFloat = -3.0       // default stroke width
    let TEXT_STROKE_COLOR: UIColor = UIColor.black  // default stroke color
    
    // Bar Button Item constants
    let ALBUM_BBI_NAME = "ALBUM"    // Album bbi title
    let COLOR_BBI_NAME = "COLOR"    // Color bbi title
    let FONT_BBI_NAME = "FONT"      // Font bbi title
    let PHOTO_ASPECT_FIT = "FIT"    // toggleContentAspectBbi -> FIT
    let PHOTO_ASPECT_FILL = "FILL"  // toggleContentAspectBbi -> FILL
    
    // outlets to UI objects
    var doneBbi: UIBarButtonItem!                   // done with MemeEditor
    var shareMemeBbi: UIBarButtonItem!              // share meme
    var cancelMemeEditingBbi: UIBarButtonItem!      // cancel meme editing
    var cameraBbi: UIBarButtonItem!                 // pick photo with camera
    var albumBbi: UIBarButtonItem!                  // pick photo from album
    var selectTextFontBbi: UIBarButtonItem!         // select text font
    var selectTextColorBbi: UIBarButtonItem!        // select text color
    var toggleContentAspectBbi: UIBarButtonItem!    // toggle image aspect
    @IBOutlet weak var memeImageView: UIImageView!  // contiain meme image
    var topTextField: UITextField!                  // top meme textField
    var bottomTextField: UITextField!               // bottom meme textField
    
    var originalImage: UIImage! // reference to original image, currently being edited
    
    
    /*
     backingView: This view is the container for the textFields which are positioned at top and bottom
     of backingView using constraints. This view is placed as a subView of self.view, and is positioned
     on top of image in memeImageView upon creation of UIImage. The backingView is implemented to
     facilitate the user ability to change meme aspect Fit/Fill while containing the top/bottom text.
     */
    var backingView: UIView!
    
    /*
     index counters and arrays of preselected fonts and colors.
     User can customize text font and color by pressing FONT/COLOR Bbi. Pressing cycles through a present
     selection of fonts/color, with index counters tracking the currently selected font/color
     */
    var fontIndex = 0   // track currently selected font
    var colorIndex = 0  // track currently selected color
    
    // some fonts for textFields text font
    let textAttributeNameArray = ["HelveticaNeue-CondensedBlack",
                               "Avenir-BlackOblique",
                               "Baskerville-Bold",
                               "ChalkboardSE-Bold",
                               "Georgia-BoldItalic"]
    
    // some colors for textFields text color
    let textColorArray = [UIColor.white,
                      UIColor.red,
                      UIColor.blue,
                      UIColor.black,
                      UIColor.orange,
                      UIColor.green]
    
    /*
    enum for Meme editing. Used to steer UI config.
        .defaultState: Show default image with app info
        .memeEditingState: memeImageView contains selected photo and text can be edited
    */
    enum MemeEditingState {
        case defaultState
        case memeEditingState
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // configure App and initial UI state
        navigationController?.setToolbarHidden(false, animated: false) // 210806:1502 remove self
        createBarButtonItems()
        
        // steer UI based on new meme or editing existing
        if let _ = memeToBeEdited {
            // editing existing
            updateUI(.memeEditingState)
        } else {
            // new meme
            updateUI(.defaultState)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // allow keyboard notifications. For shifting up view when bottom TextField is editing
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // end keyboard notifications.
        unsubscribeToKeyboardNotifications()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // update frame when rotated
        updateBackingViewFrame()
    }

    @objc func doneBbiPressed(_ sender: Any) {
        // done with Meme editor. Dismiss
        dismiss(animated: true, completion: {})
    }
    
    @objc func shareMemeBbiPressed(_ sender: Any) {

        // Action for shareMemeBbi. Meme the image and invoke UIActivityViewController for sharing
        if let memedImage = createMemeSharingImage() {
            // good memed image
            
            // activityVC
            let controller = UIActivityViewController(activityItems: [memedImage, DEFAULT_SHARED_MEME_MESSAGE],
                                                      applicationActivities: nil)
            
            // completion for activityVC
            controller.completionWithItemsHandler = {(activity, completed, items, error) in
                
                //  Verify operation complete before saving.
                if completed {
                    
                    if let topText = self.topTextField.text,
                       let bottomText = self.bottomTextField.text {
                        
                        let meme = Meme(topText: topText,
                                        bottomText: bottomText,
                                        originalImage: self.originalImage,
                                        memedImage: memedImage,
                                        fontIndex: self.fontIndex,
                                        colorIndex: self.colorIndex)
                        // save meme
                        self.saveMeme(meme)
                        
                        
                        // dismiss
                        self.dismiss(animated: true, completion: {
                            if self.memeToBeEdited == nil {
                                self.updateUIBlock(nil)
                            } else {
                                self.updateUIBlock(meme)
                            }
                        })
                    }
                }
            }
            
            // present
            present(controller,
                    animated: true,
                    completion: nil)
            
            // if used on iPad
            if let popOver = controller.popoverPresentationController {
                popOver.sourceView = self.view
                popOver.barButtonItem = shareMemeBbi
            }
        }
    }

    @objc func cancelEditingMemeBbiPressed(_ sender: Any) {

        // Steer to appropriate.
        if let _ = memeToBeEdited {
            // currently editing an existing meme..simply dismiss MemeEditorVC
            dismiss(animated: true, completion: {})
        } else {
            // editing a new meme..return to image selection
            memeImageView.image = nil
            updateUI(.defaultState)
        }
    }
    
    @objc func retrievePhoto(_ sender: UIBarButtonItem) {

        // Action for both Camera and Album BarButtonItem. Selects image source and invokes image picker.
        let controller = UIImagePickerController()
        controller.allowsEditing = true // allow editing in picker
        switch sender {
        case cameraBbi:
            controller.sourceType = .camera
        case albumBbi:
            controller.sourceType = .photoLibrary
        default:
            return
        }
        
        // set delegate and present
        controller.delegate = self
        present(controller, animated: true, completion: {})
    }
    
    // change aspect of meme
    @objc func toggleFillFitPhoto(_ sender: UIBarButtonItem) {
        
        // Action for Fill/Fit BarButtonItem. Handles swapping the aspect of the Meme between aspectFit and aspectFill.
        if memeImageView.contentMode == .scaleAspectFit {
            memeImageView.contentMode = .scaleAspectFill
            toggleContentAspectBbi.title = PHOTO_ASPECT_FIT
        } else {
            memeImageView.contentMode = .scaleAspectFit
            toggleContentAspectBbi.title = PHOTO_ASPECT_FILL
        }
        
        // update backing view for proper textField placement
        updateBackingViewFrame()
    }
    
    // change text color or font
    @objc func fontColorBbiPressed(_ sender: UIBarButtonItem) {
        
        // update text font or color.
        switch sender {
        case selectTextFontBbi:
            // update text font. Cycle through textAttributeNameArray as button pressed
           fontIndex += 1
           if fontIndex >= textAttributeNameArray.count {
               fontIndex = 0
           }
        case selectTextColorBbi:
            // update text color. Cycle through textColorArray as button pressed
            colorIndex += 1
            if colorIndex >= textColorArray.count {
                colorIndex = 0
            }
        default:
            break
        }
        
        // update text attrib's
        updateTextFieldTextAttributes()
    }
}

//  MARK: MemeEditorViewController extensions
/*  ***************************************
    * MemeEditorViewController extensions *
    ***************************************  */

// MARK: MemeEditorViewController helpers
extension MemeEditorViewController {
    
    // update the top/bottom textField attribs with current font and color count index
    func updateTextFieldTextAttributes() {
        
        // retrieve attributes and update
        let attributes = createTextAttribute(name: textAttributeNameArray[fontIndex],
                                             color: textColorArray[colorIndex])
        topTextField.defaultTextAttributes = attributes
        bottomTextField.defaultTextAttributes = attributes
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    // create the meme image for sharing
    func createMemeSharingImage() -> UIImage? {
        /*
         This function creates a image for meme sharing. The image is created by
         making new (temporary) imageView with the same properties as the memeImageView.
         This temporary imageView is then inserted into the backingView (inserted at
         index 0 such that textFields are visible). A UIImage is then created of the
         backingView, afterwhich the temporary imageView is immediately removed from
         the backingView. This method of creating the meme image was implemented as
         a means of facilitating the ability to change the aspect(Fill/Fit).
         */
        
        // create tempImageView and assign properties from memeImageView
        let tempImageView = UIImageView(frame: memeImageView.bounds)
        tempImageView.contentMode = memeImageView.contentMode
        tempImageView.image = memeImageView.image
        
        // if aspectFit, need to offset origin on tempImage
        if memeImageView.contentMode == .scaleAspectFit {
            if let frame = memeImageView.imageFrame() {
            tempImageView.frame.origin.x = -frame.origin.x
            tempImageView.frame.origin.y = -frame.origin.y
            } else {
                return nil
            }
        }
        
        // insert tempImageView into backing view, generate UIImage, remove tempImageView
        backingView.insertSubview(tempImageView, at: 0)
        let image = backingView.createUIImage()
        tempImageView.removeFromSuperview()
        
        return image
    }
    
    // update frame of backingView
    func updateBackingViewFrame() {

        // Handles updating frame of backingView. Required when device rotates or when aspect is toggled
        guard let _ = backingView, var frame = memeImageView.imageFrame() else {
            // applicable only when editing meme
            return
        }
        
        // update backingView frame
        switch memeImageView.contentMode {
        case .scaleAspectFill:
            // backingView has same frame as memeImageView when in Fill mode
            backingView.frame = memeImageView.frame
        case .scaleAspectFit:
            // scale backingFrame to same as frame of image in memeImageView when in Fit mode
            frame.origin.x += memeImageView.frame.origin.x
            frame.origin.y += memeImageView.frame.origin.y
            backingView.frame = frame
        default:
            break
        }
    }
    
    // update items on toolBar/navBar based on editing state
    func configureToolbar(_ state: MemeEditingState) {
                
        // ..for spacing
        let flexBbi = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                      target: nil,
                                      action: nil)
        
        // config toolbar items and nav items
        var items: [UIBarButtonItem]!
        switch state {
        case .defaultState:
            items = [flexBbi, albumBbi, flexBbi, cameraBbi, flexBbi]
            navigationItem.setLeftBarButton(nil, animated: true) // 210806:1502 remove self
            navigationItem.setRightBarButton(doneBbi, animated: true) // 210806:1502 remove self
        case .memeEditingState:
            items = [flexBbi, selectTextFontBbi, flexBbi, selectTextColorBbi, flexBbi, toggleContentAspectBbi, flexBbi]
            navigationItem.setLeftBarButton(shareMemeBbi, animated: true) // 210806:1502 remove self
            navigationItem.setRightBarButton(cancelMemeEditingBbi, animated: true) // 210806:1502 remove self
        }
        
        setToolbarItems(items, animated: true) // 210806:1502 remove self
    }
    
    // update UI meme editing state (tool/nav bar buttons)
    func updateUI(_ state: MemeEditingState) {
        
        // config toolbar
        configureToolbar(state)
        
        // reset font and text color to default index 0
        fontIndex = 0
        colorIndex = 0
        
        // remove existing backingView..about to create new backingView
        if let _ = backingView {
            backingView.removeFromSuperview()
            backingView = nil
        }
        
        // update UI elements
        switch state {
        case .defaultState:
            // place default image and default to aspectFit
            memeImageView.contentMode = .scaleAspectFit
            memeImageView.image = UIImage(named: DEFAULT_PHOTO)
        case .memeEditingState:
            // update memeImageView with currentImage (just selected/snapped photo)
            // ..or alternatively with meme to be edited
            if let image = memeToBeEdited?.originalImage {
                originalImage = image
            }
            memeImageView.image = originalImage

            // create backingView. Default state if bad image or frame
            if let view = createBackingView(imageView: memeImageView) {
                backingView = view
                self.view.addSubview(backingView)
                
                // editing sent meme..duplicate text, font, color
                if let meme = memeToBeEdited {
                    topTextField.text = meme.topText
                    bottomTextField.text = meme.bottomText
                    fontIndex = meme.fontIndex ?? 0
                    colorIndex = meme.colorIndex ?? 0
                    updateTextFieldTextAttributes()
                }
            } else {
                updateUI(.defaultState)
                showAlert(MemeEditorError.memeImageError)
            }
        }
    }
    
    // create a backing view for an imageView. The backing view is a UIView with textFields constrained at top
    // and bottom of view. The frame is the scaled frame of the UIImage within the imageView
    func createBackingView(imageView: UIImageView) -> UIView? {
        
        // verify good UIImage/frame
        guard var frame = imageView.imageFrame() else {
            return nil
        }
        
        // position origin offset by origin of imageView..account for margin and safe area of self.view
        frame.origin.x += imageView.frame.origin.x
        frame.origin.y += imageView.frame.origin.y
        let uiView = UIView(frame: frame)
        uiView.backgroundColor = UIColor.clear
        
        // create top textField and configure
        // 210806:1538 cleanup/abstraction per reviewer comment
        topTextField = UITextField()
        anchorTextFieldToViewAndConfigure(textField: topTextField,
                                          view: uiView,
                                          anchorTop: true)

        // create bottom textField and configure
        // 210806:1538 cleanup/abstraction per reviewer comment
        bottomTextField = UITextField()
        anchorTextFieldToViewAndConfigure(textField: bottomTextField,
                                          view: uiView,
                                          anchorTop: false)
        return uiView
    }
    
    // 210806:1520 Per reviewer comment, helper method for code abstraction
    func anchorTextFieldToViewAndConfigure(textField: UITextField, view: UIView, anchorTop: Bool) {
        /*
         for a previously created textField and view, add textField as subview and anchor
         to top or bottom... anchor to top if anchorTop is true, bottom if false. Config textField
         */
        view.addSubview(textField)
        let leading = textField.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailing = textField.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        var text: String!
        var constraint: NSLayoutConstraint!
        if  anchorTop {
            constraint = textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
            text = DEFAULT_TOP_TEXT
        } else {
            constraint = textField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
            text = DEFAULT_BOTTOM_TEXT
        }
        
        configureTextFields(textField: textField, defaultText: text)
        
        leading.isActive = true
        trailing.isActive = true
        constraint.isActive = true
    }
    
    // configure a textField with default config
    func configureTextFields(textField: UITextField, defaultText: String) {

        // set default properties
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = defaultText
        textField.autocapitalizationType = .allCharacters
        textField.borderStyle = .none
        textField.adjustsFontSizeToFitWidth = true // 210806:1542 Add per reviewer comment
        
        // assign text attrib. Use default at index 0 from arrays
        let textAttibutes = createTextAttribute(name: textAttributeNameArray[0],
                                                   color: textColorArray[0])
        textField.defaultTextAttributes = textAttibutes
        textField.textAlignment = .center
    }
    
    // create and config UIBarButtonItems used in app
    func createBarButtonItems() {
        
        // done with Meme Editor
        // 210806:1600 Use abstracted function per Udacity review
        doneBbi = createBarButtonItemWithSystemItem(item: .done,
                                                    selector: #selector(doneBbiPressed(_:)))
        // cancel editing meme
        // 210806:1600 Use abstracted function per Udacity review
        cancelMemeEditingBbi = createBarButtonItemWithSystemItem(item: .cancel,
                                                                 selector: #selector(cancelEditingMemeBbiPressed(_:)))
        // share meme
        // 210806:1600 Use abstracted function per Udacity review
        shareMemeBbi = createBarButtonItemWithSystemItem(item: .action,
                                                         selector: #selector(shareMemeBbiPressed(_:)))
        
        // invoke imagePicker with camera as image source
        // 210806:1600 Use abstracted function per Udacity review
        cameraBbi = createBarButtonItemWithSystemItem(item: .camera,
                                                      selector: #selector(retrievePhoto(_:)))
        // camer enable. Verify iOS device has camera
        cameraBbi.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // invoke imagePicker with photo album as image source
        // 210806:1609 Use abstracted function per Udacity review
        albumBbi = createBarButtonItemWithTitle(title: ALBUM_BBI_NAME,
                                                selector: #selector(retrievePhoto(_:)))
               
        // toggle the meme image, aspectFit <-> aspectFill
        // 210806:1609 Use abstracted function per Udacity review
        toggleContentAspectBbi = createBarButtonItemWithTitle(title: PHOTO_ASPECT_FILL,
                                                              selector: #selector(toggleFillFitPhoto(_:)))
        
        // select text font
        // 210806:1609 Use abstracted function per Udacity review
        selectTextFontBbi = createBarButtonItemWithTitle(title: FONT_BBI_NAME,
                                                         selector: #selector(fontColorBbiPressed(_:)))
        
        // select text color
        // 210806:1609 Use abstracted function per Udacity review
        selectTextColorBbi = createBarButtonItemWithTitle(title: COLOR_BBI_NAME,
                                                          selector: #selector(fontColorBbiPressed(_:)))
    }
    
    // create and return UIBarButtonItem with title
    // 210806:1604 Per Udacity review, abstract common code into single function
    func createBarButtonItemWithTitle( title: String, selector: Selector) -> UIBarButtonItem {
        let bbi = UIBarButtonItem(title: title,
                                  style: .plain,
                                  target: self,
                                  action: selector)
        return bbi
    }
    
    // create and return UIBarButtonItem with system item
    // 210806:1604 Per Udacity review, abstract common code into single function
    func createBarButtonItemWithSystemItem( item: UIBarButtonItem.SystemItem, selector: Selector) -> UIBarButtonItem {
        let bbi = UIBarButtonItem(barButtonSystemItem: item,
                                  target: self,
                                  action: selector)
        return bbi
    }
    
    // create a textAttribute
    func createTextAttribute(name: String, color: UIColor) -> [NSAttributedString.Key : Any] {
        
        // test for valid font... default to system font
        var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: color]
        if let font = UIFont(name: name, size: DEFAULT_TEXT_SIZE) {
            attributes[NSAttributedString.Key.strokeWidth] = TEXT_STROKE_WIDTH
            attributes[NSAttributedString.Key.strokeColor] = TEXT_STROKE_COLOR
            attributes[NSAttributedString.Key.font] = font
        } else {
            attributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize:DEFAULT_TEXT_SIZE)
        }
        return attributes
    }
}

// MARK: Keyboard view shift functions
extension MemeEditorViewController {
    
    // add notification for keyboard presentation
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    // remove notifications for keyboard
    func unsubscribeToKeyboardNotifications() {
        
        // 210806:1615 Update per Udacity reviewer comment
        NotificationCenter.default.removeObserver(self)
    }
    
    // keyboard about to show
    @objc func keyboardWillShow(_ notification: Notification) {
        
        // shift up only when bottom textField is editing
        guard bottomTextField.isEditing else {
            return
        }
        let shift = getKeyboardHeight(notification)
        view.frame.origin.y -= shift
    }
    
    // keybaord about to hide
    @objc func keyboardWillHide(_ notification: Notification) {
        
        // shift down only if bottom keyboard is editing
        guard bottomTextField.isEditing else {
            return
        }
        view.frame.origin.y = 0
    }
    
    // retrieve keyboard height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}

// MARK: ImagePicker delegate functions
extension MemeEditorViewController {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // no photo selected. Dismiss
        dismiss(animated: true, completion: {})
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // finished picking image. Retrieve image. Test for original or edited version of image
        var image: UIImage? = nil
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        
        // test for good image
        guard let _ = image else {
            // bad image. Return to default state
            dismiss(animated: true, completion: {
                self.updateUI(.defaultState)
                self.showAlert(MemeEditorError.memeImageError)
            })
            return
        }
        
        // good image. Assign and go to meme editing state
        originalImage = image
        dismiss(animated: true, completion: {
            self.updateUI(.memeEditingState)
        })
    }
}

// MARK: UITextField delegate functions
extension MemeEditorViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // return button pressed. End editing
        textField.resignFirstResponder()
        
        // enable share and cancel bbi's
        shareMemeBbi.isEnabled = true
        cancelMemeEditingBbi.isEnabled = true
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // disable share and cancel bbi's while editing text
        shareMemeBbi.isEnabled = false
        cancelMemeEditingBbi.isEnabled = false
    }
}
