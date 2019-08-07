/*:
 
 ## Fueled Apprenticeship Test
 
 A blogging platform stores the following information that is available through separate API endpoints:
 + user accounts
 + blog posts for each user
 + comments for each blog post
 
 **Objective:**
 The organization needs to identify the 3 most engaging bloggers on the platform. Using only Swift and the Foundation library, output the top 3 users with the highest average number of comments per post in the following format:
 + `[name]` - Id: `[id]`, Score: `[average_comments]`
 + (ex., Ervin Howell - Id: 2, Score: 6.1)
 
 Instead of connecting to a remote API, we are providing this data in form of JSON files, which have been made accessible through a custom Resource enum with a `data` method that provides the contents of the file.
 
 **We Are Looking to Evaluate:**
 1. How you choose to model your data
 2. How you transform the raw data into your data model
 3. How you use your models to calculate this average value
 4. How you manipulate this new info to select the users
 
 */

import Foundation

/*:
 1. First, start by modeling the data objects that will be used.
 */
struct UserInfo: Codable {
  let id: Int
  let name: String
  let username: String
  let email: String
  let address: AddressInfo
  let phone: String
  let website: URL
  let company: CompanyDetails
}

struct AddressInfo: Codable {
  let street: String
  let suite: String
  let city: String
  let zipcode: String
}

struct CompanyDetails: Codable {
  let name: String
  let catchPhrase: String
  let bs: String
}

struct PostDetails: Codable {
  let userId: Int
  let id: Int
  let title: String
  let body: String
}

struct CommentInfo: Codable {
  let postId: Int
  let email: String
  let name: String
  let body: String
  let id: Int
}
/*:
 2. Next, decode the JSON source using `Resource.users.data()`.
 */
func loadData<T: Codable>(resource: Resource) -> [T] {
  var userInformation = [T]()
  var data: Data!
  switch resource {
  case .users:
    data = Resource.users.data()
  case .comments:
    data = Resource.comments.data()
  case .posts:
    data = Resource.posts.data()
  }
  do {
    userInformation = try JSONDecoder().decode([T].self, from: data)
  } catch {
    print(error)
  }
  return userInformation
}

let userInfo = loadData(resource: Resource.users) as [UserInfo]
let posts = loadData(resource: Resource.posts) as [PostDetails]
let comments = loadData(resource: Resource.comments) as [CommentInfo]
/*:
 3. Next, use your populated models to calculate the average number of comments per user.
 */
func getCommentsPerPost(comments: [CommentInfo]) -> [Int:Int]{
  var dictOfCommentsPerPost = [Int:Int]()
  for comment in comments{
    if let value = dictOfCommentsPerPost[comment.postId] {
      dictOfCommentsPerPost[comment.postId] = value + 1
    } else {
      dictOfCommentsPerPost[comment.postId] = 1
    }
  }
  return dictOfCommentsPerPost
}

func commentsPerUser(posts: [PostDetails], postIdCommentDictionary: [Int:Int]) -> [Int: [Int]] {
  var dictCommentsPerUser = [Int:[Int]]()
  for post in posts {
    for (postID, commentsCount) in postIdCommentDictionary {
      if post.id == postID {
        var tempArray = [Int]()
        if let val = dictCommentsPerUser[post.userId] {
          tempArray = val
          tempArray.append(commentsCount)
          print(tempArray)
          dictCommentsPerUser[post.userId] = tempArray
        } else {
          tempArray.append(commentsCount)
          dictCommentsPerUser[post.userId] = tempArray
        }
      }
    }
  }
  return dictCommentsPerUser
}

func getAverageOfCommentsPerBlogger(commentCountPerBlogger: [Int: [Int]]) -> [Int:Double]{
  var averageOfCommentsPerBlogger = [Int:Double]()
  for (postID, arrayOfComments) in commentCountPerBlogger {
    let sumOfComments = arrayOfComments.reduce(0, +)
    let average: Double = Double(sumOfComments) / Double(arrayOfComments.count)
    if let _ = averageOfCommentsPerBlogger[postID]{
      averageOfCommentsPerBlogger[postID] = average
    } else {
      averageOfCommentsPerBlogger[postID] = average
    }
  }
  return averageOfCommentsPerBlogger
}
/*:
 4. Finally, use your calculated metric to find the 3 most engaging bloggers, sort order, and output the result.
 */
func topBloggersByIdAndAverage(dictOfAveragePerUser: [Int:Double], range: Int) ->  [Int:Double] {
  var dictTopUsersByAverage = [Int:Double]()
  let sortedDictionary = dictOfAveragePerUser.sorted(by: {$0.value > $1.value})
  for (userID, average) in sortedDictionary[0..<range] {
    dictTopUsersByAverage[userID] = average
  }
  return dictTopUsersByAverage
}

func infoTopEngagingBloggers(dictOfTopBloggers: [Int:Double], userDataSet: [UserInfo]) -> [String] {
  var topBloggersArray = [String]()
  var stringTemp = ""
  for (userID, average) in dictOfTopBloggers.sorted(by: {$0.value > $1.value}) {
    for user in userDataSet {
      if userID == user.id {
        let formattedAverage = String(format: "%.2f", average)
        stringTemp = "\(user.name) - Id: \(userID), Score: \(formattedAverage)"
      }
    }
    topBloggersArray.append(stringTemp)
  }
  return topBloggersArray
}

//=====================================================Getting Top Users======================================================

let commentsPerPostDict = getCommentsPerPost(comments: comments)
let commentsPerBlogger = commentsPerUser(posts: posts, postIdCommentDictionary: commentsPerPostDict)
let averagePerUser = getAverageOfCommentsPerBlogger(commentCountPerBlogger: commentsPerBlogger)
let dictTopThreeBloggers = topBloggersByIdAndAverage(dictOfAveragePerUser: averagePerUser, range: 5)
print("This is the information for the top three users: \(infoTopEngagingBloggers(dictOfTopBloggers: dictTopThreeBloggers, userDataSet: userInfo))")


