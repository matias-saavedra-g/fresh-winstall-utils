# Function to run CTT Win Utils script
function CTTScript {
    Invoke-RestMethod "https://christitus.com/win" | Invoke-Expression
}