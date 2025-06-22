data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms_access_for_endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms_access_for_endpoint_AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms_access_for_endpoint.name
}

resource "aws_iam_role" "dms_cloudwatch_logs_role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_logs_role_AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms_cloudwatch_logs_role.name
}

resource "aws_iam_role" "dms_vpc_role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role_AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms_vpc_role.name
}

resource "aws_dms_replication_subnet_group" "replication_sg" {
  replication_subnet_group_description = "replication subnet group"
  replication_subnet_group_id          = "bootcamp-replication-sg"

  subnet_ids = var.subnet_ids
}

resource "aws_dms_replication_instance" "bootcamp_dms_instance" {
  allocated_storage           = 5
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  replication_instance_class  = "dms.t3.micro"
  replication_instance_id     = "bootcamp-dms-replication-instance"
  replication_subnet_group_id = aws_dms_replication_subnet_group.replication_sg.id

  depends_on = [
    aws_iam_role_policy_attachment.dms_access_for_endpoint_AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms_cloudwatch_logs_role_AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms_vpc_role_AmazonDMSVPCManagementRole
  ]
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "bootcamp-dms-source-endpoint-id"
  endpoint_type = "source"
  engine_name   = "postgres"
  server_name   = var.source_db_server
  username      = var.source_db_username
  password      = var.source_db_password
  database_name = var.source_db_name
  port          = 5432
}


resource "aws_dms_endpoint" "target" {
  endpoint_id   = "bootcamp-dms-target-endpoint-id"
  endpoint_type = "target"
  engine_name   = "postgres"
  server_name   = var.target_db_server
  username      = var.target_db_username
  password      = var.target_db_password
  database_name = var.target_db_name
  port          = 5432
}

resource "aws_dms_replication_task" "bootcamp_dms_task" {
  migration_type           = "full-load"
  replication_instance_arn = aws_dms_replication_instance.bootcamp_dms_instance.replication_instance_arn
  replication_task_id      = "bootcamp-dms-replication-task-tf"
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn
  table_mappings = jsonencode({
    rules = [
      {
        rule-type = "selection",
        rule-id   = "1",
        rule-name = "1",
        object-locator = {
          schema-name = "%",
          table-name  = "%"
        },
        rule-action = "include"
      }
    ]
  })
}
