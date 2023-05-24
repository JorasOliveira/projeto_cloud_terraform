#creating a simple notification sistem to send out emails with the cloudWatch alarms
locals {
  emails = ["jorascco@al.insper.edu.br"]
}


resource "aws_sns_topic" "stack_notifications" {
  name   = "StackNotifications_AQUA"
}


resource "aws_sns_topic_subscription" "email_subscription" {
  count     = length(local.emails)
  topic_arn = aws_sns_topic.stack_notifications.arn
  protocol  = "email"
  #endpoint  = "jorascco@al.insper.edu.br" #change to your email
  endpoint  = local.emails[count.index]

  
}

#creating a cloudWatch alarm to monitor when something is stored in the S3 bucket
resource "aws_cloudwatch_metric_alarm" "example_alarm" {
  alarm_name          = "bucket_upload_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfObjectsUploaded"
  namespace           = "AWS/S3"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "1"
  alarm_description   = "Alarm triggered when objects are uploaded to the S3 bucket."
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]

  dimensions = {
    BucketName = aws_s3_bucket.bucket.id
  }
}


#for every stack we create a cloudWatch alarm to monitor the number of resources in the stack
resource "aws_cloudwatch_metric_alarm" "resource_count_alarm_0" {
  alarm_name          = "ResourceCountAlarm_0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ResourceCount"
  namespace           = "AWS/CloudFormation"
  period              = 60
  statistic           = "Average" 
  threshold           = 12 #change to the number of resources you want to monitor, the yaml script used as a template for the stacks has 31 resources
  alarm_description   = "Monitors the count of resources in the CloudFormation stack"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]
  dimensions = {
    StackName = aws_cloudformation_stack.mission_profile.id
  }
}


resource "aws_cloudwatch_metric_alarm" "resource_count_alarm_1" {
  alarm_name          = "ResourceCountAlarm_1"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ResourceCount"
  namespace           = "AWS/CloudFormation"
  period              = 60
  statistic           = "Average"
  threshold           = 5 #change to the number of resources you want to monitor
  alarm_description   = "Monitors the count of resources in the CloudFormation stack"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]
  dimensions = {
    StackName = aws_cloudformation_stack.data_processing.id
  }
}


#CPU utilization alarms

#too low
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_too_low_0" {
  alarm_name          = "CPU_utilizationAlarm_LOW_0"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Triggered when CPU utilization is below 20%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]  
  dimensions = {
    InstanceId = aws_cloudformation_stack.mission_profile.id
  }
}


resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_too_low_1" {
  alarm_name          = "CPU_utilizationAlarm_LOW_1"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Triggered when CPU utilization is below 20%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]  

  dimensions = {
    InstanceId = aws_cloudformation_stack.data_processing.id
  }
}

#too high
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_too_high_0" {
  alarm_name          = "CPU_UtilizationAlarm_HIGH_0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Triggered when CPU utilization is above 90%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]  

  dimensions = {
    InstanceId = aws_cloudformation_stack.mission_profile.id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_too_high_1" {
  alarm_name          = "CPU_UtilizationAlarm_HIGH_1"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Triggered when CPU utilization is above 90%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]  

  dimensions = {
    InstanceId = aws_cloudformation_stack.data_processing.id
  }
}

#Memory utilization alarms
resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm_0" {
  alarm_name          = "MemoryUtilizationAlarm_0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Triggered when memory utilization is above 90%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]   
  dimensions = {
    InstanceId = aws_cloudformation_stack.mission_profile.id  
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm_1" {
  alarm_name          = "MemoryUtilizationAlarm_1"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Triggered when memory utilization is above 90%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]   
  dimensions = {
    InstanceId = aws_cloudformation_stack.data_processing.id  
  }
}
