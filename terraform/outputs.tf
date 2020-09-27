output "rds_endpoint" {
  value       = aws_db_instance.db.endpoint
  description = "The RDS endpoint"
}

output "rds_id" {
  value       = aws_db_instance.db.id
  description = "The RDS instance ID"
}
