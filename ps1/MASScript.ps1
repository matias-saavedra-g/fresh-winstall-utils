# Function to run Microsoft Activation Scripts
function MASScript {
    Invoke-RestMethod "https://get.activated.win" | Invoke-Expression
}