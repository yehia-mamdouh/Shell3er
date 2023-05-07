# Shell3er
Shell3er PowerShell Reverse Shell


![23](https://user-images.githubusercontent.com/3721991/236687641-5a7e5a0e-5328-4049-a687-ab16988f3ea1.PNG)

## The Shell3er Reverse Features

**Get-RandomProcessName Function**

The Get-RandomProcessName function generates a random process name by concatenating "PS_" with a new GUID. This is used to create unique and seemingly random process names, making it harder to identify suspicious processes.

![sd2](https://user-images.githubusercontent.com/3721991/236688388-16119a21-1b70-4d81-9ea2-b5e85843f886.PNG)


**Run-BackgroundTask Function**

The Run-BackgroundTask function accepts a ScriptBlock and an optional ProcessName as parameters. It then starts a new background job with a random job name, executes the script block, and retrieves the output. The main purpose of this function is to run tasks in the background without interfering with the main script.

**Download and Upload Functions**

The download and upload functions serve to transfer files between the client and the server. They use Base64 encoding to transmit the file data over the network. Errors, if encountered during the file transfer process, are sent back to the client.

**Persistence Mechanisms**

The script uses two different methods to achieve persistence on the target system. First, it copies itself to the "C:\ProgramData" folder and modifies the registry key "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" to start the script every time the user logs in. Second, it copies the script to the user's Startup folder, ensuring that it runs every time the user starts their system.

The Shell3er Tested Manually on the following  Solutuions
(Checkpoint EDR version E85.40) (Kaspersky Total Security) (Widdows Defender)  

![sdf](https://user-images.githubusercontent.com/3721991/236688462-2ccd278b-b133-4908-854b-a1dd90b7cd63.PNG)


## Usage

* nc -nlvp 4444 on the Attacker Machine
* Execute the script on the Victim Mcahine

## Contributing

Awesome! Contributions are welcome and greatly appreciated. Please submit all on the GitHub pull requests tracker. Together we can make this even more amazing! 🚀
