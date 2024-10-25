Table of Contents

- [Task: Setup your repo to use Azure blob storage for state file management](#task-setup-your-repo-to-use-azure-blob-storage-for-state-file-management)
  - [Create new repo 'tech264-tf-azure'](#create-new-repo-tech264-tf-azure)
  - [Step 1: Create a Storage Account and Container in Azure](#step-1-create-a-storage-account-and-container-in-azure)
  - [Step 2: Configure Terraform Backend](#step-2-configure-terraform-backend)
  - [Step 3: Setup Main Architecture](#step-3-setup-main-architecture)
  - [Step 4: Verify and Share Links](#step-4-verify-and-share-links)
  - [Step 5: Documentation](#step-5-documentation)

<br>

# Task: Setup your repo to use Azure blob storage for state file management
* Use a Terraform folder for the backend setup
* Use a Terraform separate folder for the main architecture (to deploy the app) which uses the backend setup for state file management

Deliverables:
* In the one Teams message in the main chat, paste links:
  * to your app running which was deployed by Terraform using remote state file management on Azure.
  * a link to where your state files are stored in blob storage on the Azure portal (NOT the URL to the state files as they should NEVER be made public).
* Link to your documentation pasted into the main chat around COB.

<br>

## Create new repo 'tech264-tf-azure'
* Go to GitHub > create new repo 'tech264-tf-azure'.
* Go to GitHub Repo > `mkdir tech264-tf-azure`
* cd into new repo.
* `git init`
* 


<br>

## Step 1: Create a Storage Account and Container in Azure
1. Login to Azure.
2. Create a Resource Group.
3. Create a Storage Account.
4. Create a Blob Container.

## Step 2: Configure Terraform Backend
1. Create a backend.tf file in a separate folder (e.g., terraform-backend).
2. Initialise the Backend.

## Step 3: Setup Main Architecture
1. Create a new folder for your main architecture (e.g., terraform-main).
2. Create your Terraform configuration files (e.g., main.tf, variables.tf, etc.) in this folder.
3. Reference the Backend Configuration.
4. Initialise and Apply.

## Step 4: Verify and Share Links
1. Verify your app is running and accessible.
2. Get the link to your state files in the Azure portal.
3. Share the Links.

## Step 5: Documentation
* Document your process and any configurations.
* Share the documentation link in the main chat by COB.

<br>