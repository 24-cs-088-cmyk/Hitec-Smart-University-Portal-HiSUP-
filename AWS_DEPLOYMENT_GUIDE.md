# AWS Deployment Guide for HiSUP

This guide will show you exactly how to deploy your ASP.NET Core Web App and SQL Server Database to AWS using your $100 student credit. We will use **Amazon RDS (Relational Database Service)** for your database and **AWS Elastic Beanstalk** for your web application.

---

## 🟢 Part 1: Preparing Your Application Files (What to ZIP)

Because the `dotnet` build tools weren't accessible via the terminal earlier, you can compile the code into a "Published" folder using Visual Studio. 

**Do NOT zip your source code!** AWS needs compiled `.dll` files, not `.cs` or `.cshtml` files.

### Step-by-Step Publish via Visual Studio:
1. Open `HiSUP.sln` or the `HiSUP` project in **Visual Studio**.
2. In the Solution Explorer (right side), **Right-click the `HiSUP` project** (the one with the C# icon).
3. Click **Publish**.
4. A screen will appear asking for a target. Select **Folder** and click Next.
5. Choose a Folder location (e.g., `f:\university\4th sem project\adbms\Hitec-Smart-University-Portal-HiSUP-\publish`) and click **Finish**, then click **Publish**.
6. Wait for Visual Studio to finish building. 
7. Navigate to that `publish` folder on your computer.
8. **Select ALL the files and folders INSIDE the publish folder** (you should see `HiSUP.dll`, `web.config`, `wwwroot`, etc.).
9. **Right-click -> Send to -> Compressed (zipped) folder**. Name it `HiSUP_AWS_Deploy.zip`.

**IMPORTANT:** Make sure you are zipping the **contents** of the folder, not the `publish` folder itself. When you open the zip file, you should see `HiSUP.dll` directly inside, not nested in another folder.

---

## 🟠 Part 2: Deploying the Database to AWS RDS

AWS RDS provides a managed SQL Server instance. You get full admin access to it!

### 1. Create the Database Instance
1. Log in to the **AWS Management Console** and search for **RDS**.
2. Click **Create database**.
3. Choose **Standard create**.
4. Engine options: Select **Microsoft SQL Server**.
5. Edition: Select **SQL Server Express Edition**.
6. Templates: Select **Free tier** (this keeps you well within your $100 budget).
7. Settings:
   - **DB instance identifier:** `hisup-db`
   - **Master username:** `admin`
   - **Master password:** Set a strong password (and write it down!).
8. Instance configuration: Leave default (e.g., `db.t3.micro`).
9. Storage: Leave default (20 GB is plenty).
10. Connectivity: 
    - **Public access:** Select **Yes** (You need this to connect from your laptop to run the SQL scripts).
    - **VPC security group:** Choose "Create new" and name it `hisup-sg`.
11. Click **Create database** at the bottom. This will take about 10-15 minutes to provision.

### 2. Connect and Run Your Scripts
Once the RDS instance status says **Available**:
1. Click on the database name (`hisup-db`) and look for the **Endpoint** under Connectivity & security. It will look something like `hisup-db.cxyz123.us-east-1.rds.amazonaws.com`.
2. Open **SQL Server Management Studio (SSMS)** or **Azure Data Studio** on your laptop.
3. Connect using:
   - **Server name:** The Endpoint you just copied.
   - **Authentication:** SQL Server Authentication.
   - **Login:** `admin`
   - **Password:** The password you created.
4. Once connected, open your `database/HiSUP_DB_Script.sql` file in SSMS.
5. **CRITICAL:** Run it exactly as-is! AWS gives you `master` permissions, so `CREATE DATABASE HiSUP_DB;` will work perfectly. 
6. After the main script finishes, run the views, triggers, procedures, and security scripts (including RLS and Encryption!).

### 3. Update Your Connection String
Now that your database exists on AWS, update the connection string in your local project *before* you zip the project in Part 1 (if you already zipped it, you'll need to update `appsettings.Production.json` and re-zip).

Your connection string in `appsettings.Production.json` should look like this:
```json
{
  "ConnectionStrings": {
    "HiSUP_DB": "Server=YOUR_AWS_ENDPOINT,1433;Database=HiSUP_DB;User Id=admin;Password=YOUR_PASSWORD;TrustServerCertificate=True"
  }
}
```

---

## 🔵 Part 3: Deploying the Web App to AWS Elastic Beanstalk

Elastic Beanstalk handles all the server setup (IIS, Windows Server) for you.

### 1. Create the Web Environment
1. In the AWS Management Console, search for **Elastic Beanstalk**.
2. Click **Create Application**.
3. Configure environment:
   - **Application name:** `HiSUP`
   - **Environment name:** `HiSUP-env` (default is fine)
4. Platform:
   - Platform: **.NET on Windows Server**
   - Platform branch: **IIS 10.0 running on Windows Server ...** (pick the latest)
5. Application code:
   - Select **Upload your code**.
   - Click **Choose file** and upload the `HiSUP_AWS_Deploy.zip` file you created in Part 1.
6. Presets:
   - Select **Single instance (free tier eligible)**.
7. Click **Next** until you reach the final review page, then click **Submit**.

> Beanstalk will now provision a Windows server, install IIS, configure it, and deploy your ASP.NET Core app. This takes about 5-10 minutes.

### 2. Set Environment Variables
Your app needs to know it is in "Production" to read the correct database connection string.
1. Once the Beanstalk environment is running, go to its dashboard and click **Configuration** on the left menu.
2. Scroll down to **Updates, monitoring, and routing** and click **Edit**.
3. Scroll to the bottom to **Environment properties**.
4. Add a new property:
   - **Name:** `ASPNETCORE_ENVIRONMENT`
   - **Value:** `Production`
5. Click **Apply**. The environment will quickly restart.

### 3. Test Your App
Go to your Elastic Beanstalk dashboard. At the top, there will be a domain link (e.g., `http://hisup-env.eba-xxxxxx.us-east-1.elasticbeanstalk.com`). 
Click it, and your university portal should open, fully connected to your AWS RDS database!
