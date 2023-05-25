resource "aws_iam_user" "example_user" {
  name = "JorasOliveira"
}

resource "aws_iam_user_policy_attachment" "example_user_attachment" {
  user       = aws_iam_user.example_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
