//
//  Meme.swift
//  ImagePickerExperiment
//
//  Created by 1203 Broadway on 5/20/21.
//
/*
 About Meme.swift:
 Data object for a Meme. Contains text and image info
 */
import UIKit

struct Meme {
    
    // properties
    let topText:String?
    let bottomText: String?
    let originalImage: UIImage?
    let memedImage: UIImage?
    
    // properties for text attrib, text color..used when editing a sent meme
    // corresponds to array index of text color and attribs
    let fontIndex: Int?
    let colorIndex: Int?
}
