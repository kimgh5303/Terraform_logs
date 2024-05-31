resource "aws_iam_role" "ec2_ssm_role" {
  name = "kgh-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_role_attach1" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy" "kinesis_policy" {
  name   = "KinesisPutRecordsPolicy"
  role   = aws_iam_role.ec2_ssm_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:PutRecords",
          "kinesis:PutRecord"
        ]
        Resource = "arn:aws:kinesis:ap-northeast-2:381492154999:stream/kgh-kinesis-datastreams"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = "kgh-ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}