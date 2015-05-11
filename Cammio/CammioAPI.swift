//
//  CammioAPI.swift
//  Cammio Recruiter
//
//  Created by Bas Dirkse on 19-04-15.
//  Copyright (c) 2015 Cammio. All rights reserved.
//

import UIKit
import Alamofire

//MARK: Extensions

extension Int {
  func hexString() -> String {
    return NSString(format:"%02x", self) as String
  }
}

extension NSData {
  func hexString() -> String {
    var string = String()
    for i in UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(bytes), count: length) {
      string += Int(i).hexString()
    }
    return string
  }
  
  func MD5() -> NSData {
    let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
    CC_MD5(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
    return NSData(data: result)
  }
  
  func SHA1() -> NSData {
    let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
    CC_SHA1(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
    return NSData(data: result)
  }
}

extension String {
  func MD5() -> String {
    return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.MD5().hexString()
  }
  
  func SHA1() -> String {
    return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.SHA1().hexString()
  }
}

extension NSDate {
  func toShortDateTime() -> String! {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    formatter.timeStyle = .ShortStyle
    let dateString = formatter.stringFromDate(self)
    return dateString
  }
  
  func toShortDate() -> String! {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    formatter.timeStyle = .NoStyle
    let dateString = formatter.stringFromDate(self)
    return dateString
  }
}

extension Alamofire.Request {
  class func imageResponseSerializer() -> Serializer {
    return { request, response, data in
      if data == nil {
        return (nil, nil)
      }
      let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
      return (image, nil)
    }
  }
  
  func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
    return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
      completionHandler(request, response, image as? UIImage, error)
    })
  }
}

//MARK: CammioData

class CammioData {
  
  static let kWebsite	= "XXXXXXX"
  static let kUsername	= "XXXXX"
  static let kPassword	= "XXXX"
  static let kWowzaEndpointFirstPart	= "XXXXX"
  static let kWowzaEndpointSecondPart	= "XXXX"
  
  //MARK: Templates
  class func getTemplatesForPage(page: Int, completion: (result: [Template]?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ListTemplates(page)).responseJSON { (_,  response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var templates: [Template]?
        templates <-- JSON!["vacancies"]
        if response?.statusCode == 200 {
          completion(result: templates, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  class func getTemplatesWithType(templateType: TemplateType, forPage: Int, completion: (result: [Template]?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ListTemplatesWithType(templateType, forPage)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var templates: [Template]?
        templates <-- JSON!["vacancies"]
        if response?.statusCode == 200 {
          completion(result: templates, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  class func getTemplateWithID(id: Int, completion: (result: Template?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ShowTemplate(id)).responseJSON { (_,  response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var template: Template?
        template <-- JSON!["vacancy"]
        if response?.statusCode == 200 {
          completion(result: template, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  class func deleteTemplateWithID(id: Int, completion: (success: Bool, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.DestroyTemplate(id)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(success: false, error: error)
      }
      else {
        if response?.statusCode == 200 {
          completion(success: true, error: nil)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(success: false, error: error)
        }
      }
    }
  }
  
  //MARK: Invitations
  class func getInvitationsForPage(page: Int, completion: (result: [Invitation]?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ListInvitations(page)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var invitations: [Invitation]?
        invitations <-- JSON!["invitations"]
        if response?.statusCode == 200 {
          completion(result: invitations, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  class func getInvitationsWithTemplateType(templateType: TemplateType, forPage: Int, completion: (result: [Invitation]?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ListInvitationWithTemplateType(templateType, forPage)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var invitations: [Invitation]?
        invitations <-- JSON!["invitations"]
        if response?.statusCode == 200 {
          completion(result: invitations, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  class func getInvitationWithID(id: Int, completion: (result: Invitation?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ShowInvitation(id)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var invitation: Invitation?
        invitation <-- JSON!["invitation"]
        if response?.statusCode == 200 {
          completion(result: invitation, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  class func deleteInvitationWithID(id: Int, completion: (success: Bool, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.DestroyInvitation(id)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(success: false, error: error)
      }
      else {
        if response?.statusCode == 200 {
          completion(success: true, error: nil)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(success: false, error: error)
        }
      }
    }
  }
  
  //MARK: Interviews
  class func getInterviewsForPage(page: Int, completion: (result: [Interview]?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ListInterviews(page)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var interviews: [Interview]?
        interviews <-- JSON!["interviews"]
        if response?.statusCode == 200 {
          completion(result: interviews, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  class func getInterviewsWithTemplateType(templateType: TemplateType, forPage: Int, completion: (result: [Interview]?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ListInterviewsWithTemplateType(templateType, forPage)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var interviews: [Interview]?
        interviews <-- JSON!["interviews"]
        if response?.statusCode == 200 {
          completion(result: interviews, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  class func getInterviewWithID(id: Int, completion: (result: Interview?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ShowInvitation(id)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var interview: Interview?
        interview <-- JSON!["interview"]
        if response?.statusCode == 200 {
          completion(result: interview, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  //MARK: Recordings
  class func getRecordingsForInterviewWithID(id: Int, completion: (result: [Recording]?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ListInterviewRecordings(id)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var recordings: [Recording]?
        recordings <-- JSON!["recordings"]
        if response?.statusCode == 200 {
          completion(result: recordings, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
  //MARK: Reviews
  class func getReviewsForInterviewWithID(id: Int, completion: (result: [Review]?, error: NSError?) -> ()) {
    Alamofire.request(CammioRouter.ListInterviewReviews(id)).responseJSON { (_, response, JSON, error) in
      if (error != nil) {
        completion(result: nil, error: error)
      }
      else {
        var reviews: [Review]?
        reviews <-- JSON!["reviews"]
        if response?.statusCode == 200 {
          completion(result: reviews, error: error)
        }
        else {
          let message = JSON!.valueForKey("error") as! String
          let error = NSError(domain: "Cammio", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
          completion(result: nil, error: error)
        }
      }
    }
  }
  
}

enum TemplateType: Int {
  case Automated = 0, Live, Pitch
}

//MARK: Router

enum CammioRouter: URLRequestConvertible {
  static let baseURLString = "XXXXX"
  static let username = "XXXXX"
  static let password = "XXXXX"
  static let limit = 20
  static let loginString = "\(username):\(password)"
  static let loginData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
  static let base64LoginString = "Basic \(loginData.base64EncodedStringWithOptions(nil))"
  
  case ListTemplates(Int)
  case ListTemplatesWithType(TemplateType, Int)
  case ShowTemplate(Int)
  case DestroyTemplate(Int)
  case ListTemplateInvitations(Int)
  case ListTemplateInterviews(Int)
  case ListInvitations(Int)
  case ListInvitationWithTemplateType(TemplateType, Int)
  case ShowInvitation(Int)
  case CreateInvitation([String: AnyObject])
  case UpdateInvitation(Int, [String: AnyObject])
  case DestroyInvitation(Int)
  case ListInterviews(Int)
  case ShowInterview(Int)
  case ListInterviewsWithTemplateType(TemplateType, Int)
  case ListInterviewReviews(Int)
  case ListInterviewRecordings(Int)
  
  var method: Alamofire.Method {
    switch self {
    case .CreateInvitation:
      return .POST
    case .ShowInterview, .ListInterviews, .ListInvitations, .ShowInvitation, .ListTemplates, .ShowTemplate, .ListTemplateInvitations, .ListTemplateInterviews, .ListInvitationWithTemplateType, .ListTemplatesWithType, .ListInterviewsWithTemplateType, .ListInterviewReviews, .ListInterviewRecordings:
      return .GET
    case .UpdateInvitation:
      return .PUT
    case .DestroyInvitation, DestroyTemplate:
      return .DELETE
    }
  }
  
  var path: String {
    switch self {
    case .ListInterviews, .ListInterviewsWithTemplateType:
      return "interviews"
    case .CreateInvitation, .ListInvitations, .ListInvitationWithTemplateType:
      return "invitations"
    case .ShowInterview(let interview_id):
      return "interviews/\(interview_id)"
    case .ShowInvitation(let invitation_id):
      return "invitations/\(invitation_id)"
    case .UpdateInvitation(let invitation_id,_):
      return "invitations/\(invitation_id)"
    case .DestroyInvitation(let invitation_id):
      return "invitations/\(invitation_id)"
    case .ListTemplates, .ListTemplatesWithType:
      return "vacancies"
    case .ShowTemplate(let template_id):
      return "vacancies/\(template_id)"
    case .ListTemplateInvitations(let template_id):
      return "vacancies/\(template_id)/invitations"
    case .ListTemplateInterviews(let template_id):
      return "vacancies/\(template_id)/interviews"
    case .DestroyTemplate(let template_id):
      return "vacancies/\(template_id)"
    case .ListInterviewReviews(let interview_id):
      return "interviews/\(interview_id)/reviews"
    case .ListInterviewRecordings(let interview_id):
      return "interviews/\(interview_id)/recordings"
    }
  }
  
  var URLRequest: NSURLRequest {
    let URL = NSURL(string: CammioRouter.baseURLString)!
    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
    mutableURLRequest.HTTPMethod = method.rawValue
    mutableURLRequest.setValue(CammioRouter.base64LoginString, forHTTPHeaderField: "Authorization")
    mutableURLRequest.timeoutInterval = 30
    
    switch self {
    case .CreateInvitation(let parameters):
      return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
    case .UpdateInvitation(_, let parameters):
      return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    case .ListInterviews(let page):
      let parameters = ["offset": page, "limit": CammioRouter.limit]
      return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    case .ListInvitations(let page):
      let parameters = ["offset": page, "limit": CammioRouter.limit]
      return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    case .ListTemplates(let page):
      let parameters = ["offset": page, "limit": CammioRouter.limit]
      return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    case .ListInvitationWithTemplateType(let type, let page):
      let parameters = ["offset": page, "limit": CammioRouter.limit, "type": type.rawValue]
      return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    case .ListTemplatesWithType(let type, let page):
      let parameters = ["offset": page, "limit": CammioRouter.limit, "type": type.rawValue]
      return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    case .ListInterviewsWithTemplateType(let type, let page):
      let parameters = ["offset": page, "limit": CammioRouter.limit, "type": type.rawValue]
      return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    default:
      return mutableURLRequest
    }
  }
}

