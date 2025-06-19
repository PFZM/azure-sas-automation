<#
    .DESCRIPTION
        Runbook to start SAS VIYA INSTANCE and AKS Cluster
#>

"Please enable appropriate RBAC permissions to the system identity of this automation account. Otherwise, the runbook may fail..."

try {
    "Logging in to Azure..."
    Connect-AzAccount -Identity
} catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

# Declare variables - update these with your actual deployment values
$deploy_rg = "Name of resource group"
$deploy_cluster_name = "Name of AKS"
$deploy_namespace = "Name of Namespace"
$deploy_name = "Name of deployment"

# Generate a unique job name using current timestamp
$jobname = "sas-start-all-" + (Get-Date -format "ddMMyyyy-HHmmss")

# OPTIONAL: Start the SAS jumpbox VM if applicable
# Start-AzVM -ResourceGroupName $deploy_rg -Name "$deploy_name-jump-vm"
# Write-Output ("$deploy_name-jump-vm - Jump VM has started")

# OPTIONAL: Start the NFS VM if you are using external storage
# Start-AzVM -ResourceGroupName $deploy_rg -Name "$deploy_name-nfs-vm"
# Write-Output ("$deploy_name-nfs-vm - NFS VM has started")

# OPTIONAL: Start Postgres if using a flexible Postgres server
# Start-AzPostgreSqlFlexibleServer -ResourceGroupName $deploy_rg -Name "$deploy_name-default-flexpsql"
# Write-Output ("Postgres instance $deploy_name-default-flexpsql has started")

# Start the AKS cluster
Start-AzAksCluster -ResourceGroupName $deploy_rg -Name $deploy_cluster_name
Write-Output ("AKS cluster $deploy_cluster_name has started")

# Wait until the AKS cluster is definitely running
$clusterStatus = ""
while ($clusterStatus -ne "Succeeded") {
    $cluster = Get-AzAksCluster -Name $deploy_cluster_name -ResourceGroupName $deploy_rg
    $clusterStatus = $cluster.ProvisioningState
    Write-Output ("Current AKS cluster status: $clusterStatus")
    Start-Sleep -Seconds 30
}
Write-Output ("AKS cluster $deploy_cluster_name is running")

# Create the Kubernetes job to start SAS Viya pods
Invoke-AzAksRunCommand -ResourceGroupName $deploy_rg -Name $deploy_cluster_name -Command "kubectl -n $deploy_namespace create job $jobname --from=cronjobs/sas-start-all" -Force
Write-Output ("$jobname in $deploy_namespace namespace has been created")

# Wait until the start job has completed
Invoke-AzAksRunCommand -ResourceGroupName $deploy_rg -Name $deploy_cluster_name -Command "kubectl -n $deploy_namespace wait --for=condition=complete --timeout=600s job/$jobname" -Force
Write-Output ("SAS Instance in $deploy_namespace namespace has started with job $jobname")