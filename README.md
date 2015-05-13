# New York Times Documentation - Hyde

## Use in a repository

To use this template as a base for open source documentation, you will need to create a new `gh-pages` branch, and use this repository as a secondary remote.

1. Go to you repository and create a new empty branch. This will create a branch that is divorced from your existing commit history. Make sure you do not have any local modifications.
   `git checkout --orphan gh-pages`
2. Remove all files from the current directory. (Don't worry, they still exist in the git history, and will return when you checkout `develop` again.)
   `git rm -rf .`
3. Add this repo as a secondary remote.
   `git remote add documentation git@github.com:newsdev/documentation.git`
4. Pull down the Hyde branch.
   `git pull documentation hyde`

You should now have the latest skeleton template of Hyde. You can edit the files freely to build out your documentation, but be sure to push to your primary `origin` remote. You can pull down updates from this skeleton remote periodically if desired.

## License

Open sourced under the [Apache 2.0 lisence](LICENSE).

Forked from [Hyde](https://github.com/poole/hyde), open sourced under the [MIT license](LICENSE.md).

Certain dependencies referenced from this repository, such as external fonts, are proprietary and should not be used on websites not operated by The New York Times Company.
