# PL/SQL - Medical Allocation Query

This project contains a PL/SQL query designed to manage and track medical allocations for employees within an organization. It retrieves medical entitlement, allocation, and utilization data directly from Oracle database tables, ensuring accuracy and consistency. The query helps HR and Finance teams analyze employee medical benefits, validate eligibility, and generate allocation reports for compliance and decision-making.

## Features
- Fetches employee-wise medical allocation details.
- Tracks entitlements, utilized amounts, and remaining balances.
- Ensures accurate validation of medical claims.
- Optimized query structure for improved performance.
- Can be integrated with Oracle Reports or other reporting tools.

## Usage
1. Connect to Oracle Database.
2. Run the query in SQL Developer or any PL/SQL-supported tool.
3. Pass required parameters (e.g., Employee ID, Date Range).
4. View allocation, usage, and balance results in the output.

## Requirements
- Oracle Database 11g or later  
- SQL Developer / TOAD / Any PL/SQL execution tool  

## Example
```sql
-- Run the allocation query
EXECUTE Medical_Allocation_Query(<EMPLOYEE_ID>, <DATE_RANGE>);
