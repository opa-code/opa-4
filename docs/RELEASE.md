# How to make a release

1. Merge all the code you want in the release into the main branch.

2. Test locally so the main branch compiles and runs correctly.

3. Add a Git version tag. This you can do either locally or in the web interface.

   **Locally:**

   1. Checkout the main branch and pull the latest changes from GitHub so everything is up-to-date.
   
      ```bash
      git checkout main
      git pull origin main
      ```
   2. Create a tag for the new version. Replace MAJOR.MINOR.PATCH with the version number you want.

      ```bash
      git tag -a vMAJOR.MINOR.PATCH -m "Version MAJOR.MINOR.PATCH."
      ```
      
      In case you need to update an existing tag you can do this with the option `-af`.
      
   4. Push the tag to GitHub.
  
      ```bash
      git push origin v4.2.4
      ```
      In case you need to push an existing tag you can do this with the option `-f`.

5. The GitHub workflow for making a release will now run. It takes a little while since it needs to compile and build the code. When it's done it will not make the release directly but just a draft.
   The draft will end up on https://github.com/opa-code/opa-4/releases.

7. Click on the draft and the edit button, add the release notes you would want and finally on "Publish release".
