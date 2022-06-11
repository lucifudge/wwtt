# Windows Weefee Transfer Tool (_WWTT_) by lucifudge
   v1.0

 This tool provides a command-line interface for bulk backup and restore
  of wireless profiles by automating netsh import & export commands.

 **Usage**
   - Performing a Backup:
     - Save WWTT.bat file to a (preferably freshly formatted) flash drive
     - Insert flash drive into source computer and run WWTT.bat file
     - Choose Option 1, when instructed type "Service Order" and press Enter
     - Follow instructions to close script, then safely remove flash drive
      - **WARNING: Any existing backups are deleted when performing a new one.**   
   
   - Performing a Restore: 
     - Insert flash drive into destination computer and run WWTT.bat file
     - Choose Option 2, when instructed type "Service Order" from Backup and press Enter
     - Verify information is correct and press Y to proceed with import or N to abort
      - **WARNING: Any existing backups are deleted if "Service Order" entered does not match.**
 
 **Requirements**: 
   - User must provide any 14 or 15 numerical identifier (aka "Service Order") for backup ID
   - Will not run from OS drive (advise running from a removable disk)
   - Tested working on Windows 7, 8, 8.1, 10, 11
   - Keyboard with ISO basic Latin alphabet for navigation with letters Y, N, M
   - WLAN AutoConfig / WLANSVC enabled

 **Features**:
   - Bulk import and export of all networks via single menu selection
   - Backups saved in same directory as script in folder /WifiExports/Service Order/
   - Backups include nested folder with timestamp, computer name and Windows user name
   - List view of known network SSID
   - Verifies write-access to disk and compatible OS version on startup

   - Protection against accidental imports
     - Only one computer can be backed up at a time
     - Attempting more than one backup erases all prior backups
     - User is required to verify "Service Order" when Restoring
     - Entering incorrect service order during restore erases all prior backups
     - Automatic deletion of backups after successful import

![1](https://user-images.githubusercontent.com/13704242/173183839-8cffd90c-f45b-43b3-bbf1-8b271c59c285.png)
![2](https://user-images.githubusercontent.com/13704242/173183840-16127080-e054-4da7-ba4b-48f765b05a23.png)
![3](https://user-images.githubusercontent.com/13704242/173183841-bd28617c-d76f-4bc3-840f-3901711f3341.png)
![4](https://user-images.githubusercontent.com/13704242/173183842-132cb70e-6cab-412d-acbd-eced002b4594.png)
