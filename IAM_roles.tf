variable "user_names" {
  type    = list(string)
  default = ["JorasOliveira"]  # Add the list of user names here
}

resource "aws_iam_user" "users" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}

resource "aws_iam_user_policy_attachment" "user_attachment" {
  count = length(var.user_names)
  user       = aws_iam_user.users[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "user_service_role_attachment" {
  count = length(var.user_names)
  user       = aws_iam_user.users[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_user_policy_attachment" "user_cloudwatch_agent_attachment" {
  count = length(var.user_names)
  user       = aws_iam_user.users[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_user_policy_attachment" "user_ssm_managed_instance_attachment" {
  count = length(var.user_names)
  user       = aws_iam_user.users[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
