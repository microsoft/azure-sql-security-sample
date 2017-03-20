# Contoso Clinic Demo Application 

Sample application with database that showcases security features of Azure SQL DB (V12). 

## About this sample
- **Applies to:**  Azure SQL Database, Azure Web App Service, Azure Key Vault
- **Programming Language:** .NET C#, T-SQL
- **Authors:** Daniel Rediske [daredis-msft]

## Contents
1. [Prerequisites](#prerequisites) 
2. [Estimated Cost of Deployed Resources](#estimated-cost-of-deployed-resources)
3. [Setup](#setup) 
	* Generate Application ID and Secret
	* Retrieve TenantID
	* Retrieve User and Application ObjectID
	* Deploy to Azure
4. [Azure SQL Security Features](#azure-sql-security-features) 
	* Auditing & Threat Detection
	* Always Encrypted 
	* Row Level Security 
	* Dynamic Data Masking
5.  [Application Notes/Disclaimer](#application-notes)



## Prerequisites
+ Azure Subscription with resource creation permissions
+ Subscription associated with an Azure Active Directory 
+ [Powershell with AzureRM and Azure Modules](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

## Estimated Cost of Deployed Resources
The following table is an estimation of the cost of deploying the Demo as of 5/9/2016. 

 Resource | Cost/Month | Cost/Hr 
 --- | --- | ---  
[S1 SQL Database ](https://azure.microsoft.com/en-us/pricing/details/sql-database/) |  $30  | $0.04
[B1 App Service Plan](https://azure.microsoft.com/en-us/pricing/details/app-service/) | $55.80  | $0.075
[Storage Plan](https://azure.microsoft.com/en-us/pricing/details/storage/) | ~$0 | $0.0036/transaction
[Azure Key Vault](https://azure.microsoft.com/en-us/pricing/details/key-vault/)| ~$0| $0.03/10k operations 
**Monthly Total** | $85.80/mo | ~$0.115/hr

## Setup
### Generate Application ID and Secret
In order to allow your client application to access and use the keys in your Azure Key Vault, we need to provision an application in Azure Active Directory. This will create a Client ID and Secret that your app will use to authenticate to the Azure Key Vault. To do this, head to the [Classic Azure Portal](https://manage.windowsazure.com/) and log in.

Select &ldquo;Active Directory&rdquo; in the left sidebar, choose the Active Directory you wish to use (or create a new one if it doesn&rsquo;t exist), then click &ldquo;Applications&rdquo;. If you choose a directory other than your default, you will need to refer to the steps to change the directory associated with your account, [which can be found here](http://rickrainey.com/windows-azure-how-tos/how-to-change-the-directory-associated-with-your-windows-azure-subscription/). 

Add a new application by filling out the modal window that appears.

Enter a name, select &ldquo;Web Application&rdquo; as the type, and enter any URL for the Sign-On URL and App ID URI.&nbsp; These must include &ldquo;http://&rdquo;, but do not need to be real pages for the purposes of this demo.&nbsp; 

Go to the &ldquo;Configure&rdquo; tab and generate a new client key (also called a &ldquo;secret&rdquo;) by selecting a duration from the dropdown, then saving the configuration.&nbsp; <strong>Copy the client ID and secret out to a text file</strong>, as they will be used in deployment and in enabling the Always Encrypted functionality.
### Retrieve TenantID 

In order to deploy an Azure Key Vault for use with the Always Encrypted functionality of the demo, you will need to provide your tenantID during the deployment process. This can be copied from Powershell in the response to the `Login-AzureRmAccount` command. After the deployment step, this information is not saved by the application. 

### Retrieve User and Application ObjectID

In order to create access permissions to the Azure Key Vault during deployment, you will need to collect both your user ObjectID and the Application ObjectID. 

+ Log into your Azure account with powershell using the cmdlet `Login-AzureRmAccount`, and copy down the TenantID returned. 

![Login Example](/Img/LoginExample.png)


+ Run the command: 
`Get-AzureRMAduser -UserPrincipalName <AccountName>` 
and copy the ObjectID returned. This is your UserObjectID. 

![User Object ID Example](/Img/rmaduser.png)

+ Run the command: 
`Get-AzureRmADServicePrincipal -ServicePrincipalName <ClientID from AAD application step>` 
and copy the ObjectID returned. This is your ApplicationObjectId.

![Service Principal example](/Img/RMADSP.png)

### Deploy to Azure 
Click the Deploy to Azure Button and fill out the fields to deploy the demo to your Azure Subscription.

Note on Passwords: Please use only characters and numbers [a-z A-Z 0-9]. Because of certain implementation decisions made in development of this demo, other characters *may cause deployment issues*.  

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)

## Azure SQL Security Features 
### Auditing & Threat Detection
#### Set up and Test Auditing & Threat Detection 

+ Auditing and Threat Detection should have been turned on during deployment 
+ You can verify this in the [Azure Portal](https://portal.azure.com) by viewing the Database Settings (under **Auditing & Threat Detection**)
	- Auditing should be 'ON'
	- Threat Detection should be 'ON'
	- For shared accounts, unselect the **Email Service and Co-Administrators** box and place your own email address in the box. 
		* This will avoid alarming your Service Admins and Subscription Co-Admins with an Alert Email, should your account have them. 
+ Execute a SQL injection to show Threat Detection on the /patients page
	- We left the box at the top of the page vulnerable on purpose, but you ought to take precautions to prevent attacks on your apps. 
	- Here's a simple injection that just reorders the results. (Simply copy the following code and paste it into the textbox at the top of the patients page)
	```SQL 
	' ORDER BY SSN -- 
	```
	- Worth saying again: **You _must_ protect against SQL Injection in your app code.** [Learn more about SQL Injection and protecting against it from OWASP.](https://www.owasp.org/index.php/SQL_Injection_Prevention_Cheat_Sheet) 
	- Note: This injection will cause an error instead of reordering results IF Always Encrypted is enabled. 
+ Check your inbox for a Threat Detection email 
	- From *Microsoft Azure Security Alerts* <security-alerts-noreply@mail.windowsazure.com> 

#### How did that work? 
Threat Detection is designed to detect suspicious database activity- which may indicate malicious access, a breach, or an exploit attempt on the Database. This is designed around machine learning algorithms that look for anomalous database activities over historical data and normal behavior of databases. Because SQL injection is a leading exploit vector for unauthorized access to data, it is flagged by Threat Detection as abnormal behavior. 

### Always Encrypted 

#### Enable Always Encrypted
+ Connect to your deployed database using SSMS: 
	- The server you created will be visible in your [azure portal](https://portal.azure.com), it will begin with the string "contososerv"
	- Connect using the Administrator Login (Default was adminLogin) and the password you defined during setup 
	- For more information on using SSMS to connect to an Azure Database, [click here](https://azure.microsoft.com/en-us/documentation/articles/sql-database-connect-query-ssms/)
+ Encrypt Sensitive Data Columns using the Column Encryption Wizard 
	- Right click on the **Patients** table in the **Clinic** database and select **Encrypt Columns...**
	- The Column Encryption wizard will open. Click **Next**.
	- Select the **SSN** and **BirthDate** columns. 
		* Select **Deterministic Encryption** for **SSN** as the application needs to be able to search patients by SSN; Deterministic Encryption preserves that functionality for our app without leaving data exposed. 
		* Select **Randomized Encryption** for *BirthDate** 
	- Leave **CEK_Auto1 (New)** as the Key for both columns. Click **Next**.
	- On the **Master Key Configuration** page, set the Master Key Source to **Azure Key Vault**, select the Subscription you used in the deployment of the application, and select your Key Vault  Click **Next**. 
		* The naming convention of the Key Vault begins "Contosoakv" followed by a unique string, which satisfies the universally unique naming convention necessary for the key vault. 
		* Should you see more than one Key Vault option, using `Get-AzureRmKeyVault -ResourceGroupName <yourResourceGroupName>` within powershell would be an option to ensure you choose the correct key vault. 
	- Click the **Next** button on the Validation page.
	- The Summary Page provides an overview of the settings we selected. Click **Finish**. 
	- Monitor the progress of the wizard; once finished, click **Close**. 
+ View the data in SSMS (in SSMS use: `SELECT SSN, BirthDate FROM dbo.Patients` or `SELECT * FROM dbo.Patients` ) 
	- Note that the data is now encrypted in both the **SSN** and **BirthDate** columns. 
+ Navigate to or refresh the /patients page
	- Notice that the application still works and the encryption does not hinder the presentation of the data
	
#### How did that work? 

##### Azure Key Vault Creation and Permissions  
During the pre-deployment steps, you collected information which enabled the deployment to create an Azure Key Vault and the required permissions for both you (the user) and the Application Active Directory registration we created. During those steps, the Azure Active Directory registration for the application was necessary to enable key vault connectivity, because the application needs access to the key to enable the driver to transparently handle the decryption of the columns we encrypted. 

During the creation, we gave the user `create, list, wrapKey, unwrapKey, sign, verify` permissions in order to facilitate your Key Vault management; the application needs `get, wrapKey, unwrapKey, sign, verify`. As a best practice, you should *always follow the principle of least privelege*. For documentation on Key Vault Permissions, see [About Keys and Secrets](https://msdn.microsoft.com/en-us/library/azure/dn903623.aspx#BKMK_KeyAccessControl). 

This is the equivalent of creating a [key vault](https://blogs.technet.microsoft.com/kv/2015/06/02/azure-key-vault-step-by-step) and permissions via Powershell- see the section/cmdlets under "Create and Configure a key vault". 
##### Connection String
Our connection string for our application contains `Column Encryption Setting=Enabled` which allows the driver to handle the necessary overhead to decrypt the newly encrypted data without code changes. Ordinarily, you would need to change the connection string- but in this demo, we preemptively included this within the connection string with the intent that you enable this functionality. Don't forget this for your app if you intend to use Always Encrypted functonality. 
##### Application Code Changes
We had to prepare our application to authenticate against our Key Vault- this code is discussed in more detail in this [Blog Post](https://blogs.msdn.microsoft.com/sqlsecurity/2015/11/10/using-the-azure-key-vault-key-store-provider-for-always-encrypted/). The code changes referenced there are in our file *Startup.cs*, which can be found [here](ContosoClinicProject/ContosoClinic/Startup.cs). 

### Row Level Security (RLS) 

####Login to the application 
Sign in using (Rachel@contoso.com/Password!1) or (alice@contoso.com/Password!1)

####Enable Row Level Security (RLS) 
+ Connect to your deployed database using SSMS: [Instructions](https://azure.microsoft.com/en-us/documentation/articles/sql-database-connect-query-ssms/)
+ Open Enable-RLS.sql ( [Find it here](Security%20Demo%20Queries/Enable-RLS.sql))
+ Execute the commands 
+ Observe the changes to the results returned on the /visits or /patients page

#### How did that work? 

#####The application leverages an Entity Framework feature called **interceptors** 
Specifically, we used a `DbConnectionInterceptor`. The `Opened()` function is called whenever Entity Framework opens a connection and we set SESSION_CONTEXT with the current application `UserId` there. 

##### Predicate functions
The predicate functions we created in Enable-RLS.sql identify users by the `UserId` which was set by our interceptor whenever a connection is established from the application. The two types of predicates we created were **Filter** and **Block**. 
+ **Filter** predicates silently filter `SELECT`, `UPDATE`, and `DELETE` operations to exclude rows that do not satisfy the predicate. 
+ **Block** predicates explicitly block (throw errors) on `INSERT`, `UPDATE`, and `DELETE` operations that do not satisfy the predicate. 

### Dynamic Data Masking

#### Enable Dynamic Data Masking
+ Navigate to the /patients page
+ Connect to your deployed database using SSMS: [Instructions](https://azure.microsoft.com/en-us/documentation/articles/sql-database-connect-query-ssms/)
+ Open Enable-DDM.sql ([Find it here](Security%20Demo%20Queries/Enable-DDM.sql)) 
+ Execute the commands
+ Observe the changes in results returned on the /visits page

#### How did that work? 
Dynamic data masking limits sensitive data exposure by masking the data according to policies defined on the database level while the data in the database remains unchanged; this is based on the database user's permissions. Those with the `UNMASK` permission will 
have the ability to see the data without masks. In our case, the application's database login did not have the `UNMASK` permission and saw the data as masked. For your administrator login, the data was visible, as the user had the `UNMASK` permission. For more information on Dynamic Data Masking, [see the documentation](https://msdn.microsoft.com/en-us/library/mt130841.aspx). 

## Application Notes
The code included in this sample is only intended to provide a simple demo platform for users to enable and gain experience with Azure SQL Database (V12) security features; the demo web app is not intended to hold sensitive data and should not be used as a reference for applications that use or store sensitive data.Please take adequate steps to securely develop your application and store your data.  
