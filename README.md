# FueledChallenge

A blogging platform stores the following information that is available through separate API endpoints:

1. user accounts
2. blog posts for each user
3. comments for each blog post

Objective: The organization needs to identify the 3 most engaging bloggers on the platform. Using only Swift and the Foundation library, output the top 3 users with the highest average number of comments per post in the following format:

[name] - Id: [id], Score: [average_comments]
(ex., Ervin Howell - Id: 2, Score: 6.1)

Instead of connecting to a remote API, data was provided in form of JSON files, which have been made accessible through a custom Resource enum with a data method that provides the contents of the file.
