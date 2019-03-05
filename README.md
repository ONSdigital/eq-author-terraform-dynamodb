# eq-author-terraform-dynamodb

Terraform project that creates the DynamoDB infrastructure for EQ Author

To import this module add the following code into you Terraform project:

```
module "author-dynamodb" {
  source                                 = "github.com/ONSdigital/eq-author-terraform-dynamodb"
  env                                    = "${var.env}"
  aws_access_key                         = "${var.aws_access_key}"
  aws_secret_key                         = "${var.aws_secret_key}"
  slack_alert_sns_arn                    = "${module.survey-runner-alerting.slack_alert_sns_arn}"
}
```

To run this module on its own run the following code: (Replacing 'XXX' with your values)

```
terraform apply -var "env=XXX" \
                -var "aws_access_key=XXX" \
                -var "aws_secret_key=XXX" \
                -var "slack_alert_sns_arn=XXX"
```
