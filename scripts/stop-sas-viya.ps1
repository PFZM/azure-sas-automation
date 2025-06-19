<#
    .DESCRIPTION
        Runbook to stop SAS VIYA INSTANCE and AKS cluster
#>

"Please enable appropriate RBAC permissions to the system identity of this automation account. Otherwise, the runbook may fail..."

try {
    "Logging in to Azure..."
    Connect-AzAccount -Identity
} catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

# Declare variables - update these with your own resource names
$deploy_rg = "Name of resource group"
$deploy_cluster_name = "Name of AKS"
$deploy_namespace = "Name of Namespace"
$deploy_name = "Name of deployment"


# Generate a unique job name using current timestamp
$jobname = "sas-stop-all-" + (Get-Date -format "ddMMyyyy-HHmmss")

# Create the stop job using the predefined cronjob in Kubernetes
Invoke-AzAksRunCommand -ResourceGroupName $deploy_rg -Name $deploy_cluster_name -Command "kubectl -n $deploy_namespace create job $jobname --from=cronjobs/sas-stop-all" -Force
Write-Output ("$jobname in $deploy_namespace namespace has been created")

# Wait for the stop job to complete
Invoke-AzAksRunCommand -ResourceGroupName $deploy_rg -Name $deploy_cluster_name -Command "kubectl -n $deploy_namespace wait --for=condition=complete --timeout=600s job/$jobname" -Force
Write-Output ("SAS Instance in $deploy_namespace namespace has stopped with job $jobname")

# Stop the AKS cluster
Stop-AzAksCluster -ResourceGroupName $deploy_rg -Name $deploy_cluster_name
Write-Output ("AKS cluster $deploy_cluster_name has stopped")

# OPTIONAL: Stop Postgres if using an external managed Postgres server
# Stop-AzPostgreSqlFlexibleServer -ResourceGroupName $deploy_rg -Name "$deploy_name-default-flexpsql"
# Write-Output ("Postgres instance $deploy_name-default-flexpsql has stopped")

# OPTIONAL: Stop the NFS VM if using an external NFS server
# Stop-AzVM -ResourceGroupName $deploy_rg -Name "$deploy_name-nfs-vm" -Force
# Write-Output ("$deploy_name-nfs-vm - NFS VM has stopped") 

# OPTIONAL: Stop the SAS jumpbox VM if in use
# Stop-AzVM -ResourceGroupName $deploy_rg -Name "$deploy_name-jump-vm" -Force
# Write-Output ("$deploy_name-jump-vm - Jump VM has stopped")