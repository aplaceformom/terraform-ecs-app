resource "aws_iam_policy" "secrets" {
  count  = length(keys(var.secrets)) != 0 ? 1 : 0
  name   = "${var.name}-secrets-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.secrets.json
}

data "aws_iam_policy_document" "secrets" {
  statement {
    actions = ["ssm:GetParameters", "secretsmanager:GetSecretValue", "kms:Decrypt"]
    resources = [
      for secret in values(var.secrets):
      substr(secret, 0, 8) == "arn:aws:" ? secret : substr(secret, 0, 4) == "key/" ?  "arn:aws:kms:${local.region}:${data.aws_caller_identity.current.account_id}:${secret}" : substr(secret, 0, 1) == "/" ? "arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/${replace(secret, "/^[/]/", "")}" : "arn:aws:secretsmanager:${local.region}:${data.aws_caller_identity.current.account_id}:secret:${secret}"
      ]
  }
}

data "aws_iam_role" "exec_role" {
  name = replace(local.exec_role_arn, "/.*role[/]/", "")
}

resource "aws_iam_role_policy_attachment" "secret" {
  count      = length(keys(var.secrets)) != 0 ? 1 : 0
  role       = data.aws_iam_role.exec_role.name
  policy_arn = aws_iam_policy.secrets[0].arn
}
