# Microsoft products lifecycle management

Microsoft products and services lifecycle management guidance and tools

## Azure

### Products expiring within 6 months

Table with product, change, expiration date and links

| Product | Change | Expiration Date | Announcement | Am I impacted? | Action |
| ------- | ------ | --------------- | ------------ | -------------- | ------ |
| Azure Database for Maria DB | Product retirement | 2025-09-19 | [Retirement announcement](https://azure.microsoft.com/updates?id=azure-database-for-mariadb-will-be-retired-on-19-september-2025-migrate-to-azure-database-for-mysql-flexible-server) | [Identify existing Azure Database for MariaDB servers [Azure Resource Graph query]](./queries/azure/arg/azuremariadb-retirement.kql) | [Migrate to Azure Database for MySQL Flexible Server](https://techcommunity.microsoft.com/blog/adformysql/migrating-from-azure-database-for-mariadb-to-azure-database-for-mysql-using-mysq/3838455) |
| Basic Load Balancer | Product retirement | 2025-09-30 | [Announcement](https://azure.microsoft.com/en-us/updates?id=azure-basic-load-balancer-will-be-retired-on-30-september-2025-upgrade-to-standard-load-balancer) | [Identify existing Basic Load Balancers [Azure Resource Graph query]](./queries/azure/arg/loadbalancer-basic-retirement.kql) | [Migrate to Standard SKU Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-basic-upgrade-guidance) |