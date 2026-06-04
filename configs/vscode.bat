# export extensions
code --list-extensions > vscode-extensions.txt
# C:\Users\<USER>\AppData\Roaming\Code\User

# import extensions (powershell)
Get-Content vscode-extensions.txt | ForEach-Object { code --install-extension $_ }
