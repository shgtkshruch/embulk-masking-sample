output "rds_endpoint" {
  value       = aws_db_instance.db.endpoint
  description = "The RDS endpoint"
}
