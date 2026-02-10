# How to make a release

Here are instruction for how to make a release of OPA.

1. Merge all the code you want in the release into the main branch.

2. Test locally so the main branch compiles and runs correctly.

3. Add a Git version tag. This is best to do on the command line. See instructions below for how to add a tag and push it.

6. The GitHub workflow for making a release will now run. It takes a little while since it needs to compile and build the code. When it's done it will not make the release directly but just a draft.
   
   The draft will end up on https://github.com/opa-code/opa-4/releases.

7. Click on the draft and the edit button, add the release notes you would want and finally on "Publish release".

## Add a tag from command line

1. Checkout the main branch and pull the latest changes from GitHub so everything is up-to-date.
   
   ```bash
   git checkout main
   git pull origin main
   ```
2. Create a tag for the new version. Replace MAJOR.MINOR.PATCH with the version number you want.

   ```bash
   git tag -a vMAJOR.MINOR.PATCH -m "Version MAJOR.MINOR.PATCH."
   ```

   In case the same tag already exists and you need to update it you can do this with the option `-af`.
      
2. Push the tag to GitHub.

   ```bash
   git push origin vMAJOR.MINOR.PATCH
   ```
   In case the same tag already exists on Github you can overwrite it with the option `-f`.

In case you want to see which tags you already have you can do it with the command `git tag`. On Github you can also see it on https://github.com/opa-code/opa-4/tags.
