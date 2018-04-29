# Allow the instance to put metrics to cloudwatch so that
# we're able to make use of ASG alarms later (or whatever).
data "aws_iam_policy_document" "put-metrics" {
  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:putMetricData",
    ]

    resources = [
      "*",
    ]
  }
}

# As a default policy for the EC2, always take the AssumeRole
# action so the instance's apps can take advatange of not
# requiring static access tokens and secret keys.
data "aws_iam_policy_document" "default" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

# Create the role with the default AssumeRole policy.
resource "aws_iam_role" "main" {
  name               = "default"
  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

# Attach the put-metrics role policy to the default role so that
# the role can have the effect of being able to put metrics.
resource "aws_iam_role_policy" "main" {
  name   = "put-metrics"
  role   = "${aws_iam_role.main.name}"
  policy = "${data.aws_iam_policy_document.put-metrics.json}"
}

# Create a profile to be shipped with the instance so that
# the instance can contain the role policies assigned.
resource "aws_iam_instance_profile" "main" {
  name = "put-metrics-profile"
  role = "${aws_iam_role.main.name}"
}
