#!/bin/bash
# MySQL setup script for Tax Compliance App
# Run with: sudo bash setup-mysql.sh

MYSQL_ROOT_PASS="${MYSQL_ROOT_PASS:-}"

echo "Setting up MySQL database and user for Tax Compliance App..."

if [ -n "$MYSQL_ROOT_PASS" ]; then
    mysql -u root -p"$MYSQL_ROOT_PASS" <<SQL
CREATE DATABASE IF NOT EXISTS tax_compliance_db;
CREATE USER IF NOT EXISTS 'taxapp'@'localhost' IDENTIFIED BY 'taxapp123';
GRANT ALL PRIVILEGES ON tax_compliance_db.* TO 'taxapp'@'localhost';
FLUSH PRIVILEGES;
SQL
else
    # Try with sudo (for auth_socket plugin)
    sudo mysql <<SQL
CREATE DATABASE IF NOT EXISTS tax_compliance_db;
CREATE USER IF NOT EXISTS 'taxapp'@'localhost' IDENTIFIED BY 'taxapp123';
GRANT ALL PRIVILEGES ON tax_compliance_db.* TO 'taxapp'@'localhost';
FLUSH PRIVILEGES;
SQL
fi

if [ $? -eq 0 ]; then
    echo "Success! Database 'tax_compliance_db' created."
    echo "User 'taxapp' with password 'taxapp123' granted access."
    echo ""
    echo "Update application.properties if needed:"
    echo "  spring.datasource.url=jdbc:mysql://localhost:3306/tax_compliance_db?useSSL=false&serverTimezone=UTC"
    echo "  spring.datasource.username=taxapp"
    echo "  spring.datasource.password=taxapp123"
else
    echo "Failed. Make sure MySQL is running and you have root access."
    echo "Try: sudo mysql -e \"SELECT 1;\""
fi
