# Creating a Git Repo from Scratch
Using the ansible-galaxy command line tool that comes bundled with Ansible, we can create a role with the init command. For example, the following will create a role directory structure called ‘tower-project’ in the current working directory:

```
ansible-galaxy init new-repo
```

This will create the following file and directory structure:

```
new-repo/
├── README.md
└── roles
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    └── vars
        └── main.yml
```

With your new Ansible role directory structure created, you can now initialize this role directory as a new Git repository. The process of making changes and saving things in a repo is called a ‘commit.’ In this example, we’ll initialize our new repo and make our first commit:

```
ansible-galaxy init new-repo
cd new-repo/

git init
git add .
git commit -m 'making new role'
git push
```

And if you need to change the location of where that repo syncs to, you can change the remote push destination to a custom GitLab location:

```
git remote add origin <GitLab repo url>
git push -u origin master
```

Alternatively, in situations where the ansible-galaxy tool is NOT available, the following commands creates the requisite role files and initialize the role directory as a new git repo:

```
git init new-repo

for directory in tasks handlers files templates vars defaults meta;
do mkdir -p new-repo/roles/$directory; done

for file in tasks vars defaults meta;
do touch new-repo/roles/$file/main.yml; done

touch new-repo/README.md

cd new-repo
git add .
git commit -m 'ansible role with all the essentials'
git push
```

## Cloning and Existing Repo
We will be managing our playbooks/roles through Git repositories hosted on GitHub/GitLab/BitBucket/etc…

If our repo already exists, our starting point for new development will be to clone this repo to where we’ll be working:

```
git clone https://<git_repo_url>/443://repo.git
```

Full steps to performing either method can be found here:
[Add existing project to GitHub using CLI](https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line/)
or
[Cloning a Git repository](https://help.github.com/articles/cloning-a-repository/#platform-linux)

Now that you understand the basics behind Ansible development, and you’ve created or cloned a Git repo, you’re ready to start writing playbooks!

## Creating a New Git Branch
When beginning new development, you’ll create a new branch in a repo. Brand new development should start with a pull/rebase from the master branch:

```
git [checkout|rebase] master
git branch -b feature/config_aaa
git checkout feature/config_aaa
```

## Committing Code
Now you’re on a new feature branch. Make sure you commit your changes!

```
git add .
git commit -a -m “new branch”
git push origin feature/config_aaa
```

## Merging Branches
After you’re satisfied with your new branch, merge it into dev to begin formal testing:

```
git checkout dev
git pull origin dev
git merge feature/config_aaa
git push origin dev
```
