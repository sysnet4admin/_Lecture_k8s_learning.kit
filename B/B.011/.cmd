# headlamp
## installation 
### Windows
### https://winstall.app/apps/Headlamp.Headlamp
### winget install --id=Headlamp.Headlamp  -e
winget install headlamp -v 0.32.0

### MacOS
### https://formulae.brew.sh/cask/headlamp
### brew install --cask headlamp 
### https://github.com/Homebrew/homebrew-cask/blob/master/Casks/h/headlamp.rb
brew install --cask ./headlamp-v0.32.0/headlamp.rb

# "Headlamp” is damaged and can’t be opened. You should move it to the Trash.
sudo xattr -rd com.apple.quarantine /Applications/Headlamp.app
