resource "aws_dynamodb_table" "questionnaire_state_table" {
  name           = "${var.env}-questionnaire-state"
  read_capacity  = "${var.questionnaire_state_min_read_capacity}"
  write_capacity = "${var.questionnaire_state_min_write_capacity}"
  hash_key       = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  tags {
    Name        = "${var.env}-questionnaire-state"
    Environment = "${var.env}"
  }

  lifecycle {
    ignore_changes = ["read_capacity", "write_capacity"]
  }
}

resource "aws_appautoscaling_target" "questionnaire_state_table_read_target" {
  max_capacity       = "${var.questionnaire_state_max_read_capacity}"
  min_capacity       = "${var.questionnaire_state_min_read_capacity}"
  resource_id        = "table/${aws_dynamodb_table.questionnaire_state_table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "questionnaire_state_table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.questionnaire_state_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.questionnaire_state_table_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.questionnaire_state_table_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.questionnaire_state_table_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 40
  }
}

resource "aws_appautoscaling_target" "questionnaire_state_table_write_target" {
  max_capacity       = "${var.questionnaire_state_max_write_capacity}"
  min_capacity       = "${var.questionnaire_state_min_write_capacity}"
  resource_id        = "table/${aws_dynamodb_table.questionnaire_state_table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "questionnaire_state_table_write_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.questionnaire_state_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.questionnaire_state_table_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.questionnaire_state_table_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.questionnaire_state_table_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 40
  }
}

resource "aws_cloudwatch_metric_alarm" "questionnaire_state_table_read_throughput" {
  alarm_name          = "${var.env}-dynamodb-questionnaire-state-read-throughput"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "${var.questionnaire_state_max_read_capacity * 0.8 * 60}"
  alarm_description   = "EQ Questionnaire State DynamoDB average consumed read throughput above 80% of maximum for past 60 seconds"
  alarm_actions       = ["${var.slack_alert_sns_arn}"]

  dimensions {
    TableName = "${aws_dynamodb_table.questionnaire_state_table.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "questionnaire_state_table_write_throughput" {
  alarm_name          = "${var.env}-dynamodb-questionnaire-state-write-throughput"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsumedWriteCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "${var.questionnaire_state_max_write_capacity * 0.8 * 60}"
  alarm_description   = "EQ Questionnaire State DynamoDB average consumed write throughput above 80% of maximum for past 60 seconds"
  alarm_actions       = ["${var.slack_alert_sns_arn}"]

  dimensions {
    TableName = "${aws_dynamodb_table.questionnaire_state_table.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "questionnaire_state_table_provisioned_read_throughput" {
  alarm_name          = "${var.env}-dynamodb-questionnaire-state-provisioned-read-throughput"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ProvisionedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${var.questionnaire_state_max_read_capacity * 0.8}"
  alarm_description   = "EQ Questionnaire State DynamoDB provisioned read throughput above 80% of maximum for past 60 seconds"
  alarm_actions       = ["${var.slack_alert_sns_arn}"]

  dimensions {
    TableName = "${aws_dynamodb_table.questionnaire_state_table.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "questionnaire_state_table_provisioned_write_throughput" {
  alarm_name          = "${var.env}-dynamodb-questionnaire-state-provisioned-write-throughput"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ProvisionedWriteCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${var.questionnaire_state_max_write_capacity * 0.8}"
  alarm_description   = "EQ Questionnaire State DynamoDB provisioned write throughput above 80% of maximum for past 60 seconds"
  alarm_actions       = ["${var.slack_alert_sns_arn}"]

  dimensions {
    TableName = "${aws_dynamodb_table.questionnaire_state_table.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "questionnaire_state_table_read_throttled" {
  alarm_name          = "${var.env}-dynamodb-questionnaire-state-read-throttled"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "EQ Questionnaire State DynamoDB has had at least 1 read throttle error in the past 60 seconds"
  alarm_actions       = ["${var.slack_alert_sns_arn}"]

  dimensions {
    TableName = "${aws_dynamodb_table.questionnaire_state_table.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "questionnaire_state_table_write_throttled" {
  alarm_name          = "${var.env}-dynamodb-questionnaire-state-write-throttled"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "EQ Questionnaire State DynamoDB has had at least 1 write throttle error in the past 60 seconds"
  alarm_actions       = ["${var.slack_alert_sns_arn}"]

  dimensions {
    TableName = "${aws_dynamodb_table.questionnaire_state_table.name}"
  }
}

output "questionnaire_state_table_name" {
  value = "${aws_dynamodb_table.questionnaire_state_table.name}"
}

output "questionnaire_state_table_arn" {
  value = "${aws_dynamodb_table.questionnaire_state_table.arn}"
}