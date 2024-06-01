# utm (1/2)
## installation 
### MacOS(arm64)
### https://formulae.brew.sh/cask/utm
### brew install --cask utm
### https://github.com/Homebrew/homebrew-cask/blob/master/Casks/u/utm.rb
### utm v4.5.2 
brew install --cask ./utm-v4.5.2/utm.rb

# tabby (2/2)
## installation
### MacOS 
### https://formulae.brew.sh/cask/tabby
### brew install --cask tabby
### https://github.com/Homebrew/homebrew-cask/blob/master/Casks/tabby.rb
### tabby v1.0.207
brew install --cask ./tabby-v1.0.207/tabby.rb

## the location of configuration file 
### https://github.com/Eugeny/tabby/wiki/Config-file
### On Windows, %APPDATA%/Tabby
### On macOS: ~/Library/Application Support/tabby
### On Linux: ~/.config/tabby

## Windows 
cp ./tabby-v1.0.207/config.yaml $env:APPDATA/tabby 

## MacOS 
cp ./tabby-v1.0.207/config.yaml ~/Library/Application\ Support/tabby
