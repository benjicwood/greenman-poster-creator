#!/usr/bin/env sh
set -e

# 1. Build the project
npm run build

# 2. Navigate into the build output directory
cd dist

# 3. Remove any previous git history in dist
rm -rf .git

# 4. Initialize a temporary git repo
git init -b main
git add -A
git commit -m 'deploy'

# 5. Push to GitHub Pages
# Use SSH (ensure your SSH key is set up)
git push -f git@github.com:benjicwood/greenman-poster-creator.git main:gh-pages
# git push -f https://github.com/benjicwood/greenman-poster-creator.git main:gh-pages
# git -c core.sshCommand="ssh -o PubkeyAcceptedAlgorithms=+ssh-rsa" push -f git@github.com:benjicwood/greenman-poster-creator.git main:gh-pages

# 6. Return to root
cd -

echo "✅ Deployment complete! Visit: https://benjicwood.github.io/greenman-poster-creator/"
