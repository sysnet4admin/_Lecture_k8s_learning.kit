# virtualbox (1/3)
## installation 
### Windows 
### https://winget.run/pkg/Oracle/VirtualBox
### https://winstall.app/apps/Oracle.VirtualBox
winget install -e --id Oracle.VirtualBox -v 7.0.18

### MacOS 
### https://formulae.brew.sh/cask/virtualbox 
### brew install --cask virtualbox 
### https://github.com/Homebrew/homebrew-cask/blob/master/Casks/v/virtualbox.rb
### virtualbox v7.0.18
brew install --cask ./virtualbox-v7.0.18/virtualbox.rb


# vagrant (2/3)
## installation 
### Windows 
### https://winget.run/pkg/Hashicorp/Vagrant
### https://winstall.app/apps/Hashicorp.Vagrant
winget install -e --id Hashicorp.Vagrant -v 2.4.1 

### MacOS 
### https://formulae.brew.sh/cask/vagrant
### brew install --cask vagrant
### https://github.com/Homebrew/homebrew-cask/blob/master/Casks/v/vagrant.rb
### vagrant v2.4.1 
brew install --cask ./vagrant-v2.4.1/vagrant.rb


# tabby (3/3)
## installation
### Windows 
### https://winget.run/pkg/Eugeny/Tabby
### https://winstall.app/apps/Eugeny.Tabby
### winget install -e --id Eugeny.Tabby
winget install -e --id Eugeny.Tabby -v 1.0.207

### MacOS 
### https://formulae.brew.sh/cask/tabby
### brew install --cask tabby
### https://github.com/Homebrew/homebrew-cask/blob/master/Casks/t/tabby.rb
### tabby v1.0.207
brew install --cask ./tabby-v1.0.207/tabby.rb

## the location of configuration file 
### https://github.com/Eugeny/tabby/wiki/Config-file
### On Windows, %APPDATA%/Tabby
### On macOS: ~/Library/Application Support/tabby
### On Linux: ~/.config/tabby

## Windows 
cp ./tabby-v1.0.207/config.yaml $env:APPDATA/tabby/

## MacOS 
cp ./tabby-v1.0.207/config.yaml ~/Library/Application\ Support/tabby/
