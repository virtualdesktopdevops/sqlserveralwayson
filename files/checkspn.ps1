Param(
    [string]$spn,
    [string]$serviceaccount
)

if( (setspn -l $serviceaccount | Select-String $spn).count -gt 0) {
    echo 'SPN already registered for the target service account'
    exit 1
}