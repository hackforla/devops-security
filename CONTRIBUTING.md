# **How to Contribute to DevOps Security**
> ℹ️ **This page is under development**

Below are guidelines for contributing to the devops-security repository hosted on GitHub. These guidelines are primarily recommendations rather than strict rules. Use your discretion and feel free to suggest changes to this document by submitting a pull request.

**This guide assumes that you have finished the onboarding process, which involves joining the Hack for LA Slack, GitHub, and Google Drive. If you haven't completed onboarding yet, please visit the [Getting Started Page](https://www.hackforla.org/getting-started).**

**The team recommends using [VS Code](https://code.visualstudio.com/download) as the preferred text editor for working on code, but feel free to utilize a text editor of your preference.**

**If you have any additional questions about your contribution process, please feel free to reach out to the team in the [#ops](https://hackforla.slack.com/archives/CV7QGL66B) Slack channel.**
<br><br>

## **Table of Contents**
- [**How to Contribute to DevOps**](#how-to-contribute-to-devops)
- [**Table of Contents**](#table-of-contents)
- [**Setting up the local development environment**](#setting-up-the-local-development-environment)
    - [**Creating a personal AWS account**](#creating-a-personal-aws-account)
    - [**Login as root user & setup MFA**](#login-as-root-user-&-setup-mfa)
    - [**Setting up IAM and AWS CLI**](#setting-up-iam-and-aws-cli)
        - [**Create an IAM User**](#create-an-iam-user)
        - [**Create an IAM Group**](#create-an-iam-group)
        - [**Attach IAM user to IAM group**](#attach-iam-user-to-iam-group)
        - [**Attach `AdministratorAccess` policy to IAM group**](#attach-administratoraccess-policy-to-iam-group)
        - [**Generating Access Keys for AWS CLI**](#generating-access-keys-for-aws-cli)
    - [**Installing Terraform**](#installing-terraform)
    - [**Creating Backend State**](#creating-backend-state)
    - [**Creating Local tfvars file**](#creating-local-tfvars-file)
    - [**Installing Terraform docs**](#installing-terraform-docs)
    - [**Clone (Create) a copy on your computer**](#clone-create-a-copy-on-your-computer)
    - [**Create a new branch where you will work on your issue**](#create-a-new-branch-where-you-will-work-on-your-issue)
    - [**Terraform Setup and Execution Instructions**](#terraform-setup-and-execution-instructions)
    - [**Submitting changes via git and opening a PR**](#submitting-changes-via-git-and-opening-a-pr)

## **Setting up the local development environment**

### **Creating a personal AWS account**

- Go to [AWS](https://aws.amazon.com/) and click `"Sign In to the Console" > "Create a new AWS account."` 
- Enter your email, create a password, and input your basic details. Then provide your contact information and complete the identity verification process.
- Enter your credit/debit card information for billing purposes, opt for the free basic support.
- Agree to the AWS Customer Agreement and Service Terms, complete the registration by clicking `"Create Account and Continue"`, verify your phone number via text or call, confirm your email address following the instructions in the confirmation email, and finally sign in to access your new AWS account using your email and password.
- Follow this [video guide](https://youtu.be/CjKhQoYeR4Q?si=78GhlDLV5zZu8qwh) for deeper explanations.

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

### **Login as root user & setup MFA**
- Open [AWS Management Console](https://console.aws.amazon.com/).
- Choose `Root user` and enter your email.
- Complete security check if prompted.
- Enter password and authenticate with MFA.
- Sign in to access the Console Home page.
- Follow this [guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/enable-virt-mfa-for-root.html) for enabling MFA for the root AWS account.

**Note:** Select the `us-west-2` region. It's not required for managing IAM resources, as they are global. However, it's advisable since our other resources are in the same region.

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

## **Setting up IAM and AWS CLI**

- Open AWS CloudShell or follow this [link](https://docs.aws.amazon.com/cloudshell/latest/userguide/welcome.html#how-to-get-started)
- ### **Create an IAM User**

  Run the following commands
  ```bash
  aws iam create-user --user-name UserName
  ```
  For example if your AWS username was `octocat`:

  ```bash
  aws iam create-user --user-name octocat
  ```
  then create a login profile with username and password with

  ```bash
  aws iam create-login-profile --user-name UserName --password ExamplePassword123!
  ```
  For example if your AWS username was `octocat`:

  ```bash
  aws iam create-login-profile --user-name octocat --password OctocatIsMyPassword234!
  ```
  **Note:** Password length must be 20 characters

  <sub>[Back to Table of Contents](#table-of-contents)</sub>
  ***
- ### **Create an IAM Group**

  To create an `AdminGroup` run the command

  ```bash
  aws iam create-group --group-name AdminGroup
  ```
  <sub>[Back to Table of Contents](#table-of-contents)</sub>
  ***
- ### **Attach IAM user to IAM group**
  
  Next we need to link the newly created IAM user with the IAM group, use the command

  ```bash
  aws iam add-user-to-group --group-name AdminGroup --user-name UserName
  ```
  For example if your AWS username was `octocat`:

  ```bash
  aws iam add-user-to-group --group-name AdminGroup --user-name octocat
  ```
  <sub>[Back to Table of Contents](#table-of-contents)</sub>
  ***
- ### **Attach `AdministratorAccess` policy to IAM group**

  Run the command for attaching `AdministratorAccess` policy to the `AdminGroup` 

  ```bash
  aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --group-name AdminGroup
  ```
  <sub>[Back to Table of Contents](#table-of-contents)</sub>
  ***
- Log in as the newly created user instead of continuing to log in as the root user.
- ### **Generating Access Keys for AWS CLI**
  - Open CloudShell
  - Generate the Access Keys for AWS CLI

    ```bash
    aws iam create-access-key --user-name UserName > access_key.json
    ```
  - Print the contents of `access_key.json` and copy the contents to a secure location (you'll need the keys when you set up AWS CLI below)
   
    ```bash
    nano access_key.json
    ```
  <sub>[Back to Table of Contents](#table-of-contents)</sub>
  ***
- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) 
- [Set up the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

### **Installing Terraform**

Use the [Official HashiCorp install instructions](https://developer.hashicorp.com/terraform/install) for installing terraform.

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

### **Creating Backend State**

To facilitate AWS IAM changes using Terraform, it's essential to establish backend state storage. Refer to and follow the instructions outlined in this [issue](https://github.com/hackforla/ops/issues/105) to create the backend state.

**Note:** Users will need to create their backend state exactly as specified (i.e. using the same naming conventions).

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

### **Creating Local tfvars file**

Atfer creating a backend state, create a ```backend.tfvars``` file in the ```terraform``` directory. It should have content of this format:

```
bucket         = "{developer_specific}-hfla-ops-terraform-state"
key            = "devops-security/terraform.tfstate"
region         = "us-east-2"
dynamodb_table = "{developer_specific}_hfla_ops_terraform_table"
encrypt        = true
```

Remeber to match these values to the ones in your backend state (and replace {developer-specific} with your actual name)

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

### **Installing Terraform docs**

Follow the Terraform docs [installation guide](https://terraform-docs.io/user-guide/installation/)

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

## **Clone the repository**

Create a new folder in your computer that will contain `hackforla` projects.

In your command line interface (Terminal, Git Bash, Powershell), move to where you want your new folder to be placed and create a new folder in your computer that will contain `hackforla` projects. After that, navigate into the folder(directory) you just created.

For example:
```bash
mkdir hackforla
cd hackforla
```

and run the following commands:

```bash
git clone https://github.com/hackforla/devops-security.git
```

You should now have a new folder in your `hackforla` folder called `devops-security`. Verify this by changing into the new directory:

```bash
cd devops-security
```

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

### **Create a new branch where you will work on your issue**
Ensure you're on the main branch `git checkout main` and that your main branch is up to date `git pull`
 
Using the `-b` flag you can also use the `git checkout` command to create a new branch and immediately switch into it.  

For example, if you create a new issue branch for [Update Contributing document to include next steps - #15](https://github.com/hackforla/devops-security/issues/15):

```bash
git checkout -b update-contributing-guide-15
```

 The text after the `-b`, in the example `update-contributing-guide-15`, will be the name of your new branch.

 **Note:** Choose a branch name that:
 * relates to the issue (No spaces!)
 * includes the issue number

**Note:** The format should look like the scheme above where the words are a brief description of the issue that will make sense at a glance to someone unfamiliar with the issue.

**Note:** No law of physics will break if you don't adhere to this scheme, but laws of git will break if you add spaces.

When you've finished working on your issue, follow the steps below to prepare your changes to push to your repository.

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

### **Terraform Setup and Execution Instructions**

- Change into `terraform` directory with 

```bash
cd terraform
```

- Next initilize the terraform configuration

```bash
terraform init --backend-config=backend.tfvars
```

- Then generate and run an execution plan

```bash
terraform plan
```
<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

### **Submitting changes via git and opening a PR**

- We urge developers to be cautious using `git add`. In general it is not advisable to use `git add -all` or `git add .`. Rather, run `git status`, examine the output carefully, and then add only those files specifically related to the current issue. This will ensure that no extraneous files are included in the subsequent commit. 

- Then commit the changes with a descriptive message using

  ```bash
  git commit -m "your commit message"
  ```

- Push changes to the remote repository, replace the `branch_name` with the name of the branch you are working on

  ```bash
  git push --set-upstream origin branch_name
  ```
- Lastly open a PR to merge your changes into the `main` branch.

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***
