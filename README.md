# myflightmap 2.0

## Getting it running locally

### Step 1. Installing rbenv and ruby-build

Before you get it running locally, you need to have a recent version of Ruby available. Best way to do this is to use `rbenv` to install the latest and greatest.

#### Install with Homebrew

```bash
brew update
brew install rbenv ruby-build
```

Restart your shell.

#### Alternatively: Install manually

```bash
# Install rbenv
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

# Install ruby-build for downloading and building new Ruby versions
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
```

Restart your shell.

### Step 2. Installing Ruby

This app was build on 2.1.5, so install that

```bash
rbenv install 2.1.5
```

Then you'll want to set it as the default ruby version
```bash
rbenv global 2.1.5
ruby -v # Should output 2.1.5
```

### Step 3. Cloning

```
git clone git@github.com:mroach/myflightmap.git
```

### Step 4. Install gems

Use bundler to read the `Gemfile.lock` to install all necessary gems at the correct version. Run this from the `myflightmap` directory.

```
bundle install
```


### Step 5. Running

From inside the `myflightmap` directory:

```
bundle exec rails server
```

Now you should then have a server listening on `http://localhost:3000`. It's running attached to your shell, so if you close it, bye bye rails server. `CTRL+C` will kill it.
