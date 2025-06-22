# vmware-fusion (1/3)
## installation 
### MacOS(arm64)
### https://formulae.brew.sh/cask/virtualbox 
### brew install --cask virtualbox 
### https://github.com/Homebrew/homebrew-cask/blob/master/Casks/v/virtualbox.rb
### virtualbox v7.1.10
brew install --cask ./virtualbox-v7.1.10/virtualbox.rb

# vagrant (2/3)
## installation 
### MacOS 
### https://formulae.brew.sh/cask/vagrant
### brew install --cask vagrant
### https://github.com/Homebrew/homebrew-cask/blob/master/Casks/v/vagrant.rb
### vagrant v2.4.7
brew install --cask ./vagrant-v2.4.7/vagrant.rb

### (optional) uninstall vagrant-vmware-desktop 
vagrant plugin uninstall vagrant-vmware-desktop

# READY TO RUN the `vagrant up` 


# tabby (3/3)
## installation
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
