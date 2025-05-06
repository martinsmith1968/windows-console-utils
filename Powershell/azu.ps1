param(
    [string]$commandName = $(Throw "Must be: show, list, set, who, config"),
    
    [string]$argument1 = $(
        switch($commandName) {
            "set" {
                Throw "Specify the subscription to switch to"
            }
            "config" {
                Throw "Specify the Organization to default to"
            }
        }
    ),
    
    [string]$argument2 = $(
        switch($commandName) {
            "config" {
                Throw "Specify the Project to default to"
            }
        }
    )
)

function Assert-LoggedInUser {
    az ad signed-in-user show 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Not logged in"
    }
}

function Show-CurrentSubscription {

    Assert-LoggedInUser

    $accounts = az account list | ConvertFrom-Json

    $current = $accounts | Where-Object { $_.isDefault -eq $True }

    Write-Output $current
}

function Show-Subscriptions {

    Assert-LoggedInUser

    $accounts = az account list | ConvertFrom-Json

    $accounts | Sort-Object -Property Name | Format-Table id, Name, isDefault -GroupBy tenantId
}

function Set-Subscription {
    param(
        [Parameter(Mandatory=$true)]
        [string]$subscriptionName
    )

    Assert-LoggedInUser

    az account set --subscription $subscriptionName
    if ($LASTEXITCODE -ne 0) {
        exit
    }
    
    Show-CurrentSubscription
}

function Show-CurrentUser {
    Assert-LoggedInUser

    $user = az ad signed-in-user show 2>$null | ConvertFrom-Json

    $user
}


function Set-Config {
    param(
        [Parameter(Mandatory=$true)]
        [string]$organizationName,

        [Parameter(Mandatory=$true)]
        [string]$projectName
    )

    az devops configure --defaults organization=https://dev.azure.com/$organizationName project=$projectName

    az devops configure --list
}

try
{
    switch ($commandName) {
        "show" {
            Show-CurrentSubscription
        }
        "list" {
            Show-Subscriptions
        }
        "set" {
            Set-Subscription $argument1
        }
        "who" {
            Show-CurrentUser
        }
        "config" {
            Set-Config $argument1 $argument2
        }
        Default {
            #Write-Error "Unknown command : ${commandName}"
            Throw "Unknown command : ${commandName}"
        }
    }
}
catch {
    Write-Error "ERROR: ${PSItem}"
}
